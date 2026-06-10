class TransactionModel {
  final String id;
  final String walletId;
  final String walletName;
  final String categoryId;
  final String categoryName;
  final String? categoryIcon;
  final int type; // 1 = Thu nhập, 2 = Chi tiêu
  final double amount;
  final String? note;
  final DateTime transactionDate;
  final DateTime createdAt;

  TransactionModel({
    required this.id,
    required this.walletId,
    required this.walletName,
    required this.categoryId,
    required this.categoryName,
    this.categoryIcon,
    required this.type,
    required this.amount,
    this.note,
    required this.transactionDate,
    required this.createdAt,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'],
      walletId: json['walletId'],
      walletName: json['walletName'] ?? '',
      categoryId: json['categoryId'],
      categoryName: json['categoryName'] ?? '',
      categoryIcon: json['categoryIcon'],
      type: json['type'],
      amount: (json['amount'] as num).toDouble(),
      note: json['note'],
      transactionDate: DateTime.parse(json['transactionDate']),
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'walletId': walletId,
      'walletName': walletName,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'categoryIcon': categoryIcon,
      'type': type,
      'amount': amount,
      'note': note,
      'transactionDate': transactionDate.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
