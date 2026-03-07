using Microsoft.Extensions.Logging;

namespace MyFSchool_Backend.Services;

public interface IEmailService
{
    Task SendOtpEmailAsync(string email, string otp);
}

public class EmailService : IEmailService
{
    private readonly ILogger<EmailService> _logger;

    public EmailService(ILogger<EmailService> logger)
    {
        _logger = logger;
    }

    public Task SendOtpEmailAsync(string email, string otp)
    {
        // Trong môi trường thực tế, đây là nơi sử dụng MailKit, SmtpClient, SendGrid, Amazon SES...
        // Hiện tại tạm thời in mã OTP ra console/log để test giao diện.
        _logger.LogInformation("\n===========================================");
        _logger.LogInformation($"[MOCK EMAIL SYSTEM]");
        _logger.LogInformation($"To: {email}");
        _logger.LogInformation($"Subject: Your Password Reset OTP");
        _logger.LogInformation($"Body: Your OTP for resetting password is: {otp}. This code is valid for 5 minutes.");
        _logger.LogInformation("===========================================\n");

        return Task.CompletedTask;
    }
}
