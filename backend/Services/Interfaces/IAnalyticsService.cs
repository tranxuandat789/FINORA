using System;
using System.Threading.Tasks;
using FinanceAPI.DTOs.Responses;

namespace FinanceAPI.Services.Interfaces
{
    public interface IAnalyticsService
    {
        Task<AnalyticsResponse> GetExpenseAnalyticsAsync(Guid userId, int month, int year);
    }
}
