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
    public class DashboardService : IDashboardService
    {
        private readonly AppDbContext _context;

        public DashboardService(AppDbContext context)
        {
            _context = context;
        }

        public async Task<DashboardResponse> GetDashboardDataAsync(Guid userId)
        {
            var now = DateTime.UtcNow;
            var startOfMonth = new DateTime(now.Year, now.Month, 1);
            
            var startOfLastMonth = startOfMonth.AddMonths(-1);
            var endOfLastMonth = startOfMonth.AddTicks(-1);

            // Get total balance from all active wallets
            var totalBalance = await _context.Wallets
                .Where(w => w.UserId == userId && !w.IsDeleted)
                .SumAsync(w => w.Balance);

            // Get all transactions for current month
            var currentMonthTransactions = await _context.Transactions
                .Include(t => t.Category)
                .Include(t => t.Wallet)
                .Where(t => t.Wallet.UserId == userId && !t.IsDeleted && t.TransactionDate >= startOfMonth)
                .ToListAsync();

            var totalIncomeMonth = currentMonthTransactions
                .Where(t => t.Type == TransactionType.Income)
                .Sum(t => t.Amount);

            var totalExpenseMonth = currentMonthTransactions
                .Where(t => t.Type == TransactionType.Expense)
                .Sum(t => t.Amount);

            // Calculate percentage change compared to last month balance
            var netChangeThisMonth = totalIncomeMonth - totalExpenseMonth;
            var totalBalanceLastMonth = totalBalance - netChangeThisMonth;

            double balancePercentageChange = 0;
            if (totalBalanceLastMonth > 0)
            {
                balancePercentageChange = (double)(netChangeThisMonth / totalBalanceLastMonth) * 100;
            }
            else if (netChangeThisMonth > 0)
            {
                balancePercentageChange = 100; // From 0 to positive is 100%
            }

            // Group expenses by category
            var expensesByCategory = currentMonthTransactions
                .Where(t => t.Type == TransactionType.Expense && t.Category != null)
                .GroupBy(t => t.Category)
                .Select(g => new CategoryExpenseDto
                {
                    CategoryId = g.Key.Id,
                    CategoryName = g.Key.Name,
                    CategoryIcon = g.Key.Icon,
                    Amount = g.Sum(t => t.Amount)
                })
                .OrderByDescending(c => c.Amount)
                .ToList();

            if (totalExpenseMonth > 0)
            {
                foreach (var cat in expensesByCategory)
                {
                    cat.Percentage = (double)(cat.Amount / totalExpenseMonth);
                }
            }

            // Get recent transactions
            var recentTransactions = await _context.Transactions
                .Include(t => t.Category)
                .Include(t => t.Wallet)
                .Where(t => t.Wallet.UserId == userId && !t.IsDeleted)
                .OrderByDescending(t => t.TransactionDate.Date)
                .ThenByDescending(t => t.CreatedAt)
                .Take(5)
                .Select(t => new TransactionResponse
                {
                    Id = t.Id,
                    WalletId = t.WalletId,
                    WalletName = t.Wallet.Name,
                    CategoryId = t.CategoryId,
                    CategoryName = t.Category.Name,
                    CategoryIcon = t.Category.Icon,
                    Type = t.Type,
                    Amount = t.Amount,
                    Note = t.Note,
                    TransactionDate = t.TransactionDate,
                    CreatedAt = t.CreatedAt
                })
                .ToListAsync();

            return new DashboardResponse
            {
                TotalBalance = totalBalance,
                BalancePercentageChange = balancePercentageChange,
                TotalIncomeMonth = totalIncomeMonth,
                TotalExpenseMonth = totalExpenseMonth,
                ExpenseByCategory = expensesByCategory,
                RecentTransactions = recentTransactions
            };
        }
    }
}
