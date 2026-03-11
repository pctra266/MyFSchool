using System.Security.Claims;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using MyFSchool_Backend.Data;
using MyFSchool_Backend.Helpers;

namespace MyFSchool_Backend.Controllers;

[ApiController]
[Route("api/[controller]")]
public class TransactionsController : ControllerBase
{
    private readonly MyFSchoolDbContext _context;
    private readonly IConfiguration _configuration;

    public TransactionsController(MyFSchoolDbContext context, IConfiguration configuration)
    {
        _context = context;
        _configuration = configuration;
    }

    [HttpGet]
    [Authorize(Roles = "Student")]
    public async Task<IActionResult> GetTransactions()
    {
        var userIdStr = User.FindFirstValue(ClaimTypes.NameIdentifier);
        if (!int.TryParse(userIdStr, out var studentId)) return Unauthorized();

        var transactions = await _context.Transactions
            .Where(t => t.StudentId == studentId)
            .OrderByDescending(t => t.TransactionDate)
            .ToListAsync();

        return Ok(transactions);
    }
    
    [HttpPost("pay/{id}")]
    [Authorize(Roles = "Student")]
    public async Task<IActionResult> CreateVnPayPayment(int id)
    {
        var userIdStr = User.FindFirstValue(ClaimTypes.NameIdentifier);
        if (!int.TryParse(userIdStr, out var studentId)) return Unauthorized();

        var transaction = await _context.Transactions.FirstOrDefaultAsync(t => t.Id == id && t.StudentId == studentId);
        if (transaction == null) return NotFound("Transaction not found.");
        if (transaction.Status == "Paid" || transaction.Status == "Success") return BadRequest("Already paid.");

        // Lấy config VNPay
        string vnp_Returnurl = _configuration["VnPay:ReturnUrl"] ?? "";
        string vnp_Url = _configuration["VnPay:BaseUrl"] ?? "";
        string vnp_TmnCode = _configuration["VnPay:TmnCode"] ?? "";
        string vnp_HashSecret = _configuration["VnPay:HashSecret"] ?? "";

        var vnpay = new VnPayLibrary();
        
        var ipAddr = HttpContext.Connection.RemoteIpAddress?.ToString() ?? "127.0.0.1";
        if (ipAddr == "::1") ipAddr = "127.0.0.1";

        vnpay.AddRequestData("vnp_Version", "2.1.0");
        vnpay.AddRequestData("vnp_Command", "pay");
        vnpay.AddRequestData("vnp_TmnCode", vnp_TmnCode);
        vnpay.AddRequestData("vnp_Amount", ((long)(transaction.Amount * 100)).ToString()); // VNPay nhân 100
        vnpay.AddRequestData("vnp_CreateDate", DateTime.Now.ToString("yyyyMMddHHmmss"));
        vnpay.AddRequestData("vnp_CurrCode", "VND");
        vnpay.AddRequestData("vnp_IpAddr", ipAddr);
        vnpay.AddRequestData("vnp_Locale", "vn");
        vnpay.AddRequestData("vnp_OrderInfo", $"Thanh toan hoc phi giao dich: {transaction.Id}");
        vnpay.AddRequestData("vnp_OrderType", "other"); // default
        vnpay.AddRequestData("vnp_ReturnUrl", vnp_Returnurl);
        // Mã đơn hàng: ghép ID giao dịch và timestamp để tránh trùng lặp
        vnpay.AddRequestData("vnp_TxnRef", $"{transaction.Id}_{DateTime.Now.Ticks}"); 

        string paymentUrl = vnpay.CreateRequestUrl(vnp_Url, vnp_HashSecret);

        return Ok(new { PaymentUrl = paymentUrl });
    }

    [HttpGet("vnpay-return")]
    public async Task<IActionResult> VnPayReturn()
    {
        var queryParams = HttpContext.Request.Query;
        if (queryParams.Count == 0) return BadRequest();

        string vnp_HashSecret = _configuration["VnPay:HashSecret"] ?? "";
        var vnpayData = new VnPayLibrary();

        foreach (var (key, value) in queryParams)
        {
            if (!string.IsNullOrEmpty(key) && key.StartsWith("vnp_"))
            {
                vnpayData.AddResponseData(key, value.ToString());
            }
        }

        string orderInfo = vnpayData.GetResponseData("vnp_OrderInfo");
        string txnRef = vnpayData.GetResponseData("vnp_TxnRef");
        string vnp_ResponseCode = vnpayData.GetResponseData("vnp_ResponseCode");
        string vnp_SecureHash = queryParams["vnp_SecureHash"].ToString();

        bool checkSignature = vnpayData.ValidateSignature(vnp_SecureHash, vnp_HashSecret);

        if (checkSignature)
        {
            if (vnp_ResponseCode == "00")
            {
                // Thanh toán thành công
                // Trích xuất Transaction ID từ chuỗi vnp_TxnRef (Format: ID_Ticks)
                var idStr = txnRef.Split('_')[0];
                if (int.TryParse(idStr, out int transactionId))
                {
                    var transaction = await _context.Transactions.FindAsync(transactionId);
                    if (transaction != null && transaction.Status != "Paid")
                    {
                        transaction.Status = "Paid";
                        await _context.SaveChangesAsync();
                        // Trả về HTML script để đóng in-app browser WebView/Chrome custom tab
                        return Content("<html><body><h3>Thanh toán thành công!</h3><p>Bạn có thể quay lại ứng dụng.</p></body></html>", "text/html");
                    }
                }
            }
            return Content("<html><body><h3>Có lỗi xảy ra trong quá trình xử lý giao dịch!</h3><p>Bạn có thể quay lại ứng dụng.</p></body></html>", "text/html");
        }
        else
        {
            return Content("<html><body><h3>Chữ ký không hợp lệ!</h3><p>Bạn có thể quay lại ứng dụng.</p></body></html>", "text/html");
        }
    }
}
