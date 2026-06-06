using System;

namespace FinanceAPI.Models
{
    public class GoalContribution
    {
        public Guid Id { get; set; }
        public Guid GoalId { get; set; }
        public decimal Amount { get; set; }
        public DateTime ContributionDate { get; set; }
        public string? Note { get; set; }
        public bool IsDeleted { get; set; }

        // Navigation properties
        public Goal Goal { get; set; } = null!;
    }
}
