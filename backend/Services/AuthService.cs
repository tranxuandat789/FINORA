using System;
using System.Threading.Tasks;
using FinanceAPI.Data;
using FinanceAPI.DTOs.Auth;
using FinanceAPI.Models;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using Google.Apis.Auth;
using Microsoft.Extensions.Configuration;

namespace FinanceAPI.Services
{
    public class AuthService : IAuthService
    {
        private readonly AppDbContext _context;
        private readonly IPasswordHasher<User> _passwordHasher;
        private readonly IConfiguration _configuration;

        public AuthService(AppDbContext context, IPasswordHasher<User> passwordHasher, IConfiguration configuration)
        {
            _context = context;
            _passwordHasher = passwordHasher;
            _configuration = configuration;
        }

        public async Task<User> RegisterAsync(RegisterRequest request)
        {
            // Check if email already exists
            var existingUser = await _context.Users.FirstOrDefaultAsync(u => u.Email == request.Email);
            if (existingUser != null)
            {
                throw new Exception("Email đã được sử dụng."); // Will be caught by global error handler
            }

            var newUser = new User
            {
                Id = Guid.NewGuid(),
                FullName = request.FullName.Trim(),
                Email = request.Email.Trim(),
                CreatedAt = DateTime.UtcNow,
                IsDeleted = false
            };

            newUser.PasswordHash = _passwordHasher.HashPassword(newUser, request.Password);

            _context.Users.Add(newUser);
            await _context.SaveChangesAsync();

            return newUser;
        }

        public async Task<User> LoginAsync(LoginRequest request)
        {
            var user = await _context.Users.FirstOrDefaultAsync(u => u.Email == request.Email && !u.IsDeleted);
            if (user == null)
            {
                throw new Exception("Email hoặc mật khẩu không chính xác.");
            }

            var verificationResult = _passwordHasher.VerifyHashedPassword(user, user.PasswordHash, request.Password);
            if (verificationResult == PasswordVerificationResult.Failed)
            {
                throw new Exception("Email hoặc mật khẩu không chính xác.");
            }

            return user;
        }

        public async Task<User> GoogleLoginAsync(GoogleLoginRequest request)
        {
            GoogleJsonWebSignature.Payload payload;
            try
            {
                var settings = new GoogleJsonWebSignature.ValidationSettings
                {
                    Audience = new[] { _configuration["Authentication:Google:ClientId"] }
                };
                payload = await GoogleJsonWebSignature.ValidateAsync(request.IdToken, settings);
            }
            catch (InvalidJwtException)
            {
                throw new Exception("Google Token không hợp lệ.");
            }

            var user = await _context.Users.FirstOrDefaultAsync(u => u.Email == payload.Email && !u.IsDeleted);
            
            if (user == null)
            {
                // User does not exist, create automatically
                user = new User
                {
                    Id = Guid.NewGuid(),
                    FullName = payload.Name,
                    Email = payload.Email,
                    CreatedAt = DateTime.UtcNow,
                    IsDeleted = false
                };

                // Generate a strong random password for Google-authenticated users
                var randomPassword = Guid.NewGuid().ToString() + "A1!";
                user.PasswordHash = _passwordHasher.HashPassword(user, randomPassword);

                _context.Users.Add(user);
                await _context.SaveChangesAsync();
            }

            return user;
        }
    }
}
