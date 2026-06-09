using System;

namespace FinanceAPI.DTOs.Responses
{
    public class CategoryExpenseDto
    {
        public Guid CategoryId { get; set; }
        public string CategoryName { get; set; }
        public string CategoryIcon { get; set; }
        public decimal Amount { get; set; }
        public double Percentage { get; set; }
    }
}
