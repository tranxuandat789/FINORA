using System.Collections.Generic;

namespace FinanceAPI.DTOs.Responses
{
    public class DashboardResponse
    {
        public decimal TotalBalance { get; set; }
        public double BalancePercentageChange { get; set; }
        public decimal TotalIncomeMonth { get; set; }
        public decimal TotalExpenseMonth { get; set; }
        public List<CategoryExpenseDto> ExpenseByCategory { get; set; } = new List<CategoryExpenseDto>();
        public List<TransactionResponse> RecentTransactions { get; set; } = new List<TransactionResponse>();
    }
}
