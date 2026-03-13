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
    private readonly MyFSchool_Backend.Services.IEmailService _emailService;

    public AuthController(MyFSchoolDbContext context, IConfiguration configuration, MyFSchool_Backend.Services.IEmailService emailService)
    {
        _context = context;
        _configuration = configuration;
        _emailService = emailService;
    }

    [HttpPost("login")]
    public async Task<ActionResult<AuthResponseDto>> Login([FromBody] LoginDto loginDto)
    {
        // Validate that at least email or phone number is provided
        if (string.IsNullOrWhiteSpace(loginDto.Email) && string.IsNullOrWhiteSpace(loginDto.PhoneNumber))
            return BadRequest(new { message = "Email or phone number is required" });

        User? user;
        if (!string.IsNullOrWhiteSpace(loginDto.Email))
        {
            user = await _context.Users
                .Include(u => u.UserRoles)
                .ThenInclude(ur => ur.Role)
                .FirstOrDefaultAsync(u => u.Email == loginDto.Email);
        }
        else
        {
            user = await _context.Users
                .Include(u => u.UserRoles)
                .ThenInclude(ur => ur.Role)
                .FirstOrDefaultAsync(u => u.PhoneNumber == loginDto.PhoneNumber);
        }

        // Verify user exists and password is correct using BCrypt
        if (user == null || !BCrypt.Net.BCrypt.Verify(loginDto.Password, user.PasswordHash))
            return Unauthorized(new { message = "Invalid credentials" });

        var tokenHandler = new JwtSecurityTokenHandler();
        var key = Encoding.ASCII.GetBytes(_configuration["Jwt:Key"] ?? "fallback_secret_key_1234567890123456");
        var claims = new List<Claim>
        {
            new Claim(ClaimTypes.NameIdentifier, user.Id.ToString()),
            new Claim(ClaimTypes.Email, user.Email)
        };

        foreach (var userRole in user.UserRoles)
        {
            claims.Add(new Claim(ClaimTypes.Role, userRole.Role.Name));
        }

        var tokenDescriptor = new SecurityTokenDescriptor
        {
            Subject = new ClaimsIdentity(claims),
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
                Roles = user.UserRoles.Select(ur => ur.Role.Name).ToList(),
                FocusArea = user.FocusArea,
                DateOfBirth = user.DateOfBirth,
                Gender = user.Gender,
                Address = user.Address,
                PhoneNumber = user.PhoneNumber,
                ParentName = user.ParentName,
                PushEnabled = user.PushEnabled,
                EmailEnabled = user.EmailEnabled
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
            CreatedAt = DateTime.UtcNow,
            PushEnabled = true,
            EmailEnabled = false
        };

        // Resolve roles
        foreach (var roleName in registerDto.Roles)
        {
            var role = await _context.Roles.FirstOrDefaultAsync(r => r.Name == roleName);
            if (role != null)
            {
                newUser.UserRoles.Add(new UserRole { Role = role });
            }
        }

        _context.Users.Add(newUser);
        await _context.SaveChangesAsync();

        return Ok(new { message = "Registration successful" });
    }

    [HttpPost("forgot-password")]
    public async Task<IActionResult> ForgotPassword([FromBody] ForgotPasswordDto dto)
    {
        // Validate: at least one of email or phoneNumber must be provided
        if (string.IsNullOrWhiteSpace(dto.Email) && string.IsNullOrWhiteSpace(dto.PhoneNumber))
            return BadRequest(new { message = "Email hoặc số điện thoại là bắt buộc" });

        User? user;
        if (!string.IsNullOrWhiteSpace(dto.PhoneNumber))
        {
            user = await _context.Users.FirstOrDefaultAsync(u => u.PhoneNumber == dto.PhoneNumber);
            if (user == null)
                return BadRequest(new { message = "Không tìm thấy tài khoản với số điện thoại này" });
        }
        else
        {
            user = await _context.Users.FirstOrDefaultAsync(u => u.Email == dto.Email);
            if (user == null)
                return BadRequest(new { message = "Không tìm thấy tài khoản với email này" });
        }

        // Generate 6-digit OTP
        Random random = new Random();
        string otp = random.Next(100000, 999999).ToString();

        // Save OTP to user
        user.ResetPasswordOtp = otp;
        user.ResetPasswordExpiry = DateTime.Now.AddMinutes(5);

        await _context.SaveChangesAsync();

        if (!string.IsNullOrWhiteSpace(dto.PhoneNumber))
        {
            // TODO: Integrate real SMS service (Twilio, ESMS.vn, etc.)
            Console.WriteLine($"[SMS Mock] OTP for {dto.PhoneNumber}: {otp}");
            return Ok(new { message = $"Mã OTP đã được gửi đến số điện thoại {dto.PhoneNumber}" });
        }
        else
        {
            // Send OTP via Email
            await _emailService.SendOtpEmailAsync(user.Email, otp);
            return Ok(new { message = "Mã OTP đã được gửi đến email của bạn" });
        }
    }

    [HttpPost("reset-password")]
    public async Task<IActionResult> ResetPassword([FromBody] ResetPasswordDto dto)
    {
        // Validate: at least one of email or phoneNumber must be provided
        if (string.IsNullOrWhiteSpace(dto.Email) && string.IsNullOrWhiteSpace(dto.PhoneNumber))
            return BadRequest(new { message = "Email hoặc số điện thoại là bắt buộc" });

        User? user;
        if (!string.IsNullOrWhiteSpace(dto.PhoneNumber))
        {
            user = await _context.Users.FirstOrDefaultAsync(u => u.PhoneNumber == dto.PhoneNumber);
            if (user == null)
                return BadRequest(new { message = "Không tìm thấy tài khoản với số điện thoại này" });
        }
        else
        {
            user = await _context.Users.FirstOrDefaultAsync(u => u.Email == dto.Email);
            if (user == null)
                return BadRequest(new { message = "Không tìm thấy tài khoản với email này" });
        }

        // Verify OTP (Check expiry first, then value)
        if (user.ResetPasswordExpiry == null || user.ResetPasswordExpiry < DateTime.Now)
            return BadRequest(new { message = "Mã OTP đã hết hạn" });

        if (user.ResetPasswordOtp != dto.Otp)
            return BadRequest(new { message = "Mã OTP không hợp lệ" });

        // OTP is valid. Hash new password
        string newPasswordHash = BCrypt.Net.BCrypt.HashPassword(dto.NewPassword);
        user.PasswordHash = newPasswordHash;

        // Clear OTP fields
        user.ResetPasswordOtp = null;
        user.ResetPasswordExpiry = null;

        await _context.SaveChangesAsync();

        return Ok(new { message = "Mật khẩu đã được đặt lại thành công" });
    }
}
