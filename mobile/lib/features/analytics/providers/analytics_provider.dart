import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:mobile/core/local_storage/file_storage_service.dart';
import 'package:mobile/features/analytics/models/analytics_model.dart';
import 'package:mobile/features/analytics/services/analytics_service.dart';

class AnalyticsProvider with ChangeNotifier {
  final AnalyticsService _analyticsService;
  final FileStorageService _fileStorageService = FileStorageService();

  AnalyticsProvider(this._analyticsService);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  AnalyticsResponse? _analyticsData;
  AnalyticsResponse? get analyticsData => _analyticsData;

  DateTime _currentDate = DateTime.now();
  DateTime get currentDate => _currentDate;

  String _mode = 'month'; // 'month' or 'year'
  String get mode => _mode;

  Future<void> fetchAnalytics() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _analyticsData = await _analyticsService.getOverviewAnalytics(
        _mode,
        _mode == 'month' ? _currentDate.month : null,
        _currentDate.year,
      );
      
      // Save cache
      await _fileStorageService.writeData(
        'analytics_cache_${_mode}_${_currentDate.month}_${_currentDate.year}.json',
        jsonEncode(_analyticsData!.toJson()),
      );
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      // Load cache
      try {
        final cacheString = await _fileStorageService.readData(
            'analytics_cache_${_mode}_${_currentDate.month}_${_currentDate.year}.json');
        if (cacheString != null) {
          final cache = jsonDecode(cacheString);
          _analyticsData = AnalyticsResponse.fromJson(cache);
          _error = 'Đang hiển thị dữ liệu ngoại tuyến.';
        }
      } catch (_) {
        // ignore
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void changeMode(String newMode) {
    if (_mode != newMode) {
      _mode = newMode;
      fetchAnalytics();
    }
  }

  void changeDate(int offset) {
    if (_mode == 'month') {
      _currentDate = DateTime(_currentDate.year, _currentDate.month + offset, 1);
    } else {
      _currentDate = DateTime(_currentDate.year + offset, _currentDate.month, 1);
    }
    fetchAnalytics();
  }
}
