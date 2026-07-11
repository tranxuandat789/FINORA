using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace FinanceAPI.Models
{
    public class NotificationSetting
    {
        [Key]
        [ForeignKey("User")]
        public Guid UserId { get; set; }
        
        public bool PushNotifications { get; set; } = true;
        public bool NewTransactions { get; set; } = true;
        public bool BudgetWarnings { get; set; } = true;
        public bool SavingGoals { get; set; } = true;
        public bool SpendingReminders { get; set; } = true;
        public bool SystemAlerts { get; set; } = true;
        public bool PeriodicReports { get; set; } = true;

        // Navigation property
        public User User { get; set; } = null!;
    }
}
