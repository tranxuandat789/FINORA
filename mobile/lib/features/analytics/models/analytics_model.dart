import 'dart:convert';

class AnalyticsResponse {
  final double totalExpense;
  final double percentageChange;
  final List<CategoryExpense> categoryExpenses;
  final List<DailyExpense> dailyExpenses;

  AnalyticsResponse({
    required this.totalExpense,
    required this.percentageChange,
    required this.categoryExpenses,
    required this.dailyExpenses,
  });

  factory AnalyticsResponse.fromJson(Map<String, dynamic> json) {
    return AnalyticsResponse(
      totalExpense: (json['totalExpense'] ?? 0).toDouble(),
      percentageChange: (json['percentageChange'] ?? 0).toDouble(),
      categoryExpenses: (json['categoryExpenses'] as List<dynamic>?)
              ?.map((e) => CategoryExpense.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      dailyExpenses: (json['dailyExpenses'] as List<dynamic>?)
              ?.map((e) => DailyExpense.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalExpense': totalExpense,
      'percentageChange': percentageChange,
      'categoryExpenses': categoryExpenses.map((e) => e.toJson()).toList(),
      'dailyExpenses': dailyExpenses.map((e) => e.toJson()).toList(),
    };
  }
}

class CategoryExpense {
  final String categoryId;
  final String categoryName;
  final String categoryIcon;
  final double amount;
  final double percentage;

  CategoryExpense({
    required this.categoryId,
    required this.categoryName,
    required this.categoryIcon,
    required this.amount,
    required this.percentage,
  });

  factory CategoryExpense.fromJson(Map<String, dynamic> json) {
    return CategoryExpense(
      categoryId: json['categoryId'] ?? '',
      categoryName: json['categoryName'] ?? '',
      categoryIcon: json['categoryIcon'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      percentage: (json['percentage'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'categoryId': categoryId,
      'categoryName': categoryName,
      'categoryIcon': categoryIcon,
      'amount': amount,
      'percentage': percentage,
    };
  }
}

class DailyExpense {
  final DateTime date;
  final double amount;

  DailyExpense({
    required this.date,
    required this.amount,
  });

  factory DailyExpense.fromJson(Map<String, dynamic> json) {
    return DailyExpense(
      date: DateTime.parse(json['date']),
      amount: (json['amount'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'amount': amount,
    };
  }
}
