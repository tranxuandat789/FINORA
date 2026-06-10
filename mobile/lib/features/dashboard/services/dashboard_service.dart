import '../../../core/network/api_client.dart';
import '../models/dashboard_model.dart';

class DashboardService {
  final ApiClient _apiClient = ApiClient();

  Future<DashboardData> getDashboardData() async {
    final response = await _apiClient.dio.get('/api/Dashboard');
    return DashboardData.fromJson(response.data);
  }
}
