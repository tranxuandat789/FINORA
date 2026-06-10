using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using FinanceAPI.Data;
using FinanceAPI.Models;
using FinanceAPI.Repositories.Interfaces;
using Microsoft.EntityFrameworkCore;

namespace FinanceAPI.Repositories.Implementations
{
    public class TransactionRepository : ITransactionRepository
    {
        private readonly AppDbContext _context;

        public TransactionRepository(AppDbContext context)
        {
            _context = context;
        }

        public async Task<IEnumerable<Transaction>> GetTransactionsByUserIdAsync(Guid userId)
        {
            // Only return transactions for wallets owned by this user
            return await _context.Transactions
                .Include(t => t.Wallet)
                .Include(t => t.Category)
                .Where(t => t.Wallet.UserId == userId && !t.IsDeleted)
                .OrderByDescending(t => t.TransactionDate.Date)
                .ThenByDescending(t => t.CreatedAt)
                .ToListAsync();
        }

        public async Task<Transaction?> GetTransactionByIdAsync(Guid id, Guid userId)
        {
            return await _context.Transactions
                .Include(t => t.Wallet)
                .Include(t => t.Category)
                .FirstOrDefaultAsync(t => t.Id == id && t.Wallet.UserId == userId && !t.IsDeleted);
        }

        public async Task<Transaction> CreateTransactionAsync(Transaction transaction)
        {
            _context.Transactions.Add(transaction);
            await SaveChangesAsync();
            return transaction;
        }

        public async Task DeleteTransactionAsync(Transaction transaction)
        {
            // Soft delete
            transaction.IsDeleted = true;
            _context.Transactions.Update(transaction);
            await SaveChangesAsync();
        }

        public async Task SaveChangesAsync()
        {
            await _context.SaveChangesAsync();
        }
    }
}
