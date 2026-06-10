class CategoryBudgetProgressModel {
  final String categoryId;
  final String categoryName;
  final String? icon;
  final double budgetAmount;
  final double spentAmount;
  final double progressPercentage;

  CategoryBudgetProgressModel({
    required this.categoryId,
    required this.categoryName,
    this.icon,
    required this.budgetAmount,
    required this.spentAmount,
    required this.progressPercentage,
  });

  factory CategoryBudgetProgressModel.fromJson(Map<String, dynamic> json) {
    return CategoryBudgetProgressModel(
      categoryId: json['categoryId'],
      categoryName: json['categoryName'],
      icon: json['icon'],
      budgetAmount: (json['budgetAmount'] ?? 0).toDouble(),
      spentAmount: (json['spentAmount'] ?? 0).toDouble(),
      progressPercentage: (json['progressPercentage'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'categoryId': categoryId,
      'categoryName': categoryName,
      'icon': icon,
      'budgetAmount': budgetAmount,
      'spentAmount': spentAmount,
      'progressPercentage': progressPercentage,
    };
  }
}
