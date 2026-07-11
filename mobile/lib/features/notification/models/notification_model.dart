enum NotificationType { transaction, budget, goal, reminder, system }

class NotificationModel {
  final String id;
  final String userId;
  final String title;
  final String message;
  final NotificationType type;
  final String? referenceId;
  bool isRead;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.message,
    required this.type,
    this.referenceId,
    required this.isRead,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'],
      userId: json['userId'],
      title: json['title'],
      message: json['message'],
      type: NotificationType.values[json['type'] ?? 0],
      referenceId: json['referenceId'],
      isRead: json['isRead'] ?? false,
      createdAt: DateTime.parse(json['createdAt']).toLocal(),
    );
  }
}
