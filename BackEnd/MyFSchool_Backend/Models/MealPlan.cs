using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace MyFSchool_Backend.Models;

public class MealPlan
{
    [Key]
    public int Id { get; set; }

    [Required]
    [MaxLength(20)]
    public string DayOfWeek { get; set; } = string.Empty;

    [MaxLength(255)]
    public string? MainDish { get; set; }

    [MaxLength(255)]
    public string? SideDish { get; set; }

    [MaxLength(255)]
    public string? Soup { get; set; }

    public DateTime CreatedAt { get; set; }
}
