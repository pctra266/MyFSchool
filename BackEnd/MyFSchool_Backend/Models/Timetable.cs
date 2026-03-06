using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace MyFSchool_Backend.Models;
[Table("Timetable")]

public class Timetable
{
    [Key]
    public int Id { get; set; }

    public int ClassId { get; set; }

    public int SubjectId { get; set; }

    public int? TeacherId { get; set; }

    [Required]
    [MaxLength(50)]
    public string Room { get; set; } = string.Empty;

    [Required]
    [MaxLength(15)]
    public string DayOfWeek { get; set; } = string.Empty;

    [Required]
    public TimeSpan StartTime { get; set; }

    [Required]
    public TimeSpan EndTime { get; set; }

    // Navigation properties
    [ForeignKey("ClassId")]
    public Class? Class { get; set; }

    [ForeignKey("SubjectId")]
    public Subject? Subject { get; set; }

    [ForeignKey("TeacherId")]
    public User? Teacher { get; set; }
}
