using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace MyFSchool_Backend.Models;

public class Transaction
{
    [Key]
    public int Id { get; set; }

    public int StudentId { get; set; }

    [Required]
    [MaxLength(150)]
    public string Title { get; set; } = string.Empty;

    public decimal Amount { get; set; }

    [Required]
    [MaxLength(20)]
    public string TransactionType { get; set; } = string.Empty;

    [Required]
    [MaxLength(20)]
    public string Status { get; set; } = string.Empty;

    [Required]
    public DateTime TransactionDate { get; set; }

    // Navigation properties
    [ForeignKey("StudentId")]
    public User? Student { get; set; }
}
