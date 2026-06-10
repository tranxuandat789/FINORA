using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using FinanceAPI.DTOs.Requests;
using FinanceAPI.DTOs.Responses;

namespace FinanceAPI.Services.Interfaces
{
    public interface IGoalService
    {
        Task<IEnumerable<GoalResponse>> GetGoalsAsync(Guid userId);
        Task<GoalDetailResponse> GetGoalDetailAsync(Guid id, Guid userId);
        Task<GoalResponse> CreateGoalAsync(CreateGoalRequest req, Guid userId);
        Task<GoalResponse> UpdateGoalAsync(Guid id, UpdateGoalRequest req, Guid userId);
        Task DeleteGoalAsync(Guid id, Guid userId);
        Task<GoalResponse> AddContributionAsync(Guid goalId, AddContributionRequest req, Guid userId);
        Task<GoalResponse> WithdrawAsync(Guid goalId, AddContributionRequest req, Guid userId);
    }
}
