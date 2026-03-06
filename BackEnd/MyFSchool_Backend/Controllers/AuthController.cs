using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using MyFSchool_Backend.Data;
using MyFSchool_Backend.DTOs;
using MyFSchool_Backend.Models;

namespace MyFSchool_Backend.Controllers;

[ApiController]
[Route("api/[controller]")]
public class AuthController : ControllerBase
{
    private readonly MyFSchoolDbContext _context;
    private readonly IConfiguration _configuration;

    public AuthController(MyFSchoolDbContext context, IConfiguration configuration)
    {
        _context = context;
        _configuration = configuration;
    }

    [HttpPost("login")]
    public async Task<ActionResult<AuthResponseDto>> Login([FromBody] LoginDto loginDto)
    {
        var user = await _context.Users.FirstOrDefaultAsync(u => u.Email == loginDto.Email);
        
        // Verify user exists and password is correct using BCrypt
        if (user == null || !BCrypt.Net.BCrypt.Verify(loginDto.Password, user.PasswordHash))
            return Unauthorized(new { message = "Invalid email or password" });

        var tokenHandler = new JwtSecurityTokenHandler();
        var key = Encoding.ASCII.GetBytes(_configuration["Jwt:Key"] ?? "fallback_secret_key_1234567890123456");
        var tokenDescriptor = new SecurityTokenDescriptor
        {
            Subject = new ClaimsIdentity(new[]
            {
                new Claim(ClaimTypes.NameIdentifier, user.Id.ToString()),
                new Claim(ClaimTypes.Email, user.Email),
                new Claim(ClaimTypes.Role, user.Role)
            }),
            Expires = DateTime.UtcNow.AddDays(7),
            Issuer = _configuration["Jwt:Issuer"],
            Audience = _configuration["Jwt:Audience"],
            SigningCredentials = new SigningCredentials(new SymmetricSecurityKey(key), SecurityAlgorithms.HmacSha256Signature)
        };
        var token = tokenHandler.CreateToken(tokenDescriptor);

        return Ok(new AuthResponseDto
        {
            Token = tokenHandler.WriteToken(token),
            User = new UserProfileDto
            {
                Id = user.Id,
                FullName = user.FullName,
                Email = user.Email,
                Role = user.Role,
                FocusArea = user.FocusArea,
                PushEnabled = user.PushEnabled,
            }
        });
    }

    [HttpPost("register")]
    public async Task<ActionResult> Register([FromBody] RegisterDto registerDto)
    {
        // Check if email already exists
        if (await _context.Users.AnyAsync(u => u.Email == registerDto.Email))
        {
            return BadRequest(new { message = "Email already exists" });
        }

        // Hash the password
        string passwordHash = BCrypt.Net.BCrypt.HashPassword(registerDto.Password);

        // Create new user
        var newUser = new User
        {
            FullName = registerDto.FullName,
            Email = registerDto.Email,
            PasswordHash = passwordHash,
            Role = registerDto.Role,
            CreatedAt = DateTime.UtcNow,
            PushEnabled = true,
            EmailEnabled = false
        };

        _context.Users.Add(newUser);
        await _context.SaveChangesAsync();

        return Ok(new { message = "Registration successful" });
    }
}
