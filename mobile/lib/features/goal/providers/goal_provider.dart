import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:mobile/features/goal/models/goal_model.dart';
import 'package:mobile/features/goal/services/goal_service.dart';
import 'package:path_provider/path_provider.dart';

class GoalProvider extends ChangeNotifier {
  final GoalService _goalService = GoalService();
  List<GoalModel> _goals = [];
  bool _isLoading = false;
  String? _error;

  List<GoalModel> get goals => _goals;
  bool get isLoading => _isLoading;
  String? get error => _error;

  double get totalSaved => _goals.fold(0.0, (sum, item) => sum + item.currentAmount);
  int get activeCount => activeGoals.length;
  List<GoalModel> get activeGoals => _goals.where((g) => g.isActive).toList();
  List<GoalModel> get completedGoals => _goals.where((g) => g.isCompleted).toList();

  Future<File> get _cacheFile async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/goals_cache.json');
  }

  Future<void> _saveCache() async {
    try {
      final file = await _cacheFile;
      final jsonList = _goals.map((w) => w.toJson()).toList();
      await file.writeAsString(jsonEncode(jsonList));
    } catch (e) {
      debugPrint('Error saving goals cache: $e');
    }
  }

  Future<void> _loadCache() async {
    try {
      final file = await _cacheFile;
      if (await file.exists()) {
        final content = await file.readAsString();
        final List<dynamic> jsonList = jsonDecode(content);
        _goals = jsonList.map((json) => GoalModel.fromJson(json)).toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading goals cache: $e');
    }
  }

  Future<void> loadGoals() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    await _loadCache();

    try {
      _goals = await _goalService.getGoals();
      await _saveCache();
      _error = null;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<GoalModel?> getGoalDetail(String id) async {
    try {
      return await _goalService.getGoalDetail(id);
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return null;
    }
  }

  Future<void> createGoal(Map<String, dynamic> data) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final newGoal = await _goalService.createGoal(data);
      _goals.insert(0, newGoal);
      await _saveCache();
      _error = null;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      throw Exception(_error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateGoal(String id, Map<String, dynamic> data) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updatedGoal = await _goalService.updateGoal(id, data);
      final index = _goals.indexWhere((g) => g.id == id);
      if (index != -1) {
        _goals[index] = updatedGoal;
        await _saveCache();
      }
      _error = null;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      throw Exception(_error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteGoal(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _goalService.deleteGoal(id);
      _goals.removeWhere((g) => g.id == id);
      await _saveCache();
      _error = null;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      throw Exception(_error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addContribution(String goalId, Map<String, dynamic> data) async {
    try {
      final updatedGoal = await _goalService.addContribution(goalId, data);
      final index = _goals.indexWhere((g) => g.id == goalId);
      if (index != -1) {
        _goals[index] = updatedGoal;
        await _saveCache();
      }
      notifyListeners();
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      throw Exception(_error);
    }
  }

  Future<void> withdraw(String goalId, Map<String, dynamic> data) async {
    try {
      final updatedGoal = await _goalService.withdraw(goalId, data);
      final index = _goals.indexWhere((g) => g.id == goalId);
      if (index != -1) {
        _goals[index] = updatedGoal;
        await _saveCache();
      }
      notifyListeners();
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      throw Exception(_error);
    }
  }

  Future<String> uploadGoalImage(String filePath) async {
    try {
      return await _goalService.uploadGoalImage(filePath);
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      throw Exception(_error);
    }
  }
}
