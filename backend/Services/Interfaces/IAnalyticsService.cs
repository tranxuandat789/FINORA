using System;
using System.Threading.Tasks;
using FinanceAPI.DTOs.Responses;

namespace FinanceAPI.Services.Interfaces
{
    public interface IAnalyticsService
    {
        Task<AnalyticsResponse> GetAnalyticsAsync(Guid userId, string mode, int? month, int year);
    }
}
