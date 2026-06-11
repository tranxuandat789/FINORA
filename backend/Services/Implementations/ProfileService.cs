using System;
using System.Text.RegularExpressions;
using System.Threading.Tasks;
using FinanceAPI.Data;
using FinanceAPI.DTOs.Profile;
using FinanceAPI.Models;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using FinanceAPI.Services;

namespace FinanceAPI.Services.Implementations
{
    public class ProfileService : IProfileService
    {
        private readonly AppDbContext _context;
        private readonly IPasswordHasher<User> _passwordHasher;
        private readonly ICloudinaryService _cloudinaryService;

        public ProfileService(
            AppDbContext context,
            IPasswordHasher<User> passwordHasher,
            ICloudinaryService cloudinaryService)
        {
            _context = context;
            _passwordHasher = passwordHasher;
            _cloudinaryService = cloudinaryService;
        }

        // ─── GET PROFILE ─────────────────────────────────────────────────────────

        public async Task<ProfileResponse> GetProfileAsync(Guid userId)
        {
            var user = await _context.Users
                .FirstOrDefaultAsync(u => u.Id == userId && !u.IsDeleted)
                ?? throw new Exception("Không tìm thấy tài khoản");

            return MapToResponse(user);
        }

        // ─── UPDATE PROFILE ───────────────────────────────────────────────────────

        public async Task<ProfileResponse> UpdateProfileAsync(Guid userId, UpdateProfileRequest request)
        {
            var user = await _context.Users
                .FirstOrDefaultAsync(u => u.Id == userId && !u.IsDeleted)
                ?? throw new Exception("Không tìm thấy tài khoản");

            // Validate số điện thoại Việt Nam
            if (!string.IsNullOrWhiteSpace(request.PhoneNumber))
            {
                var phoneRegex = new Regex(@"^(0[3|5|7|8|9])+([0-9]{8})$");
                if (!phoneRegex.IsMatch(request.PhoneNumber))
                    throw new Exception("Số điện thoại không hợp lệ");
            }

            user.FullName = request.FullName.Trim();
            user.PhoneNumber = string.IsNullOrWhiteSpace(request.PhoneNumber)
                ? null
                : request.PhoneNumber.Trim();

            await _context.SaveChangesAsync();
            return MapToResponse(user);
        }

        // ─── CHANGE PASSWORD ──────────────────────────────────────────────────────

        public async Task ChangePasswordAsync(Guid userId, ChangePasswordRequest request)
        {
            var user = await _context.Users
                .FirstOrDefaultAsync(u => u.Id == userId && !u.IsDeleted)
                ?? throw new Exception("Không tìm thấy tài khoản");

            // Validate độ phức tạp mật khẩu mới
            if (!Regex.IsMatch(request.NewPassword, @"[A-Z]"))
                throw new Exception("Mật khẩu phải chứa ít nhất 1 chữ viết hoa");
            if (!Regex.IsMatch(request.NewPassword, @"[^a-zA-Z0-9]"))
                throw new Exception("Mật khẩu phải chứa ít nhất 1 ký tự đặc biệt");

            // Xác thực mật khẩu hiện tại (skip nếu Google user chưa có pass thật)
            bool isGoogleUserWithRandomPass = string.IsNullOrEmpty(request.CurrentPassword);

            if (!isGoogleUserWithRandomPass)
            {
                var verifyResult = _passwordHasher.VerifyHashedPassword(
                    user, user.PasswordHash, request.CurrentPassword!);

                if (verifyResult == PasswordVerificationResult.Failed)
                    throw new Exception("Mật khẩu hiện tại không đúng");
            }

            // Mật khẩu mới không được trùng mật khẩu cũ
            var newSameAsOld = _passwordHasher.VerifyHashedPassword(
                user, user.PasswordHash, request.NewPassword);
            if (newSameAsOld != PasswordVerificationResult.Failed)
                throw new Exception("Mật khẩu mới không được trùng với mật khẩu hiện tại");

            user.PasswordHash = _passwordHasher.HashPassword(user, request.NewPassword);
            await _context.SaveChangesAsync();
        }

        // ─── UPLOAD AVATAR ────────────────────────────────────────────────────────

        public async Task<string> UploadAvatarAsync(Guid userId, IFormFile file)
        {
            var user = await _context.Users
                .FirstOrDefaultAsync(u => u.Id == userId && !u.IsDeleted)
                ?? throw new Exception("Không tìm thấy tài khoản");

            // Validate file
            var allowedTypes = new[] { "image/jpeg", "image/png", "image/webp", "image/jpg" };
            if (!Array.Exists(allowedTypes, t => t == file.ContentType?.ToLower()))
                throw new Exception("Chỉ chấp nhận file ảnh JPG, PNG hoặc WebP");

            const long maxSize = 5 * 1024 * 1024; // 5MB
            if (file.Length > maxSize)
                throw new Exception("Kích thước ảnh không được vượt quá 5MB");

            var avatarUrl = await _cloudinaryService.UploadImageAsync(file);

            user.AvatarUrl = avatarUrl;
            await _context.SaveChangesAsync();

            return avatarUrl;
        }

        // ─── HELPERS ──────────────────────────────────────────────────────────────

        private static ProfileResponse MapToResponse(User user) => new()
        {
            Id = user.Id,
            FullName = user.FullName,
            Email = user.Email,
            PhoneNumber = user.PhoneNumber,
            AvatarUrl = user.AvatarUrl,
            CreatedAt = user.CreatedAt
        };
    }
}
