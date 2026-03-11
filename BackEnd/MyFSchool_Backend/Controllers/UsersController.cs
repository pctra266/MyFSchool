using System.Security.Claims;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using MyFSchool_Backend.Data;
using MyFSchool_Backend.DTOs;

namespace MyFSchool_Backend.Controllers;

[Authorize]
[ApiController]
[Route("api/[controller]")]
public class UsersController : ControllerBase
{
    private readonly MyFSchoolDbContext _context;

    public UsersController(MyFSchoolDbContext context)
    {
        _context = context;
    }

    [HttpGet("profile")]
    public async Task<ActionResult<UserProfileDto>> GetProfile()
    {
        var userIdStr = User.FindFirstValue(ClaimTypes.NameIdentifier);
        if (!int.TryParse(userIdStr, out var userId)) return Unauthorized();

        var user = await _context.Users
            .Include(u => u.UserRoles)
            .ThenInclude(ur => ur.Role)
            .FirstOrDefaultAsync(u => u.Id == userId);
            
        if (user == null) return NotFound();

        return Ok(new UserProfileDto
        {
            Id = user.Id,
            FullName = user.FullName,
            Email = user.Email,
            Roles = user.UserRoles.Select(ur => ur.Role.Name).ToList(),
            FocusArea = user.FocusArea,
            DateOfBirth = user.DateOfBirth,
            Gender = user.Gender,
            Address = user.Address,
            PhoneNumber = user.PhoneNumber,
            ParentName = user.ParentName,
            PushEnabled = user.PushEnabled,
            EmailEnabled = user.EmailEnabled
        });
    }

    [HttpPut("profile")]
    public async Task<IActionResult> UpdateProfile([FromBody] UserProfileDto dto)
    {
        var userIdStr = User.FindFirstValue(ClaimTypes.NameIdentifier);
        if (!int.TryParse(userIdStr, out var userId)) return Unauthorized();

        var user = await _context.Users.FindAsync(userId);
        if (user == null) return NotFound();

        // Update changeable fields
        user.PushEnabled = dto.PushEnabled;
        user.EmailEnabled = dto.EmailEnabled;
        // Email and FullName may be read-only depending on school policy, but updating for now
        user.Email = dto.Email; 
        
        await _context.SaveChangesAsync();

        return NoContent();
    }
}
