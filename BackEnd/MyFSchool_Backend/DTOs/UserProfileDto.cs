namespace MyFSchool_Backend.DTOs;

public class UserProfileDto
{
    public int Id { get; set; }
    public string FullName { get; set; } = string.Empty;
    public string Email { get; set; } = string.Empty;
    public List<string> Roles { get; set; } = new();
    public string? FocusArea { get; set; }
    public DateTime? DateOfBirth { get; set; }
    public string? Gender { get; set; }
    public string? Address { get; set; }
    public string? PhoneNumber { get; set; }
    public string? ParentName { get; set; }
    public bool PushEnabled { get; set; }
    public bool EmailEnabled { get; set; }
}
