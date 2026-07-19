using System.ComponentModel.DataAnnotations;

namespace FinanceAPI.DTOs.Auth
{
    public class SetupPinRequest
    {
        [Required]
        [StringLength(6, MinimumLength = 6)]
        public string NewPin { get; set; } = string.Empty;
    }
}
