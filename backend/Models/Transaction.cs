using System;
using FinanceAPI.Models.Enums;

namespace FinanceAPI.Models
{
    public class Transaction
    {
        public Guid Id { get; set; }
        public Guid WalletId { get; set; }
        public Guid CategoryId { get; set; }
        public TransactionType Type { get; set; }
        public decimal Amount { get; set; }
        public string? Note { get; set; }
        public DateTime TransactionDate { get; set; }
        public DateTime CreatedAt { get; set; }
        public bool IsDeleted { get; set; }

        // Navigation properties
        public Wallet Wallet { get; set; } = null!;
        public Category Category { get; set; } = null!;
    }
}
