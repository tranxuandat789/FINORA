using System.Collections.Generic;

namespace FinanceAPI.Models.DTOs
{
    public class BudgetProgressResponse
    {
        public decimal TotalBudget { get; set; }
        public decimal TotalSpent { get; set; }
        public int Month { get; set; }
        public int Year { get; set; }
        public List<CategoryBudgetProgress> Categories { get; set; } = new List<CategoryBudgetProgress>();
    }
}
