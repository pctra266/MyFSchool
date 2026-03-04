using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace MyFSchool_Backend.Models;

public class AcademicResult
{
    [Key]
    public int Id { get; set; }

    public int StudentId { get; set; }

    public int SubjectId { get; set; }

    [Required]
    public int Semester { get; set; }

    [Required]
    [MaxLength(100)]
    public string AssessmentName { get; set; } = string.Empty;

    [Required]
    [Range(0, 10)]
    public decimal Score { get; set; }

    // Navigation properties
    [ForeignKey("StudentId")]
    public User? Student { get; set; }

    [ForeignKey("SubjectId")]
    public Subject? Subject { get; set; }
}
