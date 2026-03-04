namespace MyFSchool_Backend.DTOs;

public class AttendanceSummaryDto
{
    public int Present { get; set; }
    public int Absent { get; set; }
    public int Late { get; set; }
}
