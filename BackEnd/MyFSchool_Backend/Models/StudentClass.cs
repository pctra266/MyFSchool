using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace MyFSchool_Backend.Models;

public class StudentClass
{
    public int StudentId { get; set; }
    public int ClassId { get; set; }

    // Navigation properties
    [ForeignKey("StudentId")]
    public User? Student { get; set; }

    [ForeignKey("ClassId")]
    public Class? Class { get; set; }
}
