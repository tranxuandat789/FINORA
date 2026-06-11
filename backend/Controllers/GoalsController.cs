using System;
using System.Security.Claims;
using System.Threading.Tasks;
using FinanceAPI.DTOs.Requests;
using FinanceAPI.Services.Interfaces;
using FinanceAPI.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace FinanceAPI.Controllers
{
    [Authorize]
    [ApiController]
    [Route("api/[controller]")]
    public class GoalsController : ControllerBase
    {
        private readonly IGoalService _goalService;
        private readonly ICloudinaryService _cloudinaryService;

        public GoalsController(IGoalService goalService, ICloudinaryService cloudinaryService)
        {
            _goalService = goalService;
            _cloudinaryService = cloudinaryService;
        }

        private Guid GetUserId()
        {
            var userIdStr = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            if (string.IsNullOrEmpty(userIdStr) || !Guid.TryParse(userIdStr, out var userId))
            {
                throw new UnauthorizedAccessException("Người dùng không hợp lệ.");
            }
            return userId;
        }

        [HttpGet]
        public async Task<IActionResult> GetGoals()
        {
            try
            {
                var userId = GetUserId();
                var goals = await _goalService.GetGoalsAsync(userId);
                return Ok(goals);
            }
            catch (Exception ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }

        [HttpGet("{id}")]
        public async Task<IActionResult> GetGoalDetail(Guid id)
        {
            try
            {
                var userId = GetUserId();
                var goalDetail = await _goalService.GetGoalDetailAsync(id, userId);
                return Ok(goalDetail);
            }
            catch (Exception ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }

        [HttpPost]
        public async Task<IActionResult> CreateGoal([FromBody] CreateGoalRequest request)
        {
            try
            {
                var userId = GetUserId();
                var goal = await _goalService.CreateGoalAsync(request, userId);
                return Ok(goal);
            }
            catch (Exception ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }

        [HttpPut("{id}")]
        public async Task<IActionResult> UpdateGoal(Guid id, [FromBody] UpdateGoalRequest request)
        {
            try
            {
                var userId = GetUserId();
                var goal = await _goalService.UpdateGoalAsync(id, request, userId);
                return Ok(goal);
            }
            catch (Exception ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }

        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteGoal(Guid id)
        {
            try
            {
                var userId = GetUserId();
                await _goalService.DeleteGoalAsync(id, userId);
                return Ok(new { message = "Xóa mục tiêu thành công." });
            }
            catch (Exception ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }

        [HttpPost("{id}/contributions")]
        public async Task<IActionResult> AddContribution(Guid id, [FromBody] AddContributionRequest request)
        {
            try
            {
                var userId = GetUserId();
                var goal = await _goalService.AddContributionAsync(id, request, userId);
                return Ok(goal);
            }
            catch (Exception ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }

        [HttpPost("{id}/withdraw")]
        public async Task<IActionResult> Withdraw(Guid id, [FromBody] AddContributionRequest request)
        {
            try
            {
                var userId = GetUserId();
                var goal = await _goalService.WithdrawAsync(id, request, userId);
                return Ok(goal);
            }
            catch (Exception ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }

        [HttpPost("upload-image")]
        [Consumes("multipart/form-data")]
        public async Task<IActionResult> UploadImage(Microsoft.AspNetCore.Http.IFormFile file)
        {
            if (file == null || file.Length == 0)
                return BadRequest(new { message = "Vui lòng chọn file ảnh" });

            try
            {
                var imageUrl = await _cloudinaryService.UploadImageAsync(file, "finora/goals");
                return Ok(new { imageUrl });
            }
            catch (Exception ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }
    }
}
