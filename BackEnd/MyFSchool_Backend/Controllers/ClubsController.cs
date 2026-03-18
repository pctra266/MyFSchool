using System.Security.Claims;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using MyFSchool_Backend.Data;
using MyFSchool_Backend.DTOs;
using MyFSchool_Backend.Models;

namespace MyFSchool_Backend.Controllers;

[Authorize]
[ApiController]
[Route("api/[controller]")]
public class ClubsController : ControllerBase
{
    private readonly MyFSchoolDbContext _context;

    public ClubsController(MyFSchoolDbContext context)
    {
        _context = context;
    }

    [HttpGet]
    public async Task<ActionResult<IEnumerable<ClubDto>>> GetClubs()
    {
        var clubs = await _context.Clubs.ToListAsync();
        return Ok(clubs.Select(c => new ClubDto
        {
            Id = c.Id,
            Name = c.Name,
            Description = c.Description,
            AvatarUrl = c.AvatarUrl,
            EstablishedDate = c.EstablishedDate,
            CreatedAt = c.CreatedAt
        }));
    }

    [HttpGet("{id}")]
    public async Task<ActionResult> GetClub(int id)
    {
        var club = await _context.Clubs
            .Include(c => c.Members).ThenInclude(m => m.Student)
            .Include(c => c.Events)
            .FirstOrDefaultAsync(c => c.Id == id);

        if (club == null) return NotFound();

        return Ok(new
        {
            club.Id,
            club.Name,
            club.Description,
            club.AvatarUrl,
            club.EstablishedDate,
            club.CreatedAt,
            Members = club.Members.Select(m => new ClubMemberDto
            {
                Id = m.Id,
                ClubId = m.ClubId,
                StudentId = m.StudentId,
                StudentName = m.Student.FullName,
                Role = m.Role,
                JoinedDate = m.JoinedDate
            }),
            Events = club.Events.Select(e => new ClubEventDto
            {
                Id = e.Id,
                ClubId = e.ClubId,
                Title = e.Title,
                Description = e.Description,
                EventDate = e.EventDate,
                CreatedAt = e.CreatedAt
            })
        });
    }

    [HttpPost("{id}/join")]
    public async Task<IActionResult> JoinClub(int id)
    {
        var userIdStr = User.FindFirstValue(ClaimTypes.NameIdentifier);
        if (!int.TryParse(userIdStr, out var userId)) return Unauthorized();

        var club = await _context.Clubs.FindAsync(id);
        if (club == null) return NotFound("Club not found");

        var existingMember = await _context.ClubMembers.FirstOrDefaultAsync(m => m.ClubId == id && m.StudentId == userId);
        if (existingMember != null) return BadRequest(new { message = "Already a member" });

        var member = new ClubMember
        {
            ClubId = id,
            StudentId = userId,
            Role = "Member",
            JoinedDate = DateTime.Now
        };

        _context.ClubMembers.Add(member);
        await _context.SaveChangesAsync();
        return Ok(new { message = "Joined club successfully" });
    }

    private async Task<bool> IsLeader(int clubId, int userId)
    {
        var member = await _context.ClubMembers.FirstOrDefaultAsync(m => m.ClubId == clubId && m.StudentId == userId && m.Role == "Leader");
        return member != null;
    }

    [HttpPut("{id}")]
    public async Task<IActionResult> UpdateClub(int id, [FromBody] UpdateClubDto dto)
    {
        var userIdStr = User.FindFirstValue(ClaimTypes.NameIdentifier);
        if (!int.TryParse(userIdStr, out var userId)) return Unauthorized();

        if (!await IsLeader(id, userId)) return StatusCode(403, new { message = "Only leaders can update club info" });

        var club = await _context.Clubs.FindAsync(id);
        if (club == null) return NotFound();

        if (dto.Description != null) club.Description = dto.Description;
        if (dto.AvatarUrl != null) club.AvatarUrl = dto.AvatarUrl;

        await _context.SaveChangesAsync();
        return NoContent();
    }

    [HttpPost("{id}/members/{studentId}")]
    public async Task<IActionResult> ManageMember(int id, int studentId, [FromBody] ManageClubMemberDto dto)
    {
        var userIdStr = User.FindFirstValue(ClaimTypes.NameIdentifier);
        if (!int.TryParse(userIdStr, out var userId)) return Unauthorized();

        if (!await IsLeader(id, userId)) return StatusCode(403, new { message = "Only leaders can manage members" });

        var member = await _context.ClubMembers.FirstOrDefaultAsync(m => m.ClubId == id && m.StudentId == studentId);
        if (member == null) return NotFound(new { message = "Member not found in this club" });

        if (dto.Action == "Kick")
        {
            _context.ClubMembers.Remove(member);
        }
        else if (dto.Action == "Promote")
        {
            member.Role = "Leader";
        }
        else if (dto.Action == "Demote")
        {
            if (studentId == userId) return BadRequest(new { message = "Cannot demote yourself directly." });
            member.Role = "Member";
        }
        else
        {
            return BadRequest(new { message = "Invalid action. Use Kick, Promote, Demote." });
        }

        await _context.SaveChangesAsync();
        return Ok(new { message = "Member updated successfully" });
    }

    [HttpPost("{id}/events")]
    public async Task<IActionResult> CreateEvent(int id, [FromBody] CreateClubEventDto dto)
    {
        var userIdStr = User.FindFirstValue(ClaimTypes.NameIdentifier);
        if (!int.TryParse(userIdStr, out var userId)) return Unauthorized();

        if (!await IsLeader(id, userId)) return StatusCode(403, new { message = "Only leaders can create events" });

        var club = await _context.Clubs.FindAsync(id);
        if (club == null) return NotFound();

        var ev = new ClubEvent
        {
            ClubId = id,
            Title = dto.Title,
            Description = dto.Description,
            EventDate = dto.EventDate,
            CreatedAt = DateTime.Now
        };

        _context.ClubEvents.Add(ev);
        await _context.SaveChangesAsync();
        
        return Ok(new ClubEventDto
        {
            Id = ev.Id,
            ClubId = ev.ClubId,
            Title = ev.Title,
            Description = ev.Description,
            EventDate = ev.EventDate,
            CreatedAt = ev.CreatedAt
        });
    }

    [HttpPut("{id}/events/{eventId}")]
    public async Task<IActionResult> UpdateEvent(int id, int eventId, [FromBody] UpdateClubEventDto dto)
    {
        var userIdStr = User.FindFirstValue(ClaimTypes.NameIdentifier);
        if (!int.TryParse(userIdStr, out var userId)) return Unauthorized();

        if (!await IsLeader(id, userId)) return StatusCode(403, new { message = "Only leaders can update events" });

        var ev = await _context.ClubEvents.FirstOrDefaultAsync(e => e.Id == eventId && e.ClubId == id);
        if (ev == null) return NotFound();

        if (dto.Title != null) ev.Title = dto.Title;
        if (dto.Description != null) ev.Description = dto.Description;
        if (dto.EventDate.HasValue) ev.EventDate = dto.EventDate;

        await _context.SaveChangesAsync();
        return NoContent();
    }

    [HttpDelete("{id}/events/{eventId}")]
    public async Task<IActionResult> DeleteEvent(int id, int eventId)
    {
        var userIdStr = User.FindFirstValue(ClaimTypes.NameIdentifier);
        if (!int.TryParse(userIdStr, out var userId)) return Unauthorized();

        if (!await IsLeader(id, userId)) return StatusCode(403, new { message = "Only leaders can delete events" });

        var ev = await _context.ClubEvents.FirstOrDefaultAsync(e => e.Id == eventId && e.ClubId == id);
        if (ev == null) return NotFound();

        _context.ClubEvents.Remove(ev);
        await _context.SaveChangesAsync();
        return NoContent();
    }
}
