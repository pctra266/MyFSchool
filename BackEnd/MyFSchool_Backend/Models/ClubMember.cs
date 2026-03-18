using System.ComponentModel.DataAnnotations;

namespace MyFSchool_Backend.Models;

public class ClubMember
{
    [Key]
    public int Id { get; set; }

    [Required]
    public int ClubId { get; set; }
    public Club Club { get; set; } = null!;

    [Required]
    public int StudentId { get; set; }
    public User Student { get; set; } = null!;

    [MaxLength(50)]
    public string Role { get; set; } = "Member"; // "Member", "Leader"

    public DateTime JoinedDate { get; set; } = DateTime.Now;
}
