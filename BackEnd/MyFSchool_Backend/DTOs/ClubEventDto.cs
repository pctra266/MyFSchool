namespace MyFSchool_Backend.DTOs;

public class ClubEventDto
{
    public int Id { get; set; }
    public int ClubId { get; set; }
    public string Title { get; set; } = string.Empty;
    public string? Description { get; set; }
    public DateTime? EventDate { get; set; }
    public DateTime CreatedAt { get; set; }
}
