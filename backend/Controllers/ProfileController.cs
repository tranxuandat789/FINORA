using System;
using System.Security.Claims;
using System.Threading.Tasks;
using FinanceAPI.DTOs.Common;
using FinanceAPI.DTOs.Profile;
using FinanceAPI.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace FinanceAPI.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize]
    public class ProfileController : ControllerBase
    {
        private readonly IProfileService _profileService;

        public ProfileController(IProfileService profileService)
        {
            _profileService = profileService;
        }

        private Guid GetCurrentUserId()
        {
            var idStr = User.FindFirstValue(ClaimTypes.NameIdentifier);
            return Guid.Parse(idStr!);
        }

        // ─── GET /api/profile ────────────────────────────────────────────────────

        [HttpGet]
        public async Task<IActionResult> GetProfile()
        {
            try
            {
                var profile = await _profileService.GetProfileAsync(GetCurrentUserId());
                return Ok(ApiResponse<ProfileResponse>.Ok(profile, "Lấy thông tin thành công"));
            }
            catch (Exception ex)
            {
                return BadRequest(ApiResponse<object>.Fail(ex.Message));
            }
        }

        // ─── PUT /api/profile ────────────────────────────────────────────────────

        [HttpPut]
        public async Task<IActionResult> UpdateProfile([FromBody] UpdateProfileRequest request)
        {
            if (!ModelState.IsValid)
                return BadRequest(ApiResponse<object>.Fail("Dữ liệu không hợp lệ"));

            try
            {
                var profile = await _profileService.UpdateProfileAsync(GetCurrentUserId(), request);
                return Ok(ApiResponse<ProfileResponse>.Ok(profile, "Cập nhật thông tin thành công"));
            }
            catch (Exception ex)
            {
                return BadRequest(ApiResponse<object>.Fail(ex.Message));
            }
        }

        // ─── POST /api/profile/avatar ────────────────────────────────────────────

        [HttpPost("avatar")]
        [Consumes("multipart/form-data")]
        public async Task<IActionResult> UploadAvatar(IFormFile file)
        {
            if (file == null || file.Length == 0)
                return BadRequest(ApiResponse<object>.Fail("Vui lòng chọn file ảnh"));

            try
            {
                var avatarUrl = await _profileService.UploadAvatarAsync(GetCurrentUserId(), file);
                return Ok(ApiResponse<object>.Ok(new { avatarUrl }, "Cập nhật ảnh đại diện thành công"));
            }
            catch (Exception ex)
            {
                return BadRequest(ApiResponse<object>.Fail(ex.Message));
            }
        }

        // ─── PUT /api/profile/change-password ────────────────────────────────────

        [HttpPut("change-password")]
        public async Task<IActionResult> ChangePassword([FromBody] ChangePasswordRequest request)
        {
            if (!ModelState.IsValid)
                return BadRequest(ApiResponse<object>.Fail("Dữ liệu không hợp lệ"));

            try
            {
                await _profileService.ChangePasswordAsync(GetCurrentUserId(), request);
                return Ok(ApiResponse<object>.Ok(new { }, "Cập nhật mật khẩu thành công"));
            }
            catch (Exception ex)
            {
                return BadRequest(ApiResponse<object>.Fail(ex.Message));
            }
        }
    }
}
