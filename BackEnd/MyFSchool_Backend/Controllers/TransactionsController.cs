using System.Security.Claims;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using MyFSchool_Backend.Data;

namespace MyFSchool_Backend.Controllers;

[Authorize(Roles = "Student")]
[ApiController]
[Route("api/[controller]")]
public class TransactionsController : ControllerBase
{
    private readonly MyFSchoolDbContext _context;

    public TransactionsController(MyFSchoolDbContext context)
    {
        _context = context;
    }

    [HttpGet]
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
    public async Task<IActionResult> PayTransaction(int id)
    {
        var userIdStr = User.FindFirstValue(ClaimTypes.NameIdentifier);
        if (!int.TryParse(userIdStr, out var studentId)) return Unauthorized();

        var transaction = await _context.Transactions.FirstOrDefaultAsync(t => t.Id == id && t.StudentId == studentId);
        if (transaction == null) return NotFound();

        transaction.Status = "Paid";
        await _context.SaveChangesAsync();

        return Ok(transaction);
    }
}
