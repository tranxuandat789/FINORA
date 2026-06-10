import 'category_budget_progress_model.dart';

class BudgetProgressModel {
  final double totalBudget;
  final double totalSpent;
  final int month;
  final int year;
  final List<CategoryBudgetProgressModel> categories;

  BudgetProgressModel({
    required this.totalBudget,
    required this.totalSpent,
    required this.month,
    required this.year,
    required this.categories,
  });

  factory BudgetProgressModel.fromJson(Map<String, dynamic> json) {
    var list = json['categories'] as List? ?? [];
    List<CategoryBudgetProgressModel> catsList = 
        list.map((i) => CategoryBudgetProgressModel.fromJson(i)).toList();

    return BudgetProgressModel(
      totalBudget: (json['totalBudget'] ?? 0).toDouble(),
      totalSpent: (json['totalSpent'] ?? 0).toDouble(),
      month: json['month'] ?? DateTime.now().month,
      year: json['year'] ?? DateTime.now().year,
      categories: catsList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalBudget': totalBudget,
      'totalSpent': totalSpent,
      'month': month,
      'year': year,
      'categories': categories.map((e) => e.toJson()).toList(),
    };
  }
}
