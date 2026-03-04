using System.ComponentModel.DataAnnotations;

namespace MyFSchool_Backend.Models;

public class Class
{
    [Key]
    public int Id { get; set; }

    [Required]
    [MaxLength(50)]
    public string Name { get; set; } = string.Empty;

    public DateTime CreatedAt { get; set; } = DateTime.Now;

    // Navigation properties
    public ICollection<StudentClass> StudentClasses { get; set; } = new List<StudentClass>();
    public ICollection<Timetable> Timetables { get; set; } = new List<Timetable>();
}
