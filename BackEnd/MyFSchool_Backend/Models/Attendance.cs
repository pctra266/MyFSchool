using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace MyFSchool_Backend.Models;

[Table("Attendance")]
public class Attendance
{
    [Key]
    public int Id { get; set; }

    public int StudentId { get; set; }

    public DateTime AttendanceDate { get; set; }

    [Required]
    [MaxLength(20)]
    public string Status { get; set; } = string.Empty;

    // Navigation properties
    [ForeignKey("StudentId")]
    public User? Student { get; set; }
}
