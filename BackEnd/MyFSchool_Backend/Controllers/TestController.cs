using Microsoft.AspNetCore.Mvc;
using MyFSchool_Backend.Data;

namespace MyFSchool_Backend.Controllers;

[ApiController]
[Route("api/[controller]")]
public class TestController : ControllerBase
{
    private readonly MyFSchoolDbContext _context;

    public TestController(MyFSchoolDbContext context)
    {
        _context = context;
    }

    [HttpGet("check-db")]
    public IActionResult CheckDatabase()
    {
        try
        {
            var canConnect = _context.Database.CanConnect();
            return Ok(new { 
                Message = "BackEnd is ready for API development!", 
                DatabaseConnected = canConnect 
            });
        }
        catch (Exception ex)
        {
            return Ok(new { 
                Message = "BackEnd is ready, but database connection failed. Check your connection string.", 
                Error = ex.Message 
            });
        }
    }
}
