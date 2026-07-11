import 'package:flutter/foundation.dart';
import '../models/notification_setting.dart';
import '../services/notification_settings_service.dart';

class NotificationSettingsProvider extends ChangeNotifier {
  final NotificationSettingsService _service = NotificationSettingsService();
  
  NotificationSetting? _settings;
  bool _isLoading = false;
  String? _error;

  NotificationSetting? get settings => _settings;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadSettings() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _settings = await _service.getSettings();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateSettings(NotificationSetting newSettings) async {
    try {
      // Optimistic update
      _settings = newSettings;
      notifyListeners();

      _settings = await _service.updateSettings(newSettings);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      // Reload on error to restore the previous state
      await loadSettings();
    }
  }
}
