using System;

namespace FinanceAPI.DTOs.Responses
{
    public class DailyExpenseDto
    {
        public DateTime Date { get; set; }
        public decimal Amount { get; set; }
    }
}
