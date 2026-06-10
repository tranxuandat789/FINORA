class ContributionModel {
  final String id;
  final String goalId;
  final double amount;
  final String? note;
  final DateTime contributionDate;

  ContributionModel({
    required this.id,
    required this.goalId,
    required this.amount,
    this.note,
    required this.contributionDate,
  });

  factory ContributionModel.fromJson(Map<String, dynamic> json) {
    return ContributionModel(
      id: json['id'] ?? '',
      goalId: json['goalId'] ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      note: json['note'],
      contributionDate: json['contributionDate'] != null 
          ? DateTime.parse(json['contributionDate']) 
          : DateTime.now(),
    );
  }

  bool get isWithdrawal => amount < 0;
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'goalId': goalId,
      'amount': amount,
      'note': note,
      'contributionDate': contributionDate.toIso8601String(),
    };
  }
}

class GoalModel {
  final String id;
  final String name;
  final String? icon;
  final double targetAmount;
  final double currentAmount;
  final double progress;
  final bool isCompleted;
  final DateTime deadline;
  final int daysLeft;
  final DateTime createdAt;
  final List<ContributionModel> contributions;

  GoalModel({
    required this.id,
    required this.name,
    this.icon,
    required this.targetAmount,
    required this.currentAmount,
    required this.progress,
    required this.isCompleted,
    required this.deadline,
    required this.daysLeft,
    required this.createdAt,
    this.contributions = const [],
  });

  factory GoalModel.fromJson(Map<String, dynamic> json) {
    return GoalModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      icon: json['icon'],
      targetAmount: (json['targetAmount'] as num?)?.toDouble() ?? 0.0,
      currentAmount: (json['currentAmount'] as num?)?.toDouble() ?? 0.0,
      progress: (json['progress'] as num?)?.toDouble() ?? 0.0,
      isCompleted: json['isCompleted'] ?? false,
      deadline: json['deadline'] != null ? DateTime.parse(json['deadline']) : DateTime.now(),
      daysLeft: json['daysLeft'] ?? 0,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
      contributions: json['contributions'] != null 
          ? (json['contributions'] as List).map((i) => ContributionModel.fromJson(i)).toList()
          : [],
    );
  }

  bool get isActive => !isCompleted;
  String get statusLabel => isCompleted ? 'Đã hoàn thành' : 'Đang thực hiện';

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'targetAmount': targetAmount,
      'currentAmount': currentAmount,
      'progress': progress,
      'isCompleted': isCompleted,
      'deadline': deadline.toIso8601String(),
      'daysLeft': daysLeft,
      'createdAt': createdAt.toIso8601String(),
      'contributions': contributions.map((c) => c.toJson()).toList(),
    };
  }
}
