using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace MyFSchool_Backend.Models;

public class Subject
{
    [Key]
    public int Id { get; set; }

    [Required]
    [MaxLength(100)]
    public string Name { get; set; } = string.Empty;

    public int? TeacherId { get; set; }

    // Navigation properties
    [ForeignKey("TeacherId")]
    public User? Teacher { get; set; }

    public ICollection<AcademicResult> AcademicResults { get; set; } = new List<AcademicResult>();
    public ICollection<Timetable> Timetables { get; set; } = new List<Timetable>();
}
