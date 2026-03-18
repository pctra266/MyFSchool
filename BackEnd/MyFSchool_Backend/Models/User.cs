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
    [MaxLength(255)]
    public string PasswordHash { get; set; } = string.Empty;

    public ICollection<UserRole> UserRoles { get; set; } = new List<UserRole>();

    [MaxLength(100)]
    public string? FocusArea { get; set; }

    public DateTime? DateOfBirth { get; set; }

    [MaxLength(10)]
    public string? Gender { get; set; }

    public string? Address { get; set; }

    [MaxLength(20)]
    public string? PhoneNumber { get; set; }

    [MaxLength(100)]
    public string? ParentName { get; set; }

    public bool PushEnabled { get; set; } = true;

    public bool EmailEnabled { get; set; } = false;

    public DateTime CreatedAt { get; set; } = DateTime.Now;

    [MaxLength(10)]
    public string? ResetPasswordOtp { get; set; }

    public DateTime? ResetPasswordExpiry { get; set; }

    // Navigation properties
    public ICollection<Subject> TaughtSubjects { get; set; } = new List<Subject>();
    public ICollection<AcademicResult> AcademicResults { get; set; } = new List<AcademicResult>();
    public ICollection<Attendance> Attendances { get; set; } = new List<Attendance>();
    public ICollection<LeaveRequest> LeaveRequests { get; set; } = new List<LeaveRequest>();
    public ICollection<Transaction> Transactions { get; set; } = new List<Transaction>();
    public ICollection<StudentClass> StudentClasses { get; set; } = new List<StudentClass>();
    public ICollection<Note> Notes { get; set; } = new List<Note>();
    public ICollection<Notification> Notifications { get; set; } = new List<Notification>();
    public ICollection<ClubMember> ClubMembers { get; set; } = new List<ClubMember>();
}
