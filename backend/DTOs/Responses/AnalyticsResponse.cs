using System.Collections.Generic;

namespace FinanceAPI.DTOs.Responses
{
    public class AnalyticsResponse
    {
        public decimal TotalExpense { get; set; }
        public double PercentageChange { get; set; }
        public List<CategoryExpenseDto> CategoryExpenses { get; set; } = new List<CategoryExpenseDto>();
        public List<DailyExpenseDto> DailyExpenses { get; set; } = new List<DailyExpenseDto>();
    }
}
