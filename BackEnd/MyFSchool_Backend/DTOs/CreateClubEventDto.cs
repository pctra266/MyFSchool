using System.ComponentModel.DataAnnotations;

namespace MyFSchool_Backend.DTOs;

public class CreateClubEventDto
{
    [Required]
    public string Title { get; set; } = string.Empty;
    public string? Description { get; set; }
    public DateTime? EventDate { get; set; }
}
