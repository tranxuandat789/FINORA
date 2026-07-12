using System.ComponentModel.DataAnnotations;

namespace FinanceAPI.DTOs.Requests
{
    public class AnalyzeVoiceRequest
    {
        [Required(ErrorMessage = "Vui lòng cung cấp nội dung giọng nói.")]
        public string Text { get; set; } = string.Empty;

        public string? Model { get; set; }
    }
}
