using System;
using System.Threading.Tasks;
using FinanceAPI.DTOs;

namespace FinanceAPI.Services
{
    public interface INotificationSettingService
    {
        Task<NotificationSettingDto> GetSettingsAsync(Guid userId);
        Task<NotificationSettingDto> UpdateSettingsAsync(Guid userId, UpdateNotificationSettingDto dto);
    }
}
