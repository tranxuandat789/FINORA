import 'package:flutter/material.dart';
import '../repositories/auth_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class AuthProvider with ChangeNotifier {
  final AuthRepository _repository = AuthRepository();
  bool _isLoading = false;
  Map<String, dynamic>? _user;

  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;
  Map<String, dynamic>? get user => _user;

  Future<void> checkAuthStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final userStr = prefs.getString('user');
    if (userStr != null) {
      _user = jsonDecode(userStr);
      notifyListeners();
    }
  }

  Future<void> login(String email, String password, {required Function onSuccess, required Function(String) onError}) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _repository.login(email, password);
      if (response['success'] == true) {
        _user = response['data'];
        
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user', jsonEncode(_user));
        
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

  Future<void> register(String fullName, String email, String password, String confirmPassword, {required Function onSuccess, required Function(String) onError}) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _repository.register(fullName, email, password, confirmPassword);
      if (response['success'] == true) {
        _user = response['data'];
        
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user', jsonEncode(_user));
        
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

  Future<void> logout() async {
    await _repository.logout();
    _user = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user');
    notifyListeners();
  }
}
