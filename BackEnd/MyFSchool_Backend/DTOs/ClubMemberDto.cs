namespace MyFSchool_Backend.DTOs;

public class ClubMemberDto
{
    public int Id { get; set; }
    public int ClubId { get; set; }
    public int StudentId { get; set; }
    public string StudentName { get; set; } = string.Empty;
    public string Role { get; set; } = string.Empty;
    public DateTime JoinedDate { get; set; }
}
