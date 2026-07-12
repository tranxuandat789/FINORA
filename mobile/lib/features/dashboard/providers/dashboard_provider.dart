import 'package:flutter/foundation.dart';
import '../models/dashboard_model.dart';
import '../services/dashboard_service.dart';

class DashboardProvider with ChangeNotifier {
  final DashboardService _service = DashboardService();
  DashboardData? _data;
  bool _isLoading = false;
  String? _error;

  DateTime _selectedDate = DateTime.now();
  DateTime get selectedDate => _selectedDate;

  void setSelectedDate(DateTime date) {
    _selectedDate = date;
    loadDashboardData();
  }

  DashboardData? get data => _data;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadDashboardData() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _data = await _service.getDashboardData(month: _selectedDate.month, year: _selectedDate.year);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
