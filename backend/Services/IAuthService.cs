using System.Threading.Tasks;
using FinanceAPI.DTOs.Auth;
using FinanceAPI.Models;

namespace FinanceAPI.Services
{
    public interface IAuthService
    {
        Task<User> RegisterAsync(RegisterRequest request);
        Task<User> LoginAsync(LoginRequest request);
        Task<User> GoogleLoginAsync(GoogleLoginRequest request);

        Task<string> SendOtpAsync(string email, string purpose);

        /// <summary>Xác minh OTP. Trả về token tạm thời nếu hợp lệ (dùng cho reset password)</summary>
        Task<string> VerifyOtpAsync(string email, string otp, string purpose);

        /// <summary>Đặt lại mật khẩu sau khi xác minh OTP</summary>
        Task ResetPasswordAsync(ResetPasswordRequest request);

        Task SetupPinAsync(Guid userId, SetupPinRequest request);
        Task ChangePinAsync(Guid userId, ChangePinRequest request);
        Task VerifyPinAsync(Guid userId, VerifyPinRequest request);
        Task RemovePinAsync(Guid userId, VerifyPinRequest request);   // Vô hiệu hóa PIN (giữ hash)
        Task EnablePinAsync(Guid userId, EnablePinRequest request);    // Kích hoạt lại PIN (xác minh hash)
        Task ResetPinAsync(ResetPinRequest request);
    }
}
