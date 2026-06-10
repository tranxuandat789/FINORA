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

  Future<void> fetchAnalytics() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _analyticsData = await _analyticsService.getExpenseAnalytics(
        _currentDate.month,
        _currentDate.year,
      );
      
      // Save cache
      await _fileStorageService.writeData(
        'analytics_cache_${_currentDate.month}_${_currentDate.year}.json',
        jsonEncode(_analyticsData!.toJson()),
      );
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      // Load cache
      try {
        final cacheString = await _fileStorageService.readData(
            'analytics_cache_${_currentDate.month}_${_currentDate.year}.json');
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

  void changeMonth(int offset) {
    _currentDate = DateTime(_currentDate.year, _currentDate.month + offset, 1);
    fetchAnalytics();
  }
}
