using System;

namespace FinanceAPI.DTOs
{
    public class NotificationSettingDto
    {
        public Guid UserId { get; set; }
        public bool PushNotifications { get; set; }
        public bool NewTransactions { get; set; }
        public bool BudgetWarnings { get; set; }
        public bool SavingGoals { get; set; }
        public bool SpendingReminders { get; set; }
        public bool SystemAlerts { get; set; }
        public bool PeriodicReports { get; set; }
    }

    public class UpdateNotificationSettingDto
    {
        public bool PushNotifications { get; set; }
        public bool NewTransactions { get; set; }
        public bool BudgetWarnings { get; set; }
        public bool SavingGoals { get; set; }
        public bool SpendingReminders { get; set; }
        public bool SystemAlerts { get; set; }
        public bool PeriodicReports { get; set; }
    }
}
