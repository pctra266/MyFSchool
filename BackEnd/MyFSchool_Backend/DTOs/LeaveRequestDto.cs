namespace MyFSchool_Backend.DTOs;

public class LeaveRequestDto
{
    public int Id { get; set; }
    public DateTime RequestDate { get; set; }
    public string Reason { get; set; } = string.Empty;
    public string Status { get; set; } = string.Empty;
    //public string? DocumentUrl { get; set; }
    //public DateTime CreatedAt { get; set; }
}
