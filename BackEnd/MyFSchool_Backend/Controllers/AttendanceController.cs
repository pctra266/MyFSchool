using System.Security.Claims;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using MyFSchool_Backend.Data;
using MyFSchool_Backend.DTOs;

namespace MyFSchool_Backend.Controllers;

[Authorize(Roles = "Student")]
[ApiController]
[Route("api/[controller]")]
public class AttendanceController : ControllerBase
{
    private readonly MyFSchoolDbContext _context;

    public AttendanceController(MyFSchoolDbContext context)
    {
        _context = context;
    }

    [HttpGet("summary")]
    public async Task<ActionResult<AttendanceSummaryDto>> GetSummary()
    {
        var userIdStr = User.FindFirstValue(ClaimTypes.NameIdentifier);
        if (!int.TryParse(userIdStr, out var studentId)) return Unauthorized();

        var attendances = await _context.Attendance
            .Where(a => a.StudentId == studentId)
            .ToListAsync();

        return Ok(new AttendanceSummaryDto
        {
            Present = attendances.Count(a => a.Status == "Present"),
            Absent = attendances.Count(a => a.Status == "Absent"),
            Late = attendances.Count(a => a.Status == "Late")
        });
    }

    [HttpGet("monthly")]
    public async Task<IActionResult> GetMonthly([FromQuery] int year, [FromQuery] int month)
    {
        var userIdStr = User.FindFirstValue(ClaimTypes.NameIdentifier);
        if (!int.TryParse(userIdStr, out var studentId)) return Unauthorized();

        var attendances = await _context.Attendance
            .Include(a => a.Timetable)
                .ThenInclude(t => t.Subject)
            .Where(a => a.StudentId == studentId && a.AttendanceDate.Year == year && a.AttendanceDate.Month == month)
            .OrderBy(a => a.AttendanceDate)
            .ThenBy(a => a.Timetable!.StartTime)
            .Select(a => new
            {
                Date = a.AttendanceDate,
                Status = a.Status,
                SubjectName = a.Timetable != null && a.Timetable.Subject != null ? a.Timetable.Subject.Name : "Unknown",
                StartTime = a.Timetable != null ? a.Timetable.StartTime : TimeSpan.Zero,
                EndTime = a.Timetable != null ? a.Timetable.EndTime : TimeSpan.Zero
            })
            .ToListAsync();

        return Ok(attendances);
    }
}
