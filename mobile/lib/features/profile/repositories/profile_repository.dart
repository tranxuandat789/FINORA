import 'dart:io';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile/core/network/api_client.dart';
import 'package:flutter/foundation.dart';
import 'package:http_parser/http_parser.dart';

class ProfileRepository {
  final Dio _dio = ApiClient().dio;

  /// GET /api/profile
  Future<Map<String, dynamic>> getProfile() async {
    final res = await _dio.get('/api/profile');
    return res.data as Map<String, dynamic>;
  }

  /// PUT /api/profile — cập nhật tên và số điện thoại
  Future<Map<String, dynamic>> updateProfile({
    required String fullName,
    String? phoneNumber,
  }) async {
    final res = await _dio.put('/api/profile', data: {
      'fullName': fullName,
      if (phoneNumber != null && phoneNumber.isNotEmpty) 'phoneNumber': phoneNumber,
    });
    return res.data as Map<String, dynamic>;
  }

  /// POST /api/profile/avatar — upload ảnh đại diện
  Future<Map<String, dynamic>> uploadAvatar(XFile imageFile) async {
    MultipartFile multipartFile;
    String fileName = imageFile.name;
    if (fileName.isEmpty) fileName = 'avatar.jpg';

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

    final res = await _dio.post(
      '/api/profile/avatar',
      data: formData,
    );
    return res.data as Map<String, dynamic>;
  }

  /// PUT /api/profile/change-password
  Future<Map<String, dynamic>> changePassword({
    String? currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    final res = await _dio.put('/api/profile/change-password', data: {
      if (currentPassword != null && currentPassword.isNotEmpty)
        'currentPassword': currentPassword,
      'newPassword': newPassword,
      'confirmPassword': confirmPassword,
    });
    return res.data as Map<String, dynamic>;
  }
}
