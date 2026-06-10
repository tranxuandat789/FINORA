using System;
using System.Security.Claims;
using System.Threading.Tasks;
using FinanceAPI.Models.DTOs;
using FinanceAPI.Services.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace FinanceAPI.Controllers
{
    [Authorize]
    [ApiController]
    [Route("api/[controller]")]
    public class BudgetsController : ControllerBase
    {
        private readonly IBudgetService _budgetService;

        public BudgetsController(IBudgetService budgetService)
        {
            _budgetService = budgetService;
        }

        private Guid GetUserId()
        {
            var userIdString = User.FindFirstValue(ClaimTypes.NameIdentifier);
            if (string.IsNullOrEmpty(userIdString) || !Guid.TryParse(userIdString, out Guid userId))
            {
                throw new UnauthorizedAccessException("Người dùng chưa đăng nhập hợp lệ.");
            }
            return userId;
        }

        [HttpGet("progress")]
        public async Task<IActionResult> GetProgress([FromQuery] int month, [FromQuery] int year)
        {
            try
            {
                if (month == 0) month = DateTime.UtcNow.Month;
                if (year == 0) year = DateTime.UtcNow.Year;

                var userId = GetUserId();
                var result = await _budgetService.GetMonthlyProgressAsync(userId, month, year);
                return Ok(new { success = true, data = result });
            }
            catch (Exception ex)
            {
                return BadRequest(new { success = false, message = ex.Message });
            }
        }

        [HttpPost("category/{categoryId}")]
        public async Task<IActionResult> UpsertCategoryBudget(Guid categoryId, [FromBody] BudgetUpsertRequest request)
        {
            try
            {
                var userId = GetUserId();
                await _budgetService.UpsertCategoryBudgetAsync(userId, categoryId, request.Amount);
                return Ok(new { success = true, message = "Cập nhật ngân sách thành công" });
            }
            catch (Exception ex)
            {
                return BadRequest(new { success = false, message = ex.Message });
            }
        }
    }
}
