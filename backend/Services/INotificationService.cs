using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using FinanceAPI.Models;

namespace FinanceAPI.Services
{
    public interface INotificationService
    {
        Task<Notification?> CreateNotificationAsync(Guid userId, string title, string message, NotificationType type, Guid? referenceId = null);
        Task<IEnumerable<Notification>> GetListAsync(Guid userId, int page = 1, int pageSize = 20);
        Task<int> GetUnreadCountAsync(Guid userId);
        Task<bool> MarkAsReadAsync(Guid notificationId, Guid userId);
        Task<bool> MarkAllAsReadAsync(Guid userId);
    }
}
