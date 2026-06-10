import 'package:mobile/core/network/api_client.dart';
import 'package:mobile/features/analytics/models/analytics_model.dart';
import 'package:dio/dio.dart';

class AnalyticsService {
  final ApiClient _apiClient = ApiClient();

  Future<AnalyticsResponse> getExpenseAnalytics(int month, int year) async {
    try {
      final response = await _apiClient.dio.get(
        '/api/analytics/expense',
        queryParameters: {
          'month': month,
          'year': year,
        },
      );
      return AnalyticsResponse.fromJson(response.data);
    } catch (e) {
      if (e is DioException) {
        final data = e.response?.data;
        if (data is Map<String, dynamic> && data.containsKey('message')) {
          throw Exception(data['message']);
        }
      }
      throw Exception('Lỗi khi lấy dữ liệu phân tích');
    }
  }
}
