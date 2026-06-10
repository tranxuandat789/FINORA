using System.ComponentModel.DataAnnotations;
using FinanceAPI.Models.Enums;

namespace FinanceAPI.Models.DTOs
{
    public class CategoryCreateDto
    {
        [Required]
        public string Name { get; set; } = string.Empty;

        [Required]
        public TransactionType Type { get; set; }

        public string? Icon { get; set; }

        public decimal? BudgetAmount { get; set; }
    }
}
