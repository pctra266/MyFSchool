using System.Security.Claims;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using MyFSchool_Backend.Data;

namespace MyFSchool_Backend.Controllers;

[Authorize(Roles = "Student")]
[ApiController]
[Route("api/[controller]")]
public class TimetableController : ControllerBase
{
    private readonly MyFSchoolDbContext _context;

    public TimetableController(MyFSchoolDbContext context)
    {
        _context = context;
    }

    [HttpGet]
    public async Task<IActionResult> GetTimetable()
    {
        var userIdStr = User.FindFirstValue(ClaimTypes.NameIdentifier);
        if (!int.TryParse(userIdStr, out var studentId)) return Unauthorized();

        var classIds = await _context.StudentClasses
            .Where(sc => sc.StudentId == studentId)
            .Select(sc => sc.ClassId)
            .ToListAsync();

        var timetables = await _context.Timetables
            .Include(t => t.Subject)
            .Include(t => t.Teacher)
            .Where(t => classIds.Contains(t.ClassId))
            .Select(t => new
            {
                t.Id,
                SubjectName = t.Subject!.Name,
                TeacherName = t.Teacher != null ? t.Teacher.FullName : null,
                t.Room,
                t.DayOfWeek,
                t.StartTime,
                t.EndTime
            })
            .ToListAsync();

        return Ok(timetables);
    }
}
