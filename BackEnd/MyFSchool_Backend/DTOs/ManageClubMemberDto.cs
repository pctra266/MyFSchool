using System.ComponentModel.DataAnnotations;

namespace MyFSchool_Backend.DTOs;

public class ManageClubMemberDto
{
    [Required]
    public string Action { get; set; } = string.Empty; // "Approve", "Kick", "Promote", "Demote"
}
