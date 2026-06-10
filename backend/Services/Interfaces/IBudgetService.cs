using System;
using System.Threading.Tasks;
using FinanceAPI.Models.DTOs;

namespace FinanceAPI.Services.Interfaces
{
    public interface IBudgetService
    {
        Task<BudgetProgressResponse> GetMonthlyProgressAsync(Guid userId, int month, int year);
        Task UpsertCategoryBudgetAsync(Guid userId, Guid categoryId, decimal amount);
    }
}
