using System;

namespace FinanceAPI.DTOs.Responses
{
    public class ContributionResponse
    {
        public Guid Id { get; set; }
        public Guid GoalId { get; set; }
        public decimal Amount { get; set; }
        public string? Note { get; set; }
        public DateTime ContributionDate { get; set; }
    }
}
