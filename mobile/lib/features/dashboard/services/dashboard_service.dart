import '../../../core/network/api_client.dart';
import '../models/dashboard_model.dart';

class DashboardService {
  final ApiClient _apiClient = ApiClient();

  Future<DashboardData> getDashboardData({int? month, int? year}) async {
    final Map<String, dynamic> queryParameters = {};
    if (month != null) queryParameters['month'] = month;
    if (year != null) queryParameters['year'] = year;
    final response = await _apiClient.dio.get('/api/Dashboard', queryParameters: queryParameters.isNotEmpty ? queryParameters : null);
    return DashboardData.fromJson(response.data);
  }
}
