using System;
using System.Threading.Tasks;
using FinanceAPI.DTOs.Responses;

namespace FinanceAPI.Services.Interfaces
{
    public interface IDashboardService
    {
        Task<DashboardResponse> GetDashboardDataAsync(Guid userId, int? month = null, int? year = null);
    }
}
