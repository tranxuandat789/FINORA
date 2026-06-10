using System;

namespace FinanceAPI.DTOs.Responses
{
    public class GoalResponse
    {
        public Guid Id { get; set; }
        public string Name { get; set; } = string.Empty;
        public string? Icon { get; set; }
        public decimal TargetAmount { get; set; }
        public decimal CurrentAmount { get; set; }
        public decimal Progress { get; set; }
        public bool IsCompleted { get; set; }
        public DateTime Deadline { get; set; }
        public int DaysLeft { get; set; }
        public DateTime CreatedAt { get; set; }
    }
}
