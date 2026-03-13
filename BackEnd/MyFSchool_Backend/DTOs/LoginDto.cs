namespace MyFSchool_Backend.DTOs;

public class LoginDto
{
    public string? Email { get; set; }
    public string? PhoneNumber { get; set; }
    public string Password { get; set; } = string.Empty;
}
