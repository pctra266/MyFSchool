using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using MyFSchool_Backend.Data;
using MyFSchool_Backend.Models;
using System.Collections.Generic;
using System.Threading.Tasks;
using System;
using System.Linq;

namespace MyFSchool_Backend.Controllers;

[Route("api/[controller]")]
[ApiController]
public class MealPlanController : ControllerBase
{
    private readonly MyFSchoolDbContext _context;

    public MealPlanController(MyFSchoolDbContext context)
    {
        _context = context;
    }

    [HttpGet]
    public async Task<ActionResult<IEnumerable<MealPlan>>> GetMealPlans()
    {
        try
        {
            var mealPlans = await _context.MealPlans.ToListAsync();
            
            // Sắp xếp theo thứ trong tuần
            var dayOrder = new Dictionary<string, int>
            {
                { "Monday", 1 }, { "Tuesday", 2 }, { "Wednesday", 3 },
                { "Thursday", 4 }, { "Friday", 5 }, { "Saturday", 6 }, { "Sunday", 7 }
            };

            var ordered = mealPlans.OrderBy(mp => dayOrder.ContainsKey(mp.DayOfWeek) ? dayOrder[mp.DayOfWeek] : 99).ToList();

            return Ok(ordered);
        }
        catch (Exception ex)
        {
            return StatusCode(500, $"Internal server error: {ex.Message}");
        }
    }
}
