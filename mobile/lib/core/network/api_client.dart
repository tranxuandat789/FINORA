import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  late Dio dio;
  bool _isInitialized = false;

  factory ApiClient() {
    return _instance;
  }

  ApiClient._internal() {
    // 192.168.1.18 is localhost for Android emulator. For iOS simulator use 127.0.0.1 or localhost.
    String baseUrl = 'http://localhost:5063';
    if (!kIsWeb && Platform.isAndroid) {
      baseUrl = 'http://192.168.1.18:5063';
    }

    dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));
  }

  Future<void> init() async {
    if (_isInitialized) return;

    // Add JWT interceptor  Ereads token from SharedPreferences and injects into every request
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('auth_token');
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        debugPrint('=> ${options.method} ${options.uri}');
        debugPrint('=> Headers: ${options.headers}');
        return handler.next(options);
      },
      onResponse: (response, handler) {
        debugPrint('<= ${response.statusCode} ${response.requestOptions.uri}');
        debugPrint('<= Data: ${response.data}');
        return handler.next(response);
      },
      onError: (DioException e, handler) {
        debugPrint('<= Error: ${e.message}');
        if (e.response != null) {
          debugPrint('<= Response data: ${e.response?.data}');
        }
        return handler.next(e);
      },
    ));

    _isInitialized = true;
  }
}

