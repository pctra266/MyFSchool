using System.Security.Claims;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using MyFSchool_Backend.Data;

namespace MyFSchool_Backend.Controllers;

[Authorize(Roles = "Student")]
[ApiController]
[Route("api/academic-results")]
public class AcademicResultsController : ControllerBase
{
    private readonly MyFSchoolDbContext _context;

    public AcademicResultsController(MyFSchoolDbContext context)
    {
        _context = context;
    }

    [HttpGet]
    public async Task<IActionResult> GetResults()
    {
        var userIdStr = User.FindFirstValue(ClaimTypes.NameIdentifier);
        if (!int.TryParse(userIdStr, out var studentId)) return Unauthorized();

        var results = await _context.AcademicResults
            .Include(ar => ar.Subject)
                .ThenInclude(s => s!.Teacher)
            .Where(ar => ar.StudentId == studentId)
            .OrderBy(ar => ar.GradeLevel)
            .ThenBy(ar => ar.Semester)
            .Select(ar => new
            {
                ar.Id,
                SubjectName = ar.Subject!.Name,
                TeacherName = ar.Subject.Teacher != null ? ar.Subject.Teacher.FullName : "Unknown",
                ar.GradeLevel,
                ar.Semester,
                ar.AssessmentName,
                ar.Score
            })
            .ToListAsync();

        return Ok(results);
    }
}
