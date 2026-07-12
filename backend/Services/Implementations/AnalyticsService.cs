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

        public async Task<AnalyticsResponse> GetAnalyticsAsync(Guid userId, string mode, int? month, int year)
        {
            DateTime startDate;
            DateTime endDate;
            DateTime prevStartDate;
            DateTime prevEndDate;

            if (mode == "year")
            {
                startDate = new DateTime(year, 1, 1);
                endDate = new DateTime(year, 12, 31);
                prevStartDate = new DateTime(year - 1, 1, 1);
                prevEndDate = new DateTime(year - 1, 12, 31);
            }
            else // mode == "month"
            {
                int m = month ?? DateTime.Now.Month;
                startDate = new DateTime(year, m, 1);
                endDate = startDate.AddMonths(1).AddDays(-1);
                prevStartDate = startDate.AddMonths(-1);
                prevEndDate = startDate.AddDays(-1);
            }

            // Fetch transactions for the selected period
            var currentPeriodTransactions = await _context.Transactions
                .Include(t => t.Wallet)
                .Include(t => t.Category)
                .Where(t => t.Wallet.UserId == userId && 
                            !t.IsDeleted &&
                            t.TransactionDate >= startDate && t.TransactionDate <= endDate)
                .ToListAsync();

            // Fetch transactions for previous period (for percentage change)
            var prevPeriodTransactions = await _context.Transactions
                .Include(t => t.Wallet)
                .Where(t => t.Wallet.UserId == userId && 
                            !t.IsDeleted &&
                            t.TransactionDate >= prevStartDate && t.TransactionDate <= prevEndDate)
                .ToListAsync();

            var response = new AnalyticsResponse();
            
            // Calculate totals
            response.TotalExpense = currentPeriodTransactions.Where(t => t.Type == TransactionType.Expense).Sum(t => t.Amount);
            response.TotalIncome = currentPeriodTransactions.Where(t => t.Type == TransactionType.Income).Sum(t => t.Amount);
            response.NetIncome = response.TotalIncome - response.TotalExpense;

            var prevTotalExpense = prevPeriodTransactions.Where(t => t.Type == TransactionType.Expense).Sum(t => t.Amount);

            if (prevTotalExpense == 0)
            {
                response.PercentageChange = response.TotalExpense > 0 ? 100 : 0;
            }
            else
            {
                response.PercentageChange = Math.Round((double)((response.TotalExpense - prevTotalExpense) / prevTotalExpense) * 100, 2);
            }

            // Categories (only expenses for the chart)
            var categoryGroups = currentPeriodTransactions
                .Where(t => t.Type == TransactionType.Expense)
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

            // Daily/Monthly trend (only expenses)
            var trendData = new List<DailyExpenseDto>();

            if (mode == "year")
            {
                var groupedByMonth = currentPeriodTransactions
                    .Where(t => t.Type == TransactionType.Expense)
                    .GroupBy(t => t.TransactionDate.Month)
                    .ToDictionary(g => g.Key, g => g.Sum(t => t.Amount));

                for (int i = 1; i <= 12; i++)
                {
                    var date = new DateTime(year, i, 1);
                    decimal amount = groupedByMonth.ContainsKey(i) ? groupedByMonth[i] : 0;

                    trendData.Add(new DailyExpenseDto
                    {
                        Date = date,
                        Amount = amount
                    });
                }
            }
            else
            {
                var daysInPeriod = (endDate - startDate).Days + 1;
                var groupedByDay = currentPeriodTransactions
                    .Where(t => t.Type == TransactionType.Expense)
                    .GroupBy(t => t.TransactionDate.Date)
                    .ToDictionary(g => g.Key, g => g.Sum(t => t.Amount));

                int m = month ?? DateTime.Now.Month;
                for (int i = 1; i <= daysInPeriod; i++)
                {
                    var date = new DateTime(year, m, i);
                    decimal amount = groupedByDay.ContainsKey(date) ? groupedByDay[date] : 0;

                    trendData.Add(new DailyExpenseDto
                    {
                        Date = date,
                        Amount = amount
                    });
                }
            }

            response.DailyExpenses = trendData;

            return response;
        }
    }
}
