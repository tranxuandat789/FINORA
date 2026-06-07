using System;
using System.Collections.Generic;
using System.Security.Claims;
using System.Threading.Tasks;
using FinanceAPI.DTOs.Auth;
using FinanceAPI.DTOs.Common;
using FinanceAPI.Models;
using FinanceAPI.Services;
using Microsoft.AspNetCore.Authentication;
using Microsoft.AspNetCore.Authentication.Cookies;
using Microsoft.AspNetCore.Mvc;

namespace FinanceAPI.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class AuthController : ControllerBase
    {
        private readonly IAuthService _authService;

        public AuthController(IAuthService authService)
        {
            _authService = authService;
        }

        private async Task SignInUserAsync(User user)
        {
            var claims = new List<Claim>
            {
                new Claim(ClaimTypes.NameIdentifier, user.Id.ToString()),
                new Claim(ClaimTypes.Email, user.Email),
                new Claim(ClaimTypes.Name, user.FullName)
            };

            var claimsIdentity = new ClaimsIdentity(claims, CookieAuthenticationDefaults.AuthenticationScheme);

            var authProperties = new AuthenticationProperties
            {
                IsPersistent = true,
                AllowRefresh = true,
                IssuedUtc = DateTimeOffset.UtcNow,
                ExpiresUtc = DateTimeOffset.UtcNow.AddDays(30)
            };

            await HttpContext.SignInAsync(
                CookieAuthenticationDefaults.AuthenticationScheme,
                new ClaimsPrincipal(claimsIdentity),
                authProperties);
        }

        private AuthResponse MapToResponse(User user)
        {
            return new AuthResponse
            {
                Id = user.Id,
                FullName = user.FullName,
                Email = user.Email
            };
        }

        [HttpPost("register")]
        public async Task<IActionResult> Register([FromBody] RegisterRequest request)
        {
            if (!ModelState.IsValid)
            {
                return BadRequest(ApiResponse<object>.Fail("Dữ liệu không hợp lệ."));
            }

            try
            {
                var user = await _authService.RegisterAsync(request);
                await SignInUserAsync(user);
                
                return Ok(ApiResponse<AuthResponse>.Ok(MapToResponse(user), "Đăng ký thành công"));
            }
            catch (Exception ex)
            {
                return BadRequest(ApiResponse<object>.Fail(ex.Message));
            }
        }

        [HttpPost("login")]
        public async Task<IActionResult> Login([FromBody] LoginRequest request)
        {
            if (!ModelState.IsValid)
            {
                return BadRequest(ApiResponse<object>.Fail("Dữ liệu không hợp lệ."));
            }

            try
            {
                var user = await _authService.LoginAsync(request);
                await SignInUserAsync(user);
                
                return Ok(ApiResponse<AuthResponse>.Ok(MapToResponse(user), "Đăng nhập thành công"));
            }
            catch (Exception ex)
            {
                return Unauthorized(ApiResponse<object>.Fail(ex.Message));
            }
        }

        [HttpPost("google-login")]
        public async Task<IActionResult> GoogleLogin([FromBody] GoogleLoginRequest request)
        {
            if (!ModelState.IsValid)
            {
                return BadRequest(ApiResponse<object>.Fail("Dữ liệu không hợp lệ."));
            }

            try
            {
                var user = await _authService.GoogleLoginAsync(request);
                await SignInUserAsync(user);
                
                return Ok(ApiResponse<AuthResponse>.Ok(MapToResponse(user), "Đăng nhập Google thành công"));
            }
            catch (Exception ex)
            {
                return Unauthorized(ApiResponse<object>.Fail(ex.Message));
            }
        }

        [HttpPost("logout")]
        public async Task<IActionResult> Logout()
        {
            await HttpContext.SignOutAsync(CookieAuthenticationDefaults.AuthenticationScheme);
            return Ok(ApiResponse<object>.Ok(new {}, "Đăng xuất thành công"));
        }
    }
}
