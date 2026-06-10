using System;

namespace FinanceAPI.Models.DTOs
{
    public class CategoryBudgetProgress
    {
        public Guid CategoryId { get; set; }
        public string CategoryName { get; set; } = string.Empty;
        public string? Icon { get; set; }
        public decimal BudgetAmount { get; set; }
        public decimal SpentAmount { get; set; }
        public decimal ProgressPercentage => BudgetAmount > 0 ? Math.Round((SpentAmount / BudgetAmount) * 100, 2) : 0;
    }
}
