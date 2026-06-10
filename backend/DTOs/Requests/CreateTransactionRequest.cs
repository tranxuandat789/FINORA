using System;
using System.ComponentModel.DataAnnotations;
using FinanceAPI.Models.Enums;

namespace FinanceAPI.DTOs.Requests
{
    public class CreateTransactionRequest
    {
        public Guid WalletId { get; set; }

        [Required]
        public Guid CategoryId { get; set; }

        [Required]
        public TransactionType Type { get; set; }

        [Required]
        [Range(0.01, double.MaxValue, ErrorMessage = "Số tiền phải lớn hơn 0")]
        public decimal Amount { get; set; }

        public string? Note { get; set; }

        [Required]
        public DateTime TransactionDate { get; set; }
    }
}
