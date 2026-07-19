using System.ComponentModel.DataAnnotations;

namespace FinanceAPI.DTOs.Auth
{
    public class ResetPinRequest
    {
        [Required]
        [EmailAddress]
        public string Email { get; set; } = string.Empty;

        [Required]
        public string ResetToken { get; set; } = string.Empty;

        [Required]
        [StringLength(6, MinimumLength = 6)]
        public string NewPin { get; set; } = string.Empty;
    }
}
