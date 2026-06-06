using System;

namespace FinanceAPI.Models
{
    public class Budget
    {
        public Guid Id { get; set; }
        public Guid UserId { get; set; }
        public Guid CategoryId { get; set; }
        public decimal BaseAmount { get; set; }
        public DateTime StartDate { get; set; }
        public bool IsDeleted { get; set; }

        // Navigation properties
        public User User { get; set; } = null!;
        public Category Category { get; set; } = null!;
    }
}
