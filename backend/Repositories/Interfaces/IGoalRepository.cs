using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using FinanceAPI.Models;

namespace FinanceAPI.Repositories.Interfaces
{
    public interface IGoalRepository
    {
        Task<List<Goal>> GetAllByUserIdAsync(Guid userId);
        Task<Goal?> GetByIdAsync(Guid id, Guid userId);
        Task<Goal> CreateAsync(Goal goal);
        Task<Goal> UpdateAsync(Goal goal);
        Task SoftDeleteAsync(Goal goal);
        Task<GoalContribution> AddContributionAsync(GoalContribution contribution);
        Task<List<GoalContribution>> GetContributionsByGoalIdAsync(Guid goalId);
    }
}
