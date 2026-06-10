import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

// On native (Android/iOS), we use SharedPreferences for simplicity.
// On Web, SharedPreferences uses localStorage — no path_provider needed.
class FileStorageService {
  Future<void> writeData(String filename, String data) async {
    try {
      if (kIsWeb) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('cache_$filename', data);
      } else {
        // Use SharedPreferences on native too for simplicity & web parity
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('cache_$filename', data);
      }
    } catch (e) {
      // Ignore write errors
    }
  }

  Future<String?> readData(String filename) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('cache_$filename');
    } catch (e) {
      return null;
    }
  }

  Future<void> deleteData(String filename) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('cache_$filename');
    } catch (e) {
      // Ignore error
    }
  }
}
