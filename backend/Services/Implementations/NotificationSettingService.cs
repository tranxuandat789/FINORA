using System;
using System.Threading.Tasks;
using FinanceAPI.Data;
using FinanceAPI.DTOs;
using FinanceAPI.Models;
using Microsoft.EntityFrameworkCore;

namespace FinanceAPI.Services.Implementations
{
    public class NotificationSettingService : INotificationSettingService
    {
        private readonly AppDbContext _context;

        public NotificationSettingService(AppDbContext context)
        {
            _context = context;
        }

        public async Task<NotificationSettingDto> GetSettingsAsync(Guid userId)
        {
            var setting = await _context.NotificationSettings
                .FirstOrDefaultAsync(s => s.UserId == userId);

            // Create default settings if not exists
            if (setting == null)
            {
                setting = new NotificationSetting
                {
                    UserId = userId,
                    PushNotifications = true,
                    NewTransactions = true,
                    BudgetWarnings = true,
                    SavingGoals = true,
                    SpendingReminders = true,
                    SystemAlerts = true,
                    PeriodicReports = true
                };
                
                _context.NotificationSettings.Add(setting);
                await _context.SaveChangesAsync();
            }

            return new NotificationSettingDto
            {
                UserId = setting.UserId,
                PushNotifications = setting.PushNotifications,
                NewTransactions = setting.NewTransactions,
                BudgetWarnings = setting.BudgetWarnings,
                SavingGoals = setting.SavingGoals,
                SpendingReminders = setting.SpendingReminders,
                SystemAlerts = setting.SystemAlerts,
                PeriodicReports = setting.PeriodicReports
            };
        }

        public async Task<NotificationSettingDto> UpdateSettingsAsync(Guid userId, UpdateNotificationSettingDto dto)
        {
            var setting = await _context.NotificationSettings
                .FirstOrDefaultAsync(s => s.UserId == userId);

            if (setting == null)
            {
                setting = new NotificationSetting { UserId = userId };
                _context.NotificationSettings.Add(setting);
            }

            setting.PushNotifications = dto.PushNotifications;
            setting.NewTransactions = dto.NewTransactions;
            setting.BudgetWarnings = dto.BudgetWarnings;
            setting.SavingGoals = dto.SavingGoals;
            setting.SpendingReminders = dto.SpendingReminders;
            setting.SystemAlerts = dto.SystemAlerts;
            setting.PeriodicReports = dto.PeriodicReports;

            await _context.SaveChangesAsync();

            return new NotificationSettingDto
            {
                UserId = setting.UserId,
                PushNotifications = setting.PushNotifications,
                NewTransactions = setting.NewTransactions,
                BudgetWarnings = setting.BudgetWarnings,
                SavingGoals = setting.SavingGoals,
                SpendingReminders = setting.SpendingReminders,
                SystemAlerts = setting.SystemAlerts,
                PeriodicReports = setting.PeriodicReports
            };
        }
    }
}
