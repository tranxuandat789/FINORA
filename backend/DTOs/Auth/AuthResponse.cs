using System;

namespace FinanceAPI.DTOs.Auth
{
    public class AuthResponse
    {
        public Guid Id { get; set; }
        public string FullName { get; set; } = string.Empty;
        public string Email { get; set; } = string.Empty;
        public string? PhoneNumber { get; set; }
        public string? AvatarUrl { get; set; }
        public string Token { get; set; } = string.Empty;
        public bool HasPin { get; set; }      // PIN tồn tại VÀ đang bật
        public bool HasPinHash { get; set; }  // Có PIN hash trong DB (kể cả khi bị tắt)
    }
}
