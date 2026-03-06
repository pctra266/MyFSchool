using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using MyFSchool_Backend.Data;

namespace MyFSchool_Backend.Controllers;

[Authorize]
[ApiController]
[Route("api/[controller]")]
public class NewsController : ControllerBase
{
    private readonly MyFSchoolDbContext _context;

    public NewsController(MyFSchoolDbContext context)
    {
        _context = context;
    }

    [HttpGet]
    public async Task<IActionResult> GetNews()
    {
        var news = await _context.News
            .OrderByDescending(n => n.CreatedAt)
            .Select(n => new
            {
                n.Id,
                n.Title,
                n.Category,
                n.ImageUrl,
                n.CreatedAt
            })
            .ToListAsync();

        return Ok(news);
    }

    [HttpGet("{id}")]
    public async Task<IActionResult> GetNewsDetails(int id)
    {
        var newsItem = await _context.News
            .Where(n => n.Id == id)
            .Select(n => new
            {
                n.Id,
                n.Title,
                n.Description,
                n.Category,
                n.ImageUrl,
                n.CreatedAt,
                Attachments = n.Attachments
                    .Select(a => new
                    {
                        a.Id,
                        a.FileName,
                        a.FileSize,
                        a.FileUrl
                    })
                    .ToList()
            })
            .FirstOrDefaultAsync();

        if (newsItem == null) return NotFound();

        return Ok(newsItem);
    }
}
