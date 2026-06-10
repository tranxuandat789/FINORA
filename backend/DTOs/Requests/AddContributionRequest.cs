using System;
using System.ComponentModel.DataAnnotations;

namespace FinanceAPI.DTOs.Requests
{
    public class AddContributionRequest
    {
        [Required]
        [Range(0.01, double.MaxValue, ErrorMessage = "Số tiền phải lớn hơn 0")]
        public decimal Amount { get; set; }

        [MaxLength(200)]
        public string? Note { get; set; }

        public DateTime ContributionDate { get; set; } = DateTime.UtcNow;
    }
}
