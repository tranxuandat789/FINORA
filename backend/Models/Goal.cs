using System;
using System.Collections.Generic;

namespace FinanceAPI.Models
{
    public class Goal
    {
        public Guid Id { get; set; }
        public Guid UserId { get; set; }
        public string Name { get; set; } = string.Empty;
        public decimal TargetAmount { get; set; }
        public decimal CurrentAmount { get; set; }
        public DateTime Deadline { get; set; }
        public string? Icon { get; set; }
        public bool IsDeleted { get; set; }

        // Navigation properties
        public User User { get; set; } = null!;
        public ICollection<GoalContribution> Contributions { get; set; } = new List<GoalContribution>();
    }
}
