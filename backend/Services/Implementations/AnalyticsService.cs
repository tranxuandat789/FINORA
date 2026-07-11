using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using FinanceAPI.Data;
using FinanceAPI.DTOs.Responses;
using FinanceAPI.Models.Enums;
using FinanceAPI.Services.Interfaces;
using Microsoft.EntityFrameworkCore;

namespace FinanceAPI.Services.Implementations
{
    public class AnalyticsService : IAnalyticsService
    {
        private readonly AppDbContext _context;

        public AnalyticsService(AppDbContext context)
        {
            _context = context;
        }

        public async Task<AnalyticsResponse> GetExpenseAnalyticsAsync(Guid userId, int month, int year)
        {
            var startDate = new DateTime(year, month, 1);
            var endDate = startDate.AddMonths(1).AddDays(-1);

            var prevMonthStartDate = startDate.AddMonths(-1);
            var prevMonthEndDate = startDate.AddDays(-1);

            // Fetch transactions for this month
            var currentMonthTransactions = await _context.Transactions
                .Include(t => t.Wallet)
                .Include(t => t.Category)
                .Where(t => t.Wallet.UserId == userId && 
                            t.Type == TransactionType.Expense && 
                            !t.IsDeleted &&
                            t.TransactionDate >= startDate && t.TransactionDate <= endDate)
                .ToListAsync();

            // Fetch transactions for previous month
            var prevMonthTransactions = await _context.Transactions
                .Include(t => t.Wallet)
                .Where(t => t.Wallet.UserId == userId && 
                            t.Type == TransactionType.Expense && 
                            !t.IsDeleted &&
                            t.TransactionDate >= prevMonthStartDate && t.TransactionDate <= prevMonthEndDate)
                .ToListAsync();

            var response = new AnalyticsResponse();
            response.TotalExpense = currentMonthTransactions.Sum(t => t.Amount);

            var prevMonthExpense = prevMonthTransactions.Sum(t => t.Amount);

            if (prevMonthExpense == 0)
            {
                response.PercentageChange = response.TotalExpense > 0 ? 100 : 0;
            }
            else
            {
                response.PercentageChange = Math.Round((double)((response.TotalExpense - prevMonthExpense) / prevMonthExpense) * 100, 2);
            }

            // Categories
            var categoryGroups = currentMonthTransactions
                .GroupBy(t => t.Category)
                .Select(g => new CategoryExpenseDto
                {
                    CategoryId = g.Key?.Id ?? Guid.Empty,
                    CategoryName = g.Key?.Name ?? "Chưa phân loại",
                    CategoryIcon = g.Key?.Icon ?? "help_outline",
                    Amount = g.Sum(t => t.Amount),
                    Percentage = response.TotalExpense > 0 ? Math.Round((double)(g.Sum(t => t.Amount) / response.TotalExpense) * 100, 2) : 0
                })
                .OrderByDescending(c => c.Amount)
                .ToList();

            response.CategoryExpenses = categoryGroups;

            // Daily trend
            var daysInMonth = DateTime.DaysInMonth(year, month);
            var dailyData = new List<DailyExpenseDto>();

            var groupedByDay = currentMonthTransactions
                .GroupBy(t => t.TransactionDate.Date)
                .ToDictionary(g => g.Key, g => g.Sum(t => t.Amount));

            for (int i = 1; i <= daysInMonth; i++)
            {
                var date = new DateTime(year, month, i);
                decimal amount = 0;
                if (groupedByDay.ContainsKey(date))
                {
                    amount = groupedByDay[date];
                }

                dailyData.Add(new DailyExpenseDto
                {
                    Date = date,
                    Amount = amount
                });
            }

            response.DailyExpenses = dailyData;

            return response;
        }
    }
}
