using System;
using System.Security.Claims;
using System.Threading.Tasks;
using FinanceAPI.DTOs;
using FinanceAPI.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace FinanceAPI.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize]
    public class NotificationSettingsController : ControllerBase
    {
        private readonly INotificationSettingService _settingService;

        public NotificationSettingsController(INotificationSettingService settingService)
        {
            _settingService = settingService;
        }

        // GET: api/NotificationSettings
        [HttpGet]
        public async Task<ActionResult<NotificationSettingDto>> GetSettings()
        {
            try
            {
                var userIdString = User.FindFirstValue(ClaimTypes.NameIdentifier);
                if (string.IsNullOrEmpty(userIdString) || !Guid.TryParse(userIdString, out Guid userId))
                {
                    return Unauthorized("User ID not found in token.");
                }

                var settings = await _settingService.GetSettingsAsync(userId);
                return Ok(settings);
            }
            catch (Exception ex)
            {
                return StatusCode(500, $"Internal server error: {ex.Message}");
            }
        }

        // PUT: api/NotificationSettings
        [HttpPut]
        public async Task<ActionResult<NotificationSettingDto>> UpdateSettings([FromBody] UpdateNotificationSettingDto dto)
        {
            try
            {
                var userIdString = User.FindFirstValue(ClaimTypes.NameIdentifier);
                if (string.IsNullOrEmpty(userIdString) || !Guid.TryParse(userIdString, out Guid userId))
                {
                    return Unauthorized("User ID not found in token.");
                }

                var updatedSettings = await _settingService.UpdateSettingsAsync(userId, dto);
                return Ok(updatedSettings);
            }
            catch (Exception ex)
            {
                return StatusCode(500, $"Internal server error: {ex.Message}");
            }
        }
    }
}
