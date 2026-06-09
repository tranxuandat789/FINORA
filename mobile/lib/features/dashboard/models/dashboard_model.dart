import '../../transaction/models/transaction_model.dart';

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
}

class DashboardData {
  final double totalBalance;
  final double balancePercentageChange;
  final double totalIncomeMonth;
  final double totalExpenseMonth;
  final List<CategoryExpense> expenseByCategory;
  final List<TransactionModel> recentTransactions;

  DashboardData({
    required this.totalBalance,
    required this.balancePercentageChange,
    required this.totalIncomeMonth,
    required this.totalExpenseMonth,
    required this.expenseByCategory,
    required this.recentTransactions,
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    var expenseList = json['expenseByCategory'] as List? ?? [];
    var recentList = json['recentTransactions'] as List? ?? [];

    return DashboardData(
      totalBalance: (json['totalBalance'] ?? 0).toDouble(),
      balancePercentageChange: (json['balancePercentageChange'] ?? 0).toDouble(),
      totalIncomeMonth: (json['totalIncomeMonth'] ?? 0).toDouble(),
      totalExpenseMonth: (json['totalExpenseMonth'] ?? 0).toDouble(),
      expenseByCategory: expenseList.map((e) => CategoryExpense.fromJson(e)).toList(),
      recentTransactions: recentList.map((e) => TransactionModel.fromJson(e)).toList(),
    );
  }
}
