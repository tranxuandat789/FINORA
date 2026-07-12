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

        [HttpGet("overview")]
        public async Task<IActionResult> GetAnalytics([FromQuery] string mode, [FromQuery] int? month, [FromQuery] int year)
        {
            var userIdString = User.FindFirstValue(ClaimTypes.NameIdentifier);
            if (string.IsNullOrEmpty(userIdString) || !Guid.TryParse(userIdString, out Guid userId))
            {
                return Unauthorized("Token không hợp lệ.");
            }

            if (mode != "month" && mode != "year")
            {
                return BadRequest("Chế độ không hợp lệ.");
            }

            if (mode == "month" && (month == null || month < 1 || month > 12))
            {
                return BadRequest("Tháng không hợp lệ.");
            }

            if (year < 2000 || year > 2100)
            {
                return BadRequest("Năm không hợp lệ.");
            }

            var result = await _analyticsService.GetAnalyticsAsync(userId, mode, month, year);
            return Ok(result);
        }
    }
}
