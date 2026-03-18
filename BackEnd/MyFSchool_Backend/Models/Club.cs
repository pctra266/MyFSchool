using System.ComponentModel.DataAnnotations;

namespace MyFSchool_Backend.Models;

public class Club
{
    [Key]
    public int Id { get; set; }

    [Required]
    [MaxLength(255)]
    public string Name { get; set; } = string.Empty;

    public string? Description { get; set; }

    public string? AvatarUrl { get; set; }

    public DateTime? EstablishedDate { get; set; }

    public DateTime CreatedAt { get; set; } = DateTime.Now;

    public ICollection<ClubMember> Members { get; set; } = new List<ClubMember>();
    public ICollection<ClubEvent> Events { get; set; } = new List<ClubEvent>();
}
