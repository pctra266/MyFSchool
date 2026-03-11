using System.Security.Claims;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using MyFSchool_Backend.Data;
using MyFSchool_Backend.DTOs;
using MyFSchool_Backend.Models;

namespace MyFSchool_Backend.Controllers;

[Authorize(Roles = "Student")]
[ApiController]
[Route("api/leave-requests")]
public class LeaveRequestsController : ControllerBase
{
    private readonly MyFSchoolDbContext _context;

    public LeaveRequestsController(MyFSchoolDbContext context)
    {
        _context = context;
    }

    [HttpGet]
    public async Task<IActionResult> GetRequests()
    {
        var userIdStr = User.FindFirstValue(ClaimTypes.NameIdentifier);
        if (!int.TryParse(userIdStr, out var studentId)) return Unauthorized();

        var requests = await _context.LeaveRequests
            .Where(lr => lr.StudentId == studentId)
            .OrderByDescending(lr => lr.RequestDate)
            .ToListAsync();

        return Ok(requests);
    }

    [HttpPost]
    public async Task<IActionResult> CreateRequest([FromBody] LeaveRequestDto dto)
    {
        var userIdStr = User.FindFirstValue(ClaimTypes.NameIdentifier);
        if (!int.TryParse(userIdStr, out var studentId)) return Unauthorized();

        var request = new LeaveRequest
        {
            StudentId = studentId,
            RequestDate = dto.RequestDate,
            Reason = dto.Reason,
            Status = "Pending",
        };

        _context.LeaveRequests.Add(request);
        await _context.SaveChangesAsync();

        return CreatedAtAction(nameof(GetRequests), new { id = request.Id }, request);
    }

    [HttpPut("{id}")]
    public async Task<IActionResult> UpdateRequest(int id, [FromBody] LeaveRequestDto dto)
    {
        var userIdStr = User.FindFirstValue(ClaimTypes.NameIdentifier);
        if (!int.TryParse(userIdStr, out var studentId)) return Unauthorized();

        var request = await _context.LeaveRequests
            .FirstOrDefaultAsync(lr => lr.Id == id && lr.StudentId == studentId);

        if (request == null)
            return NotFound(new { message = "Leave request not found." });

        if (request.Status != "Pending")
            return BadRequest(new { message = "Only pending requests can be updated." });

        request.RequestDate = dto.RequestDate;
        request.Reason = dto.Reason;

        await _context.SaveChangesAsync();

        return Ok(request);
    }

    [HttpDelete("{id}")]
    public async Task<IActionResult> DeleteRequest(int id)
    {
        var userIdStr = User.FindFirstValue(ClaimTypes.NameIdentifier);
        if (!int.TryParse(userIdStr, out var studentId)) return Unauthorized();

        var request = await _context.LeaveRequests
            .FirstOrDefaultAsync(lr => lr.Id == id && lr.StudentId == studentId);

        if (request == null)
            return NotFound(new { message = "Leave request not found." });

        if (request.Status != "Pending")
            return BadRequest(new { message = "Only pending requests can be deleted." });

        _context.LeaveRequests.Remove(request);
        await _context.SaveChangesAsync();

        return NoContent();
    }
}
