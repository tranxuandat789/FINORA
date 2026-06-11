import 'package:flutter/material.dart';
import '../repositories/auth_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:convert';
import '../../../core/local_storage/file_storage_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthRepository _repository = AuthRepository();
  bool _isLoading = false;
  bool _isGoogleLoading = false;
  Map<String, dynamic>? _user;

  bool get isLoading => _isLoading;
  bool get isGoogleLoading => _isGoogleLoading;
  bool get isAuthenticated => _user != null;
  Map<String, dynamic>? get user => _user;

  Future<void> checkAuthStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final userStr = prefs.getString('user');
    final token = prefs.getString('auth_token');
    if (userStr != null && token != null) {
      _user = jsonDecode(userStr);
      notifyListeners();
    }
  }

  Future<void> _saveSession(Map<String, dynamic> userData, String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user', jsonEncode(userData));
    await prefs.setString('auth_token', token);
  }

  /// Cập nhật một field trong user data và đồng bộ vào SharedPreferences
  void updateUserField(String key, dynamic value) {
    if (_user == null) return;
    _user = Map<String, dynamic>.from(_user!)..[key] = value;
    // Sync to SharedPreferences (fire-and-forget)
    SharedPreferences.getInstance().then((prefs) {
      prefs.setString('user', jsonEncode(_user));
    });
    notifyListeners();
  }

  Future<void> login(String email, String password,
      {required Function onSuccess, required Function(String) onError}) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _repository.login(email, password);
      if (response['success'] == true) {
        final data = Map<String, dynamic>.from(response['data'] as Map<String, dynamic>);
        final token = data['token'] as String? ?? '';
        data['isGoogleUser'] = false;
        _user = data;

        await _saveSession(data, token);
        onSuccess();
      } else {
        onError(response['message'] ?? 'Đăng nhập thất bại');
      }
    } catch (e) {
      onError(e.toString().replaceAll('Exception: ', ''));
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loginWithGoogle(
      {required Function onSuccess, required Function(String) onError}) async {
    _isGoogleLoading = true;
    notifyListeners();

    try {
      final GoogleSignIn googleSignIn = GoogleSignIn(
        clientId:
            '1086341000678-ufm92ber5vqb64htjvpvg7ekm3cruvi4.apps.googleusercontent.com',
        serverClientId:
            '1086341000678-ufm92ber5vqb64htjvpvg7ekm3cruvi4.apps.googleusercontent.com',
      );
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        _isGoogleLoading = false;
        notifyListeners();
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final String? idToken = googleAuth.idToken;

      if (idToken == null) {
        throw Exception("Không thể lấy ID Token từ Google");
      }

      final response = await _repository.googleLogin(idToken);

      if (response['success'] == true) {
        final data = Map<String, dynamic>.from(response['data'] as Map<String, dynamic>);
        final token = data['token'] as String? ?? '';
        data['isGoogleUser'] = true;
        _user = data;

        await _saveSession(data, token);
        onSuccess();
      } else {
        onError(response['message'] ?? 'Đăng nhập Google thất bại');
      }
    } catch (e) {
      onError(e.toString().replaceAll('Exception: ', ''));
    } finally {
      _isGoogleLoading = false;
      notifyListeners();
    }
  }

  Future<void> register(
      String fullName, String email, String password, String confirmPassword,
      {required Function onSuccess, required Function(String) onError}) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response =
          await _repository.register(fullName, email, password, confirmPassword);
      if (response['success'] == true) {
        final data = response['data'] as Map<String, dynamic>;
        final token = data['token'] as String? ?? '';
        _user = data;

        await _saveSession(data, token);
        onSuccess();
      } else {
        onError(response['message'] ?? 'Đăng ký thất bại');
      }
    } catch (e) {
      onError(e.toString().replaceAll('Exception: ', ''));
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> sendOtp(String email, String purpose,
      {required Function() onSuccess, required Function(String) onError}) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _repository.sendOtp(email, purpose);
      onSuccess();
    } catch (e) {
      onError(e.toString().replaceAll('Exception: ', ''));
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> verifyOtp(String email, String otp, String purpose,
      {required Function(String resetToken) onSuccess, required Function(String) onError}) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _repository.verifyOtp(email, otp, purpose);
      final data = response['data'] as Map<String, dynamic>? ?? {};
      final resetToken = data['resetToken'] as String? ?? '';
      onSuccess(resetToken);
    } catch (e) {
      onError(e.toString().replaceAll('Exception: ', ''));
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> resetPassword(String email, String otpToken, String newPassword, String confirmPassword,
      {required Function onSuccess, required Function(String) onError}) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _repository.resetPassword(email, otpToken, newPassword, confirmPassword);
      onSuccess();
    } catch (e) {
      onError(e.toString().replaceAll('Exception: ', ''));
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    try {
      await _repository.logout();
    } catch (_) {}

    _user = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user');
    await prefs.remove('auth_token');

    // Clear all file caches
    final storage = FileStorageService();
    await storage.deleteData('categories_cache.json');
    await storage.deleteData('transactions_cache.json');
    await storage.deleteData('dashboard_cache.json');
    await storage.deleteData('sync_queue.json');

    notifyListeners();
  }
}
