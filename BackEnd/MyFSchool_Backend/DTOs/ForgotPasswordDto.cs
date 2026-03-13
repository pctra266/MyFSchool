using System.ComponentModel.DataAnnotations;

namespace MyFSchool_Backend.DTOs;

public class ForgotPasswordDto
{
    // Either Email or PhoneNumber must be provided
    [EmailAddress]
    public string? Email { get; set; }

    [MaxLength(20)]
    public string? PhoneNumber { get; set; }
}

public class ResetPasswordDto
{
    // Either Email or PhoneNumber must be provided
    [EmailAddress]
    public string? Email { get; set; }

    public string? PhoneNumber { get; set; }

    [Required]
    public string Otp { get; set; } = string.Empty;

    [Required]
    [MinLength(6)]
    public string NewPassword { get; set; } = string.Empty;
}
