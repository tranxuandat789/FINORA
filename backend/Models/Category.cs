using System;
using System.Collections.Generic;
using FinanceAPI.Models.Enums;

namespace FinanceAPI.Models
{
    public class Category
    {
        public Guid Id { get; set; }
        public Guid? UserId { get; set; } // Null means system default
        public string Name { get; set; } = string.Empty;
        public TransactionType Type { get; set; }
        public string? Icon { get; set; }
        public bool IsDeleted { get; set; }

        // Navigation properties
        public User? User { get; set; }
        public ICollection<Transaction> Transactions { get; set; } = new List<Transaction>();
        public ICollection<Budget> Budgets { get; set; } = new List<Budget>();
    }
}
