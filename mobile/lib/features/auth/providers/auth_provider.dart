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

  Future<void> loginWithGoogle({required Function onSuccess, required Function(String) onError}) async {
    _isGoogleLoading = true;
    notifyListeners();

    try {
      // TODO: Replace with your actual Web Client ID from Google Cloud Console
      final GoogleSignIn googleSignIn = GoogleSignIn(
        clientId: '1086341000678-ufm92ber5vqb64htjvpvg7ekm3cruvi4.apps.googleusercontent.com',
        serverClientId: '1086341000678-ufm92ber5vqb64htjvpvg7ekm3cruvi4.apps.googleusercontent.com',
      );
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      
      if (googleUser == null) {
        // User canceled the login
        _isGoogleLoading = false;
        notifyListeners();
        return;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final String? idToken = googleAuth.idToken;

      if (idToken == null) {
        throw Exception("Không thể lấy ID Token từ Google");
      }

      final response = await _repository.googleLogin(idToken);
      
      if (response['success'] == true) {
        _user = response['data'];
        
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user', jsonEncode(_user));
        
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
    
    // Clear all file caches
    final storage = FileStorageService();
    await storage.deleteData('categories_cache.json');
    await storage.deleteData('transactions_cache.json');
    await storage.deleteData('dashboard_cache.json');
    await storage.deleteData('sync_queue.json');

    notifyListeners();
  }
}
