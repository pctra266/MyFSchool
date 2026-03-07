using MailKit.Net.Smtp;
using MailKit.Security;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using MimeKit;

namespace MyFSchool_Backend.Services;

public interface IEmailService
{
    Task SendOtpEmailAsync(string email, string otp);
}

public class EmailService : IEmailService
{
    private readonly EmailSettings _emailSettings;
    private readonly ILogger<EmailService> _logger;

    // Inject IOptions<EmailSettings> để lấy cấu hình từ appsettings
    public EmailService(IOptions<EmailSettings> emailOptions, ILogger<EmailService> logger)
    {
        _emailSettings = emailOptions.Value;
        _logger = logger;
    }

    public async Task SendOtpEmailAsync(string email, string otp)
    {
        try
        {
            // 1. Tạo đối tượng email
            var message = new MimeMessage();
            message.From.Add(new MailboxAddress(_emailSettings.SenderName, _emailSettings.SenderEmail));
            message.To.Add(MailboxAddress.Parse(email));
            message.Subject = "Your Password Reset OTP - MyFSchool";

            // 2. Nội dung email (có thể dùng HTML)
            var builder = new BodyBuilder
            {
                HtmlBody = $"<p>Xin chào,</p><p>Mã OTP để đặt lại mật khẩu của bạn là: <strong>{otp}</strong></p><p>Mã này có hiệu lực trong 5 phút.</p>"
            };
            message.Body = builder.ToMessageBody();

            // 3. Kết nối SMTP và Gửi
            using var smtp = new SmtpClient();

            // Connect
            await smtp.ConnectAsync(_emailSettings.SmtpServer, _emailSettings.Port, SecureSocketOptions.StartTls);

            // Authenticate
            await smtp.AuthenticateAsync(_emailSettings.SenderEmail, _emailSettings.Password);

            // Send
            await smtp.SendAsync(message);

            // Disconnect
            await smtp.DisconnectAsync(true);

            _logger.LogInformation($"[EMAIL SUCCESS] Đã gửi OTP thành công tới {email}");
        }
        catch (Exception ex)
        {
            _logger.LogError($"[EMAIL ERROR] Lỗi khi gửi email tới {email}: {ex.Message}");
            throw; // Tuỳ thuộc vào logic bạn muốn ném lỗi hay chỉ log lại
        }
    }
}