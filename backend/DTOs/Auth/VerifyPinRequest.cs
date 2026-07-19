using System.ComponentModel.DataAnnotations;

namespace FinanceAPI.DTOs.Auth
{
    public class VerifyPinRequest
    {
        [Required]
        public string Pin { get; set; } = string.Empty;
    }
}
