import 'package:dio/dio.dart';
import 'package:mobile/core/network/api_client.dart';
import '../models/budget_progress_model.dart';

class BudgetService {
  final ApiClient _apiClient = ApiClient();

  String _handleError(dynamic error, String defaultMsg) {
    if (error is DioException) {
      final data = error.response?.data;
      if (data is Map<String, dynamic>) {
        if (data.containsKey('message')) return data['message'].toString();
        if (data.containsKey('title')) return data['title'].toString();
      } else if (data is String) {
        return data;
      }
    }
    return defaultMsg;
  }

  Future<BudgetProgressModel> getMonthlyProgress({int? month, int? year}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (month != null) queryParams['month'] = month;
      if (year != null) queryParams['year'] = year;

      final response = await _apiClient.dio.get(
        '/api/budgets/progress',
        queryParameters: queryParams,
      );

      final data = response.data['data'];
      return BudgetProgressModel.fromJson(data);
    } catch (e) {
      throw Exception(_handleError(e, 'Không thể lấy dữ liệu ngân sách'));
    }
  }

  Future<void> upsertCategoryBudget(String categoryId, double amount) async {
    try {
      await _apiClient.dio.post(
        '/api/budgets/category/$categoryId',
        data: {'amount': amount},
      );
    } catch (e) {
      throw Exception(_handleError(e, 'Không thể cập nhật ngân sách'));
    }
  }
}
