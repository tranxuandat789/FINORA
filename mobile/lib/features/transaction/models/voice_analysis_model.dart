class VoiceAnalysisModel {
  final double? amount;
  final String? categoryId;
  final String? categoryName;
  final String? note;
  final DateTime? transactionDate;

  VoiceAnalysisModel({
    this.amount,
    this.categoryId,
    this.categoryName,
    this.note,
    this.transactionDate,
  });

  factory VoiceAnalysisModel.fromJson(Map<String, dynamic> json) {
    return VoiceAnalysisModel(
      amount: json['amount'] != null ? (json['amount'] as num).toDouble() : null,
      categoryId: json['categoryId'],
      categoryName: json['categoryName'],
      note: json['note'],
      transactionDate: json['transactionDate'] != null ? DateTime.parse(json['transactionDate']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'amount': amount,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'note': note,
      'transactionDate': transactionDate?.toIso8601String(),
    };
  }
}
