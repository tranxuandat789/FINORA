import 'package:flutter/foundation.dart';
import '../models/notification_model.dart';
import '../services/notification_service.dart';
import '../services/signalr_service.dart';

class NotificationProvider with ChangeNotifier {
  final NotificationService _notificationService = NotificationService();
  final SignalRService _signalRService = SignalRService();

  List<NotificationModel> _notifications = [];
  bool _isLoading = false;
  int _unreadCount = 0;

  List<NotificationModel> get notifications => _notifications;
  bool get isLoading => _isLoading;
  int get unreadCount => _unreadCount;

  NotificationProvider() {
    _signalRService.onNotificationReceived = _handleNewNotification;
  }

  void _handleNewNotification(Map<String, dynamic> data) {
    final newNotif = NotificationModel.fromJson(data);
    _notifications.insert(0, newNotif);
    _unreadCount++;
    notifyListeners();
  }

  Future<void> fetchNotifications({bool refresh = false}) async {
    if (refresh) {
      _isLoading = true;
      notifyListeners();
    }
    
    try {
      _notifications = await _notificationService.getNotifications();
      await fetchUnreadCount();
    } catch (e) {
      debugPrint('Failed to fetch notifications: $e');
    } finally {
      if (refresh) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  Future<void> fetchUnreadCount() async {
    try {
      _unreadCount = await _notificationService.getUnreadCount();
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to fetch unread count: $e');
    }
  }

  Future<void> markAsRead(String id) async {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1 && !_notifications[index].isRead) {
      // Optimistic update
      _notifications[index].isRead = true;
      if (_unreadCount > 0) _unreadCount--;
      notifyListeners();

      final success = await _notificationService.markAsRead(id);
      if (!success) {
        // Revert on failure
        _notifications[index].isRead = false;
        _unreadCount++;
        notifyListeners();
      }
    }
  }

  Future<void> markAllAsRead() async {
    if (_unreadCount == 0) return;

    final List<NotificationModel> previousState = List.from(_notifications);
    final previousCount = _unreadCount;

    // Optimistic update
    for (var n in _notifications) {
      n.isRead = true;
    }
    _unreadCount = 0;
    notifyListeners();

    final success = await _notificationService.markAllAsRead();
    if (!success) {
      // Revert on failure
      _notifications = previousState;
      _unreadCount = previousCount;
      notifyListeners();
    }
  }
}
