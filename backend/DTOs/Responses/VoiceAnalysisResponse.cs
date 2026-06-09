using System;

namespace FinanceAPI.DTOs.Responses
{
    public class VoiceAnalysisResponse
    {
        public decimal? Amount { get; set; }
        public Guid? CategoryId { get; set; }
        public string? CategoryName { get; set; }
        public string? Note { get; set; }
        public DateTime? TransactionDate { get; set; }
    }
}
