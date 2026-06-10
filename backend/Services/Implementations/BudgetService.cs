using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using FinanceAPI.Data;
using FinanceAPI.Models;
using FinanceAPI.Models.DTOs;
using FinanceAPI.Models.Enums;
using FinanceAPI.Services.Interfaces;

namespace FinanceAPI.Services.Implementations
{
    public class BudgetService : IBudgetService
    {
        private readonly AppDbContext _context;

        public BudgetService(AppDbContext context)
        {
            _context = context;
        }

        public async Task<BudgetProgressResponse> GetMonthlyProgressAsync(Guid userId, int month, int year)
        {
            var startDate = new DateTime(year, month, 1);
            var endDate = startDate.AddMonths(1).AddDays(-1);

            // Get all expense categories for this user (including system default)
            var categories = await _context.Categories
                .Where(c => !c.IsDeleted && c.Type == TransactionType.Expense && (c.UserId == null || c.UserId == userId))
                .ToListAsync();

            var categoryIds = categories.Select(c => c.Id).ToList();

            // Get budgets for these categories by this user
            var budgets = await _context.Budgets
                .Where(b => !b.IsDeleted && b.UserId == userId && categoryIds.Contains(b.CategoryId))
                .ToListAsync();

            // Get transactions for these categories in this month
            var transactions = await _context.Transactions
                .Include(t => t.Wallet)
                .Where(t => !t.IsDeleted && t.Type == TransactionType.Expense && t.Wallet.UserId == userId && 
                            t.TransactionDate >= startDate && t.TransactionDate <= endDate)
                .ToListAsync();

            var response = new BudgetProgressResponse
            {
                Month = month,
                Year = year
            };

            foreach (var category in categories)
            {
                var budget = budgets.FirstOrDefault(b => b.CategoryId == category.Id);
                var spent = transactions.Where(t => t.CategoryId == category.Id).Sum(t => t.Amount);

                response.Categories.Add(new CategoryBudgetProgress
                {
                    CategoryId = category.Id,
                    CategoryName = category.Name,
                    Icon = category.Icon,
                    BudgetAmount = budget?.BaseAmount ?? 0,
                    SpentAmount = spent
                });
            }

            response.TotalBudget = response.Categories.Sum(c => c.BudgetAmount);
            response.TotalSpent = response.Categories.Sum(c => c.SpentAmount);
            
            // Sort by SpentAmount descending
            response.Categories = response.Categories.OrderByDescending(c => c.SpentAmount).ToList();

            return response;
        }

        public async Task UpsertCategoryBudgetAsync(Guid userId, Guid categoryId, decimal amount)
        {
            var budget = await _context.Budgets
                .FirstOrDefaultAsync(b => b.UserId == userId && b.CategoryId == categoryId && !b.IsDeleted);

            if (budget == null)
            {
                budget = new Budget
                {
                    Id = Guid.NewGuid(),
                    UserId = userId,
                    CategoryId = categoryId,
                    BaseAmount = amount,
                    StartDate = new DateTime(DateTime.UtcNow.Year, DateTime.UtcNow.Month, 1),
                    IsDeleted = false
                };
                _context.Budgets.Add(budget);
            }
            else
            {
                budget.BaseAmount = amount;
            }

            await _context.SaveChangesAsync();
        }
    }
}
