using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using MyFSchool_Backend.Data;
using MyFSchool_Backend.Models;

namespace MyFSchool_Backend.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class HealthRecordsController : ControllerBase
    {
        private readonly MyFSchoolDbContext _context;

        public HealthRecordsController(MyFSchoolDbContext context)
        {
            _context = context;
        }

        // GET: api/HealthRecords/Student/5
        [HttpGet("Student/{studentId}")]
        public async Task<ActionResult<IEnumerable<HealthRecord>>> GetHealthRecordsByStudent(int studentId)
        {
            var records = await _context.HealthRecords
                .Where(h => h.StudentId == studentId)
                .OrderByDescending(h => h.RecordDate)
                .ToListAsync();

            if (records == null || !records.Any())
            {
                return NotFound($"No health records found for student ID {studentId}");
            }

            return Ok(records);
        }
    }
}
