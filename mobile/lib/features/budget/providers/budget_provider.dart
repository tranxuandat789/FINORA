import 'package:flutter/material.dart';
import '../models/budget_progress_model.dart';
import '../services/budget_service.dart';

class BudgetProvider with ChangeNotifier {
  final BudgetService _service = BudgetService();
  
  BudgetProgressModel? _progress;
  bool _isLoading = false;
  String? _error;

  BudgetProgressModel? get progress => _progress;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadMonthlyProgress({int? month, int? year}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _progress = await _service.getMonthlyProgress(month: month, year: year);
      _error = null;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> upsertCategoryBudget(String categoryId, double amount) async {
    try {
      await _service.upsertCategoryBudget(categoryId, amount);
      // Reload current month's progress
      if (_progress != null) {
        await loadMonthlyProgress(month: _progress!.month, year: _progress!.year);
      } else {
        await loadMonthlyProgress();
      }
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      throw Exception(_error);
    }
  }
}
