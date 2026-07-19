using System.ComponentModel.DataAnnotations;

namespace FinanceAPI.DTOs.Auth
{
    public class ChangePinRequest
    {
        [Required]
        public string OldPin { get; set; } = string.Empty;

        [Required]
        [StringLength(6, MinimumLength = 6)]
        public string NewPin { get; set; } = string.Empty;
    }
}
