using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace MyFSchool_Backend.Models;

public class Note
{
    [Key]
    public int Id { get; set; }

    public int StudentId { get; set; }
    public int? TeacherId { get; set; }

    [Required]
    public string Content { get; set; } = string.Empty;

    [MaxLength(50)]
    public string Type { get; set; } = string.Empty;

    public DateTime CreatedAt { get; set; } = DateTime.Now;

    // Navigation properties
    [ForeignKey("StudentId")]
    public User? Student { get; set; }

    [ForeignKey("TeacherId")]
    public User? Teacher { get; set; }
}
