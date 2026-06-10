using System;
using System.ComponentModel.DataAnnotations;

namespace FinanceAPI.DTOs.Requests
{
    public class CreateGoalRequest
    {
        [Required]
        [MaxLength(100)]
        public string Name { get; set; } = string.Empty;

        [Required]
        [Range(1, double.MaxValue, ErrorMessage = "Số tiền mục tiêu phải lớn hơn 0")]
        public decimal TargetAmount { get; set; }

        [Required]
        public DateTime Deadline { get; set; }

        public string? Icon { get; set; }
    }
}
