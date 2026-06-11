namespace FinanceAPI.Services
{
    public interface IEmailService
    {
        /// <summary>Gửi email OTP đến người dùng</summary>
        Task SendOtpEmailAsync(string toEmail, string toName, string otp, string purpose);
    }
}
