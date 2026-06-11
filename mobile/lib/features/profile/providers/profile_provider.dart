import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile/features/profile/repositories/profile_repository.dart';

class ProfileProvider extends ChangeNotifier {
  final ProfileRepository _repository = ProfileRepository();

  bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;

  void _setLoading(bool v) {
    _isLoading = v;
    notifyListeners();
  }

  // ─── UPDATE PROFILE ──────────────────────────────────────────────────────

  Future<Map<String, dynamic>?> updateProfile({
    required String fullName,
    String? phoneNumber,
    required Function(Map<String, dynamic>) onSuccess,
    required Function(String) onError,
  }) async {
    _setLoading(true);
    _error = null;
    try {
      final res = await _repository.updateProfile(
          fullName: fullName, phoneNumber: phoneNumber);
      if (res['success'] == true) {
        final data = res['data'] as Map<String, dynamic>;
        onSuccess(data);
        return data;
      } else {
        final msg = res['message'] ?? 'Cập nhật thất bại';
        _error = msg;
        onError(msg);
        return null;
      }
    } catch (e) {
      final msg = _parseError(e);
      _error = msg;
      onError(msg);
      return null;
    } finally {
      _setLoading(false);
    }
  }

  // ─── UPLOAD AVATAR ────────────────────────────────────────────────────────

  Future<String?> uploadAvatar({
    required XFile imageFile,
    required Function(String avatarUrl) onSuccess,
    required Function(String) onError,
  }) async {
    _setLoading(true);
    _error = null;
    try {
      final res = await _repository.uploadAvatar(imageFile);
      if (res['success'] == true) {
        final url = res['data']['avatarUrl'] as String;
        onSuccess(url);
        return url;
      } else {
        final msg = res['message'] ?? 'Upload ảnh thất bại';
        _error = msg;
        onError(msg);
        return null;
      }
    } catch (e) {
      final msg = _parseError(e);
      _error = msg;
      onError(msg);
      return null;
    } finally {
      _setLoading(false);
    }
  }

  // ─── CHANGE PASSWORD ──────────────────────────────────────────────────────

  Future<bool> changePassword({
    String? currentPassword,
    required String newPassword,
    required String confirmPassword,
    required Function() onSuccess,
    required Function(String) onError,
  }) async {
    _setLoading(true);
    _error = null;
    try {
      final res = await _repository.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
        confirmPassword: confirmPassword,
      );
      if (res['success'] == true) {
        onSuccess();
        return true;
      } else {
        final msg = res['message'] ?? 'Cập nhật mật khẩu thất bại';
        _error = msg;
        onError(msg);
        return false;
      }
    } catch (e) {
      final msg = _parseError(e);
      _error = msg;
      onError(msg);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  String _parseError(Object e) {
    if (e is DioException) {
      if (e.response?.data != null && e.response?.data is Map) {
        final message = e.response?.data['message'];
        if (message != null) return message.toString();
      }
      return e.message ?? e.toString();
    }
    if (e is Exception) {
      final str = e.toString();
      // Lấy message từ response body
      final match = RegExp(r'"message":"([^"]+)"').firstMatch(str);
      if (match != null) return match.group(1)!;
      return str.replaceFirst('Exception: ', '');
    }
    return 'Đã xảy ra lỗi, vui lòng thử lại';
  }
}
