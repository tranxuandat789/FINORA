using System;
using System.Collections.Generic;
using FinanceAPI.Models.Enums;

namespace FinanceAPI.Models
{
    public class Wallet
    {
        public Guid Id { get; set; }
        public Guid UserId { get; set; }
        public string Name { get; set; } = string.Empty;
        public WalletType Type { get; set; }
        public decimal Balance { get; set; }
        public string? Icon { get; set; }
        public DateTime CreatedAt { get; set; }
        public bool IsDeleted { get; set; }

        // Navigation properties
        public User User { get; set; } = null!;
        public ICollection<Transaction> Transactions { get; set; } = new List<Transaction>();
    }
}
