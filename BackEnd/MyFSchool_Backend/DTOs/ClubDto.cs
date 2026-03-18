namespace MyFSchool_Backend.DTOs;

public class ClubDto
{
    public int Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public string? Description { get; set; }
    public string? AvatarUrl { get; set; }
    public DateTime? EstablishedDate { get; set; }
    public DateTime CreatedAt { get; set; }
}
