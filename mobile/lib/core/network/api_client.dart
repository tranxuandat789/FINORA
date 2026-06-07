import 'dart:io';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  late Dio dio;
  late PersistCookieJar cookieJar;
  bool _isInitialized = false;

  factory ApiClient() {
    return _instance;
  }

  ApiClient._internal() {
    // 10.0.2.2 is localhost for Android emulator. For iOS simulator use 127.0.0.1 or localhost.
    String baseUrl = 'http://127.0.0.1:5063';
    if (!kIsWeb && Platform.isAndroid) {
      baseUrl = 'http://10.0.2.2:5063';
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
    
    if (kIsWeb) {
      // In web, browser handles cookies automatically. We don't need cookie manager.
      // But we need to make sure requests include credentials.
      dio.options.extra['withCredentials'] = true;
    } else {
      final appDocDir = await getApplicationDocumentsDirectory();
      final appDocPath = appDocDir.path;
      cookieJar = PersistCookieJar(
        ignoreExpires: true,
        storage: FileStorage("$appDocPath/.cookies/"),
      );
      dio.interceptors.add(CookieManager(cookieJar));
    }
    
    // Add interceptor for logging
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        debugPrint('=> \${options.method} \${options.uri}');
        debugPrint('=> Headers: \${options.headers}');
        debugPrint('=> Data: \${options.data}');
        return handler.next(options);
      },
      onResponse: (response, handler) {
        debugPrint('<= \${response.statusCode} \${response.requestOptions.uri}');
        debugPrint('<= Data: \${response.data}');
        return handler.next(response);
      },
      onError: (DioException e, handler) {
        debugPrint('<= Error: \${e.message}');
        if (e.response != null) {
          debugPrint('<= Response data: \${e.response?.data}');
        }
        return handler.next(e);
      },
    ));

    _isInitialized = true;
  }
}
