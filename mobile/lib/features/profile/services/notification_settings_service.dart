import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../models/notification_setting.dart';

class NotificationSettingsService {
  final Dio _dio;

  NotificationSettingsService() : _dio = ApiClient().dio;

  Future<NotificationSetting> getSettings() async {
    try {
      final response = await _dio.get('/api/NotificationSettings');
      return NotificationSetting.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to load notification settings: $e');
    }
  }

  Future<NotificationSetting> updateSettings(NotificationSetting settings) async {
    try {
      final response = await _dio.put(
        '/api/NotificationSettings',
        data: settings.toJson(),
      );
      return NotificationSetting.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to update notification settings: $e');
    }
  }
}
