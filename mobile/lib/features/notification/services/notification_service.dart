import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../models/notification_model.dart';

class NotificationService {
  final ApiClient _apiClient = ApiClient();

  Future<List<NotificationModel>> getNotifications({int page = 1, int pageSize = 20}) async {
    try {
      final response = await _apiClient.dio.get('/api/notifications', queryParameters: {
        'page': page,
        'pageSize': pageSize,
      });

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => NotificationModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }

  Future<int> getUnreadCount() async {
    try {
      final response = await _apiClient.dio.get('/api/notifications/unread-count');
      if (response.statusCode == 200) {
        return response.data['count'] ?? 0;
      }
      return 0;
    } catch (e) {
      return 0;
    }
  }

  Future<bool> markAsRead(String id) async {
    try {
      final response = await _apiClient.dio.put('/api/notifications/$id/read');
      return response.statusCode == 204;
    } catch (e) {
      return false;
    }
  }

  Future<bool> markAllAsRead() async {
    try {
      final response = await _apiClient.dio.put('/api/notifications/read-all');
      return response.statusCode == 204;
    } catch (e) {
      return false;
    }
  }
}
