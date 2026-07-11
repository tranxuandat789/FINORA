import 'package:mobile/core/network/api_client.dart';
import 'package:mobile/features/goal/models/goal_model.dart';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:http_parser/http_parser.dart';

class GoalService {
  final ApiClient _apiClient = ApiClient();

  String _handleError(dynamic error, String defaultMsg) {
    if (error is DioException) {
      final data = error.response?.data;
      if (data is Map<String, dynamic>) {
        if (data.containsKey('message')) return data['message'].toString();
        if (data.containsKey('errors')) return data['errors'].toString();
      }
      if (data is String && data.isNotEmpty) {
        return data;
      }
      return defaultMsg;
    }
    return 'Lỗi kết nối máy chủ';
  }

  Future<List<GoalModel>> getGoals() async {
    try {
      final response = await _apiClient.dio.get('/api/Goals');
      final List<dynamic> data = response.data;
      return data.map((json) => GoalModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception(_handleError(e, 'Lỗi tải danh sách mục tiêu'));
    }
  }

  Future<GoalModel> getGoalDetail(String id) async {
    try {
      final response = await _apiClient.dio.get('/api/Goals/$id');
      return GoalModel.fromJson(response.data);
    } catch (e) {
      throw Exception(_handleError(e, 'Lỗi tải chi tiết mục tiêu'));
    }
  }

  Future<GoalModel> createGoal(Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.dio.post('/api/Goals', data: data);
      return GoalModel.fromJson(response.data);
    } catch (e) {
      throw Exception(_handleError(e, 'Lỗi tạo mục tiêu'));
    }
  }

  Future<GoalModel> updateGoal(String id, Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.dio.put('/api/Goals/$id', data: data);
      return GoalModel.fromJson(response.data);
    } catch (e) {
      throw Exception(_handleError(e, 'Lỗi cập nhật mục tiêu'));
    }
  }

  Future<void> deleteGoal(String id) async {
    try {
      await _apiClient.dio.delete('/api/Goals/$id');
    } catch (e) {
      throw Exception(_handleError(e, 'Lỗi xóa mục tiêu'));
    }
  }

  Future<GoalModel> addContribution(String goalId, Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.dio.post('/api/Goals/$goalId/contributions', data: data);
      return GoalModel.fromJson(response.data);
    } catch (e) {
      throw Exception(_handleError(e, 'Lỗi đóng góp tiền'));
    }
  }

  Future<GoalModel> withdraw(String goalId, Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.dio.post('/api/Goals/$goalId/withdraw', data: data);
      return GoalModel.fromJson(response.data);
    } catch (e) {
      throw Exception(_handleError(e, 'Lỗi rút tiền'));
    }
  }

  Future<String> uploadGoalImage(XFile imageFile) async {
    try {
      MultipartFile multipartFile;
      String fileName = imageFile.name;
      if (fileName.isEmpty) fileName = 'goal_image.jpg';

      final ext = fileName.split('.').last.toLowerCase();
      String mimeType = 'jpeg';
      if (ext == 'png') mimeType = 'png';
      else if (ext == 'webp') mimeType = 'webp';
      else if (ext == 'jpg') mimeType = 'jpeg';

      if (kIsWeb) {
        multipartFile = MultipartFile.fromBytes(
          await imageFile.readAsBytes(),
          filename: fileName,
          contentType: MediaType('image', mimeType),
        );
      } else {
        multipartFile = await MultipartFile.fromFile(
          imageFile.path,
          filename: fileName,
          contentType: MediaType('image', mimeType),
        );
      }

      final formData = FormData.fromMap({
        'file': multipartFile,
      });

      final response = await _apiClient.dio.post(
        '/api/Goals/upload-image',
        data: formData,
      );
      return response.data['imageUrl'] as String;
    } catch (e) {
      throw Exception(_handleError(e, 'Lỗi tải ảnh lên'));
    }
  }
}
