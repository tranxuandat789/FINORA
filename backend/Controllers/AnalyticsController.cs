using System;
using System.Threading.Tasks;
using FinanceAPI.Services.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;

namespace FinanceAPI.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize]
    public class AnalyticsController : ControllerBase
    {
        private readonly IAnalyticsService _analyticsService;

        public AnalyticsController(IAnalyticsService analyticsService)
        {
            _analyticsService = analyticsService;
        }

        [HttpGet("expense")]
        public async Task<IActionResult> GetExpenseAnalytics([FromQuery] int month, [FromQuery] int year)
        {
            var userIdString = User.FindFirstValue(ClaimTypes.NameIdentifier);
            if (string.IsNullOrEmpty(userIdString) || !Guid.TryParse(userIdString, out Guid userId))
            {
                return Unauthorized("Token không hợp lệ.");
            }

            if (month < 1 || month > 12 || year < 2000 || year > 2100)
            {
                return BadRequest("Tháng hoặc năm không hợp lệ.");
            }

            var result = await _analyticsService.GetExpenseAnalyticsAsync(userId, month, year);
            return Ok(result);
        }
    }
}
