using System.ComponentModel.DataAnnotations;

namespace MyFSchool_Backend.Models;

public class ClubEvent
{
    [Key]
    public int Id { get; set; }

    [Required]
    public int ClubId { get; set; }
    public Club Club { get; set; } = null!;

    [Required]
    [MaxLength(255)]
    public string Title { get; set; } = string.Empty;

    public string? Description { get; set; }

    public DateTime? EventDate { get; set; }

    public DateTime CreatedAt { get; set; } = DateTime.Now;
}
