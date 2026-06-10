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
    public class GoalRepository : IGoalRepository
    {
        private readonly AppDbContext _context;

        public GoalRepository(AppDbContext context)
        {
            _context = context;
        }

        public async Task<List<Goal>> GetAllByUserIdAsync(Guid userId)
        {
            return await _context.Goals
                .Where(g => g.UserId == userId && !g.IsDeleted)
                .OrderByDescending(g => g.Deadline)
                .ToListAsync();
        }

        public async Task<Goal?> GetByIdAsync(Guid id, Guid userId)
        {
            return await _context.Goals
                .FirstOrDefaultAsync(g => g.Id == id && g.UserId == userId && !g.IsDeleted);
        }

        public async Task<Goal> CreateAsync(Goal goal)
        {
            _context.Goals.Add(goal);
            await _context.SaveChangesAsync();
            return goal;
        }

        public async Task<Goal> UpdateAsync(Goal goal)
        {
            _context.Goals.Update(goal);
            await _context.SaveChangesAsync();
            return goal;
        }

        public async Task SoftDeleteAsync(Goal goal)
        {
            goal.IsDeleted = true;
            _context.Goals.Update(goal);
            await _context.SaveChangesAsync();
        }

        public async Task<GoalContribution> AddContributionAsync(GoalContribution contribution)
        {
            _context.GoalContributions.Add(contribution);
            await _context.SaveChangesAsync();
            return contribution;
        }

        public async Task<List<GoalContribution>> GetContributionsByGoalIdAsync(Guid goalId)
        {
            return await _context.GoalContributions
                .Where(c => c.GoalId == goalId && !c.IsDeleted)
                .OrderByDescending(c => c.ContributionDate)
                .ToListAsync();
        }
    }
}
