using System.Net;
using System.Net.Mail;
using Microsoft.Extensions.Configuration;

namespace FinanceAPI.Services
{
    public class EmailService : IEmailService
    {
        private readonly string _smtpHost;
        private readonly int _smtpPort;
        private readonly string _senderEmail;
        private readonly string _senderName;
        private readonly string _appPassword;

        public EmailService(IConfiguration configuration)
        {
            _smtpHost    = configuration["Email:SmtpHost"]    ?? "smtp.gmail.com";
            _smtpPort    = int.Parse(configuration["Email:SmtpPort"] ?? "587");
            _senderEmail = configuration["Email:SenderEmail"] ?? "";
            _senderName  = configuration["Email:SenderName"]  ?? "Finora";
            _appPassword = configuration["Email:AppPassword"] ?? "";
        }

        public async Task SendOtpEmailAsync(string toEmail, string toName, string otp, string purpose)
        {
            var subject = purpose == "forgot_password"
                ? "Finora – Mã xác nhận đặt lại mật khẩu"
                : "Finora – Mã xác nhận đăng ký tài khoản";

            var purposeLabel = purpose == "forgot_password"
                ? "đặt lại mật khẩu"
                : "xác nhận tài khoản";

            var body = $@"
<!DOCTYPE html>
<html lang=""vi"">
<head><meta charset=""UTF-8""></head>
<body style=""font-family: 'Segoe UI', Arial, sans-serif; background:#f4f6fb; margin:0; padding:0;"">
  <table width=""100%"" cellpadding=""0"" cellspacing=""0"" style=""background:#f4f6fb;"">
    <tr>
      <td align=""center"" style=""padding: 40px 0;"">
        <table width=""520"" cellpadding=""0"" cellspacing=""0"" style=""background:#ffffff; border-radius:16px; overflow:hidden; box-shadow:0 2px 12px rgba(0,0,0,0.07);"">
          <!-- Header -->
          <tr>
            <td style=""background:linear-gradient(135deg,#2563EB,#3B82F6); padding:32px 40px; text-align:center;"">
              <h1 style=""color:#fff; margin:0; font-size:26px; font-weight:700; letter-spacing:-0.5px;"">Finora</h1>
              <p style=""color:rgba(255,255,255,0.85); margin:6px 0 0; font-size:13px;"">Quản lý tài chính cá nhân</p>
            </td>
          </tr>
          <!-- Body -->
          <tr>
            <td style=""padding:40px 40px 32px;"">
              <p style=""color:#374151; font-size:15px; margin:0 0 8px;"">Xin chào <strong>{toName}</strong>,</p>
              <p style=""color:#6B7280; font-size:14px; line-height:1.6; margin:0 0 28px;"">
                Chúng tôi nhận được yêu cầu {purposeLabel} của bạn.<br>
                Vui lòng sử dụng mã OTP dưới đây. Mã có hiệu lực trong <strong>5 phút</strong>.
              </p>
              <!-- OTP Box -->
              <div style=""background:#EFF6FF; border:2px dashed #3B82F6; border-radius:12px; padding:24px; text-align:center; margin-bottom:28px;"">
                <p style=""color:#6B7280; font-size:13px; margin:0 0 8px; text-transform:uppercase; letter-spacing:1px;"">Mã xác nhận</p>
                <span style=""font-size:42px; font-weight:800; color:#2563EB; letter-spacing:8px; font-family:monospace;"">{otp}</span>
              </div>
              <p style=""color:#9CA3AF; font-size:13px; line-height:1.5; margin:0;"">
                Nếu bạn không thực hiện yêu cầu này, hãy bỏ qua email này.<br>
                Không chia sẻ mã này với bất kỳ ai.
              </p>
            </td>
          </tr>
          <!-- Footer -->
          <tr>
            <td style=""background:#F9FAFB; padding:20px 40px; border-top:1px solid #E5E7EB; text-align:center;"">
              <p style=""color:#D1D5DB; font-size:12px; margin:0;"">© 2024 Finora. Tất cả quyền được bảo lưu.</p>
            </td>
          </tr>
        </table>
      </td>
    </tr>
  </table>
</body>
</html>";

            using var client = new SmtpClient(_smtpHost, _smtpPort)
            {
                EnableSsl = true,
                Credentials = new NetworkCredential(_senderEmail, _appPassword),
                DeliveryMethod = SmtpDeliveryMethod.Network,
            };

            using var message = new MailMessage
            {
                From       = new MailAddress(_senderEmail, _senderName),
                Subject    = subject,
                Body       = body,
                IsBodyHtml = true,
            };
            message.To.Add(new MailAddress(toEmail, toName));

            await client.SendMailAsync(message);
        }
    }
}
