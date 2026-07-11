using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using FinanceAPI.Data;
using FinanceAPI.Models;
using FinanceAPI.Hubs;
using Microsoft.AspNetCore.SignalR;
using Microsoft.EntityFrameworkCore;

namespace FinanceAPI.Services
{
    public class NotificationService : INotificationService
    {
        private readonly AppDbContext _context;
        private readonly IHubContext<NotificationHub> _hubContext;

        public NotificationService(AppDbContext context, IHubContext<NotificationHub> hubContext)
        {
            _context = context;
            _hubContext = hubContext;
        }

        public async Task<Notification?> CreateNotificationAsync(Guid userId, string title, string message, NotificationType type, Guid? referenceId = null)
        {
            var settings = await _context.Set<NotificationSetting>().FirstOrDefaultAsync(s => s.UserId == userId);
            
            if (settings != null)
            {
                bool shouldCreate = true;
                switch (type)
                {
                    case NotificationType.Transaction:
                        shouldCreate = settings.NewTransactions;
                        break;
                    case NotificationType.Budget:
                        shouldCreate = settings.BudgetWarnings;
                        break;
                    case NotificationType.Goal:
                        shouldCreate = settings.SavingGoals;
                        break;
                    case NotificationType.Reminder:
                        shouldCreate = settings.SpendingReminders;
                        break;
                    case NotificationType.System:
                        shouldCreate = settings.SystemAlerts;
                        break;
                }

                if (!shouldCreate || !settings.PushNotifications)
                {
                    return null;
                }
            }
            var notification = new Notification
            {
                UserId = userId,
                Title = title,
                Message = message,
                Type = type,
                ReferenceId = referenceId,
                CreatedAt = DateTime.UtcNow,
                IsRead = false
            };

            _context.Notifications.Add(notification);
            await _context.SaveChangesAsync();

            // Push notification to the user via SignalR
            await _hubContext.Clients.User(userId.ToString()).SendAsync("ReceiveNotification", notification);
            
            return notification;
        }

        public async Task<IEnumerable<Notification>> GetListAsync(Guid userId, int page = 1, int pageSize = 20)
        {
            return await _context.Notifications
                .Where(n => n.UserId == userId)
                .OrderByDescending(n => n.CreatedAt)
                .Skip((page - 1) * pageSize)
                .Take(pageSize)
                .ToListAsync();
        }

        public async Task<int> GetUnreadCountAsync(Guid userId)
        {
            return await _context.Notifications
                .CountAsync(n => n.UserId == userId && !n.IsRead);
        }

        public async Task<bool> MarkAsReadAsync(Guid notificationId, Guid userId)
        {
            var notification = await _context.Notifications
                .FirstOrDefaultAsync(n => n.Id == notificationId && n.UserId == userId);

            if (notification == null) return false;

            notification.IsRead = true;
            await _context.SaveChangesAsync();
            return true;
        }

        public async Task<bool> MarkAllAsReadAsync(Guid userId)
        {
            var unreadNotifications = await _context.Notifications
                .Where(n => n.UserId == userId && !n.IsRead)
                .ToListAsync();

            if (!unreadNotifications.Any()) return true;

            foreach (var notification in unreadNotifications)
            {
                notification.IsRead = true;
            }

            await _context.SaveChangesAsync();
            return true;
        }
    }
}
