using System.ComponentModel.DataAnnotations;

namespace FinanceAPI.DTOs.Auth
{
    public class EnablePinRequest
    {
        [Required]
        public string Pin { get; set; } = string.Empty;
    }
}
