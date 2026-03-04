using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace MyFSchool_Backend.Models;

public class User
{
    [Key]
    public int Id { get; set; }

    [Required]
    [MaxLength(100)]
    public string FullName { get; set; } = string.Empty;

    [Required]
    [MaxLength(100)]
    [EmailAddress]
    public string Email { get; set; } = string.Empty;

    [Required]
    [MaxLength(50)]
    public string Role { get; set; } = string.Empty;

    [MaxLength(100)]
    public string? FocusArea { get; set; }

    public bool PushEnabled { get; set; } = true;

    public bool EmailEnabled { get; set; } = false;

    public DateTime CreatedAt { get; set; } = DateTime.Now;

    // Navigation properties
    public ICollection<Subject> TaughtSubjects { get; set; } = new List<Subject>();
    public ICollection<AcademicResult> AcademicResults { get; set; } = new List<AcademicResult>();
    public ICollection<Attendance> Attendances { get; set; } = new List<Attendance>();
    public ICollection<LeaveRequest> LeaveRequests { get; set; } = new List<LeaveRequest>();
    public ICollection<Transaction> Transactions { get; set; } = new List<Transaction>();
    public ICollection<StudentClass> StudentClasses { get; set; } = new List<StudentClass>();
}
