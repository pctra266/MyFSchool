using System.Security.Claims;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using MyFSchool_Backend.Data;
using MyFSchool_Backend.Models;

namespace MyFSchool_Backend.Controllers;

[Authorize]
[ApiController]
[Route("api/[controller]")]
public class NotesController : ControllerBase
{
    private readonly MyFSchoolDbContext _context;

    public NotesController(MyFSchoolDbContext context)
    {
        _context = context;
    }

    [HttpGet]
    public async Task<IActionResult> GetNotes()
    {
        var userIdStr = User.FindFirstValue(ClaimTypes.NameIdentifier);
        if (!int.TryParse(userIdStr, out var userId)) return Unauthorized();

        var notes = await _context.Notes
            .Include(n => n.Teacher)
            .Where(n => n.StudentId == userId)
            .OrderByDescending(n => n.CreatedAt)
            .Select(n => new
            {
                n.Id,
                n.Content,
                n.Type,
                n.CreatedAt,
                TeacherName = n.Teacher != null ? n.Teacher.FullName : "System"
            })
            .ToListAsync();

        return Ok(notes);
    }
}
