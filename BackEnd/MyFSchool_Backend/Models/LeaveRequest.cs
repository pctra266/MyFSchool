using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace MyFSchool_Backend.Models;

public class LeaveRequest
{
    [Key]
    public int Id { get; set; }

    public int StudentId { get; set; }

    [Required]
    public DateTime RequestDate { get; set; }

    [Required]
    public string Reason { get; set; } = string.Empty;

    [MaxLength(20)]
    public string Status { get; set; } = "Pending";

    [MaxLength(255)]
    public string? DocumentUrl { get; set; }

    public DateTime CreatedAt { get; set; } = DateTime.Now;

    // Navigation properties
    [ForeignKey("StudentId")]
    public User? Student { get; set; }
}
