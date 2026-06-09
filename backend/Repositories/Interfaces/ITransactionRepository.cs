using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using FinanceAPI.Models;

namespace FinanceAPI.Repositories.Interfaces
{
    public interface ITransactionRepository
    {
        Task<IEnumerable<Transaction>> GetTransactionsByUserIdAsync(Guid userId);
        Task<Transaction?> GetTransactionByIdAsync(Guid id, Guid userId);
        Task<Transaction> CreateTransactionAsync(Transaction transaction);
        Task DeleteTransactionAsync(Transaction transaction);
        Task SaveChangesAsync();
    }
}
