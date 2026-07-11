class NotificationSetting {
  final bool pushNotifications;
  final bool newTransactions;
  final bool budgetWarnings;
  final bool savingGoals;
  final bool spendingReminders;
  final bool systemAlerts;
  final bool periodicReports;

  NotificationSetting({
    required this.pushNotifications,
    required this.newTransactions,
    required this.budgetWarnings,
    required this.savingGoals,
    required this.spendingReminders,
    required this.systemAlerts,
    required this.periodicReports,
  });

  factory NotificationSetting.fromJson(Map<String, dynamic> json) {
    return NotificationSetting(
      pushNotifications: json['pushNotifications'] ?? true,
      newTransactions: json['newTransactions'] ?? true,
      budgetWarnings: json['budgetWarnings'] ?? true,
      savingGoals: json['savingGoals'] ?? true,
      spendingReminders: json['spendingReminders'] ?? true,
      systemAlerts: json['systemAlerts'] ?? true,
      periodicReports: json['periodicReports'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pushNotifications': pushNotifications,
      'newTransactions': newTransactions,
      'budgetWarnings': budgetWarnings,
      'savingGoals': savingGoals,
      'spendingReminders': spendingReminders,
      'systemAlerts': systemAlerts,
      'periodicReports': periodicReports,
    };
  }

  NotificationSetting copyWith({
    bool? pushNotifications,
    bool? newTransactions,
    bool? budgetWarnings,
    bool? savingGoals,
    bool? spendingReminders,
    bool? systemAlerts,
    bool? periodicReports,
  }) {
    return NotificationSetting(
      pushNotifications: pushNotifications ?? this.pushNotifications,
      newTransactions: newTransactions ?? this.newTransactions,
      budgetWarnings: budgetWarnings ?? this.budgetWarnings,
      savingGoals: savingGoals ?? this.savingGoals,
      spendingReminders: spendingReminders ?? this.spendingReminders,
      systemAlerts: systemAlerts ?? this.systemAlerts,
      periodicReports: periodicReports ?? this.periodicReports,
    );
  }
}
