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
        final data = e.response?.data;
        if (data is Map<String, dynamic>) {
          if (data.containsKey('message') && data['message'] != null) {
            throw Exception(data['message']);
          } else if (data.containsKey('errors')) {
            final errors = data['errors'] as Map<String, dynamic>;
            if (errors.isNotEmpty) {
              final firstError = errors.values.first;
              if (firstError is List && firstError.isNotEmpty) {
                throw Exception(firstError.first.toString());
              }
            }
          } else if (data.containsKey('title') && data['title'] != null) {
            throw Exception(data['title']);
          }
        }
        throw Exception('Đăng nhập thất bại');
      }
      throw Exception('Không thể kết nối đến máy chủ: ${e.message}');
    }
  }

  Future<Map<String, dynamic>> googleLogin(String idToken) async {
    try {
      final response = await _apiClient.dio.post(
        '/api/auth/google-login',
        data: {
          'idToken': idToken,
        },
      );
      return response.data;
    } on DioException catch (e) {
      if (e.response != null) {
        final data = e.response?.data;
        if (data is Map<String, dynamic>) {
          if (data.containsKey('message') && data['message'] != null) {
            throw Exception(data['message']);
          } else if (data.containsKey('errors')) {
            final errors = data['errors'] as Map<String, dynamic>;
            if (errors.isNotEmpty) {
              final firstError = errors.values.first;
              if (firstError is List && firstError.isNotEmpty) {
                throw Exception(firstError.first.toString());
              }
            }
          } else if (data.containsKey('title') && data['title'] != null) {
            throw Exception(data['title']);
          }
        }
        throw Exception('Đăng nhập Google thất bại');
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
        final data = e.response?.data;
        if (data is Map<String, dynamic>) {
          if (data.containsKey('message') && data['message'] != null) {
            throw Exception(data['message']);
          } else if (data.containsKey('errors')) {
            final errors = data['errors'] as Map<String, dynamic>;
            if (errors.isNotEmpty) {
              final firstError = errors.values.first;
              if (firstError is List && firstError.isNotEmpty) {
                throw Exception(firstError.first.toString());
              }
            }
          } else if (data.containsKey('title') && data['title'] != null) {
            throw Exception(data['title']);
          }
        }
        throw Exception('Đăng ký thất bại');
      }
      throw Exception('Không thể kết nối đến máy chủ: ${e.message}');
    }
  }

  Future<Map<String, dynamic>> sendOtp(String email, String purpose) async {
    try {
      final response = await _apiClient.dio.post(
        '/api/auth/send-otp',
        data: {'email': email, 'purpose': purpose},
      );
      return response.data;
    } on DioException catch (e) {
      final data = e.response?.data;
      if (data is Map<String, dynamic> && data['message'] != null) {
        throw Exception(data['message']);
      }
      throw Exception('Không thể gửi OTP. Vui lòng thử lại.');
    }
  }

  Future<Map<String, dynamic>> verifyOtp(String email, String otp, String purpose) async {
    try {
      final response = await _apiClient.dio.post(
        '/api/auth/verify-otp',
        data: {'email': email, 'otp': otp, 'purpose': purpose},
      );
      return response.data;
    } on DioException catch (e) {
      final data = e.response?.data;
      if (data is Map<String, dynamic> && data['message'] != null) {
        throw Exception(data['message']);
      }
      throw Exception('Xác minh OTP thất bại.');
    }
  }

  Future<Map<String, dynamic>> resetPassword(String email, String otpToken, String newPassword, String confirmPassword) async {
    try {
      final response = await _apiClient.dio.post(
        '/api/auth/reset-password',
        data: {
          'email': email,
          'otpToken': otpToken,
          'newPassword': newPassword,
          'confirmPassword': confirmPassword,
        },
      );
      return response.data;
    } on DioException catch (e) {
      final data = e.response?.data;
      if (data is Map<String, dynamic> && data['message'] != null) {
        throw Exception(data['message']);
      }
      throw Exception('Đặt lại mật khẩu thất bại.');
    }
  }

  // --- PIN ---

  Future<Map<String, dynamic>> setupPin(String newPin) async {
    try {
      final response = await _apiClient.dio.post(
        '/api/auth/setup-pin',
        data: {
          'newPin': newPin,
        },
      );
      return response.data;
    } on DioException catch (e) {
      final data = e.response?.data;
      if (data is Map<String, dynamic> && data['message'] != null) {
        throw Exception(data['message']);
      }
      throw Exception('Thiết lập mã PIN thất bại.');
    }
  }

  Future<Map<String, dynamic>> changePin(String oldPin, String newPin) async {
    try {
      final response = await _apiClient.dio.post(
        '/api/auth/change-pin',
        data: {
          'oldPin': oldPin,
          'newPin': newPin,
        },
      );
      return response.data;
    } on DioException catch (e) {
      final data = e.response?.data;
      if (data is Map<String, dynamic> && data['message'] != null) {
        throw Exception(data['message']);
      }
      throw Exception('Đổi mã PIN thất bại.');
    }
  }

  Future<Map<String, dynamic>> verifyPin(String pin) async {
    try {
      final response = await _apiClient.dio.post(
        '/api/auth/verify-pin',
        data: {
          'pin': pin,
        },
      );
      return response.data;
    } on DioException catch (e) {
      final data = e.response?.data;
      if (data is Map<String, dynamic> && data['message'] != null) {
        throw Exception(data['message']);
      }
      throw Exception('Xác thực mã PIN thất bại.');
    }
  }

  Future<Map<String, dynamic>> resetPin(String email, String resetToken, String newPin) async {
    try {
      final response = await _apiClient.dio.post(
        '/api/auth/reset-pin',
        data: {
          'email': email,
          'resetToken': resetToken,
          'newPin': newPin,
        },
      );
      return response.data;
    } on DioException catch (e) {
      final data = e.response?.data;
      if (data is Map<String, dynamic> && data['message'] != null) {
        throw Exception(data['message']);
      }
      throw Exception('Đặt lại mã PIN thất bại.');
    }
  }

  Future<Map<String, dynamic>> removePin(String pin) async {
    try {
      final response = await _apiClient.dio.post(
        '/api/auth/remove-pin',
        data: {'pin': pin},
      );
      return response.data;
    } on DioException catch (e) {
      final data = e.response?.data;
      if (data is Map<String, dynamic>) {
        final msg = data['message'] ?? data['Message'];
        if (msg != null) throw Exception(msg);
      }
      throw Exception('Tắt mã PIN thất bại.');
    }
  }

  Future<Map<String, dynamic>> enablePin(String pin) async {
    try {
      final response = await _apiClient.dio.post(
        '/api/auth/enable-pin',
        data: {'pin': pin},
      );
      return response.data;
    } on DioException catch (e) {
      final data = e.response?.data;
      if (data is Map<String, dynamic>) {
        final msg = data['message'] ?? data['Message'];
        if (msg != null) throw Exception(msg);
      }
      throw Exception('Bật mã PIN thất bại.');
    }
  }

  Future<void> logout() async {
    try {
      await _apiClient.dio.post('/api/auth/logout');
    } catch (e) {
      // Ignore errors on logout
    }
  }
}
