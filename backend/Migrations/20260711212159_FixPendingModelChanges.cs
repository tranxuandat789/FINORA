using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace FinanceAPI.Migrations
{
    /// <inheritdoc />
    public partial class FixPendingModelChanges : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "NotificationSettings",
                columns: table => new
                {
                    UserId = table.Column<Guid>(type: "uniqueidentifier", nullable: false),
                    PushNotifications = table.Column<bool>(type: "bit", nullable: false),
                    NewTransactions = table.Column<bool>(type: "bit", nullable: false),
                    BudgetWarnings = table.Column<bool>(type: "bit", nullable: false),
                    SavingGoals = table.Column<bool>(type: "bit", nullable: false),
                    SpendingReminders = table.Column<bool>(type: "bit", nullable: false),
                    SystemAlerts = table.Column<bool>(type: "bit", nullable: false),
                    PeriodicReports = table.Column<bool>(type: "bit", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_NotificationSettings", x => x.UserId);
                    table.ForeignKey(
                        name: "FK_NotificationSettings_Users_UserId",
                        column: x => x.UserId,
                        principalTable: "Users",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "NotificationSettings");
        }
    }
}
