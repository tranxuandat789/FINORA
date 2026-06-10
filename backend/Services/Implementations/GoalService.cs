using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using FinanceAPI.DTOs.Requests;
using FinanceAPI.DTOs.Responses;
using FinanceAPI.Models;
using FinanceAPI.Repositories.Interfaces;
using FinanceAPI.Services.Interfaces;

namespace FinanceAPI.Services.Implementations
{
    public class GoalService : IGoalService
    {
        private readonly IGoalRepository _goalRepository;

        public GoalService(IGoalRepository goalRepository)
        {
            _goalRepository = goalRepository;
        }

        private GoalResponse MapToGoalResponse(Goal goal)
        {
            var progress = goal.TargetAmount > 0 ? goal.CurrentAmount / goal.TargetAmount : 0;
            return new GoalResponse
            {
                Id = goal.Id,
                Name = goal.Name,
                Icon = goal.Icon,
                TargetAmount = goal.TargetAmount,
                CurrentAmount = goal.CurrentAmount,
                Progress = progress > 1 ? 1 : progress,
                IsCompleted = goal.CurrentAmount >= goal.TargetAmount,
                Deadline = goal.Deadline,
                DaysLeft = (goal.Deadline.Date - DateTime.UtcNow.Date).Days,
                CreatedAt = goal.Id != Guid.Empty ? DateTime.UtcNow : DateTime.UtcNow // Lacking CreatedAt in Goal model, fallback
            };
        }

        public async Task<IEnumerable<GoalResponse>> GetGoalsAsync(Guid userId)
        {
            var goals = await _goalRepository.GetAllByUserIdAsync(userId);
            return goals.Select(MapToGoalResponse);
        }

        public async Task<GoalDetailResponse> GetGoalDetailAsync(Guid id, Guid userId)
        {
            var goal = await _goalRepository.GetByIdAsync(id, userId);
            if (goal == null)
                throw new Exception("Mục tiêu không tồn tại.");

            var contributions = await _goalRepository.GetContributionsByGoalIdAsync(id);

            var res = new GoalDetailResponse
            {
                Id = goal.Id,
                Name = goal.Name,
                Icon = goal.Icon,
                TargetAmount = goal.TargetAmount,
                CurrentAmount = goal.CurrentAmount,
                Progress = goal.TargetAmount > 0 ? (goal.CurrentAmount / goal.TargetAmount) > 1 ? 1 : (goal.CurrentAmount / goal.TargetAmount) : 0,
                IsCompleted = goal.CurrentAmount >= goal.TargetAmount,
                Deadline = goal.Deadline,
                DaysLeft = (goal.Deadline.Date - DateTime.UtcNow.Date).Days,
                Contributions = contributions.Select(c => new ContributionResponse
                {
                    Id = c.Id,
                    GoalId = c.GoalId,
                    Amount = c.Amount,
                    Note = c.Note,
                    ContributionDate = c.ContributionDate
                }).ToList()
            };

            return res;
        }

        public async Task<GoalResponse> CreateGoalAsync(CreateGoalRequest req, Guid userId)
        {
            var goal = new Goal
            {
                UserId = userId,
                Name = req.Name,
                TargetAmount = req.TargetAmount,
                CurrentAmount = 0,
                Deadline = req.Deadline,
                Icon = req.Icon,
                IsDeleted = false
            };

            var createdGoal = await _goalRepository.CreateAsync(goal);
            return MapToGoalResponse(createdGoal);
        }

        public async Task<GoalResponse> UpdateGoalAsync(Guid id, UpdateGoalRequest req, Guid userId)
        {
            var goal = await _goalRepository.GetByIdAsync(id, userId);
            if (goal == null)
                throw new Exception("Mục tiêu không tồn tại.");

            goal.Name = req.Name;
            goal.TargetAmount = req.TargetAmount;
            goal.Deadline = req.Deadline;
            goal.Icon = req.Icon;

            var updatedGoal = await _goalRepository.UpdateAsync(goal);
            return MapToGoalResponse(updatedGoal);
        }

        public async Task DeleteGoalAsync(Guid id, Guid userId)
        {
            var goal = await _goalRepository.GetByIdAsync(id, userId);
            if (goal == null)
                throw new Exception("Mục tiêu không tồn tại.");

            await _goalRepository.SoftDeleteAsync(goal);
        }

        public async Task<GoalResponse> AddContributionAsync(Guid goalId, AddContributionRequest req, Guid userId)
        {
            var goal = await _goalRepository.GetByIdAsync(goalId, userId);
            if (goal == null)
                throw new Exception("Mục tiêu không tồn tại.");

            if (goal.CurrentAmount >= goal.TargetAmount)
                throw new Exception("Mục tiêu đã hoàn thành, không thể đóng góp thêm.");

            var contribution = new GoalContribution
            {
                GoalId = goalId,
                Amount = req.Amount,
                Note = req.Note,
                ContributionDate = req.ContributionDate,
                IsDeleted = false
            };

            await _goalRepository.AddContributionAsync(contribution);
            
            goal.CurrentAmount += req.Amount;
            await _goalRepository.UpdateAsync(goal);

            return MapToGoalResponse(goal);
        }

        public async Task<GoalResponse> WithdrawAsync(Guid goalId, AddContributionRequest req, Guid userId)
        {
            var goal = await _goalRepository.GetByIdAsync(goalId, userId);
            if (goal == null)
                throw new Exception("Mục tiêu không tồn tại.");

            if (goal.CurrentAmount - req.Amount < 0)
                throw new Exception("Số tiền rút vượt quá số tiền đã tiết kiệm được.");

            var contribution = new GoalContribution
            {
                GoalId = goalId,
                Amount = -req.Amount, // Âm để phân biệt rút tiền
                Note = req.Note,
                ContributionDate = req.ContributionDate,
                IsDeleted = false
            };

            await _goalRepository.AddContributionAsync(contribution);

            goal.CurrentAmount -= req.Amount;
            await _goalRepository.UpdateAsync(goal);

            return MapToGoalResponse(goal);
        }
    }
}
