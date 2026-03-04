using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace MyFSchool_Backend.Models;

public class NewsAttachment
{
    [Key]
    public int Id { get; set; }

    public int NewsId { get; set; }

    [Required]
    [MaxLength(255)]
    public string FileName { get; set; } = string.Empty;

    [Required]
    [MaxLength(50)]
    public string FileSize { get; set; } = string.Empty;

    [Required]
    [MaxLength(255)]
    public string FileUrl { get; set; } = string.Empty;

    // Navigation properties
    [ForeignKey("NewsId")]
    public News? News { get; set; }
}
