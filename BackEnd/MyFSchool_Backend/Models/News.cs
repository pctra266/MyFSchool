using System.ComponentModel.DataAnnotations;

namespace MyFSchool_Backend.Models;

public class News
{
    [Key]
    public int Id { get; set; }

    [Required]
    [MaxLength(200)]
    public string Title { get; set; } = string.Empty;

    [Required]
    public string Description { get; set; } = string.Empty;

    [Required]
    [MaxLength(50)]
    public string Category { get; set; } = string.Empty;

    [MaxLength(255)]
    public string? ImageUrl { get; set; }

    public DateTime CreatedAt { get; set; } = DateTime.Now;

    // Navigation properties
    public ICollection<NewsAttachment> Attachments { get; set; } = new List<NewsAttachment>();
}
