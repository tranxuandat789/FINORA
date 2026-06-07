import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../core/network/api_client.dart';

class AuthRepository {
  final ApiClient _apiClient = ApiClient();

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _apiClient.dio.post(
        '/api/auth/login',
        data: {
          'email': email,
          'password': password,
        },
      );
      return response.data;
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response?.data['message'] ?? 'Đăng nhập thất bại');
      }
      throw Exception('Không thể kết nối đến máy chủ: ${e.message}');
    }
  }

  Future<Map<String, dynamic>> register(String fullName, String email, String password, String confirmPassword) async {
    try {
      final response = await _apiClient.dio.post(
        '/api/auth/register',
        data: {
          'fullName': fullName,
          'email': email,
          'password': password,
          'confirmPassword': confirmPassword,
        },
      );
      return response.data;
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response?.data['message'] ?? 'Đăng ký thất bại');
      }
      throw Exception('Không thể kết nối đến máy chủ: ${e.message}');
    }
  }

  Future<void> logout() async {
    try {
      await _apiClient.dio.post('/api/auth/logout');
      if (!kIsWeb) {
        await _apiClient.cookieJar.deleteAll();
      }
    } catch (e) {
      // Ignore errors on logout
    }
  }
}
