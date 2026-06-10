import 'package:flutter/material.dart';
import 'dart:convert';
import '../models/category_model.dart';
import '../services/category_service.dart';
import '../../../core/local_storage/file_storage_service.dart';

class CategoryProvider with ChangeNotifier {
  final CategoryService _service = CategoryService();
  final FileStorageService _storage = FileStorageService();

  List<CategoryModel> _categories = [];
  bool _isLoading = false;
  String? _error;

  List<CategoryModel> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadCategories() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final cacheData = await _storage.readData('categories_cache.json');
      if (cacheData != null) {
        final List<dynamic> jsonList = jsonDecode(cacheData);
        _categories = jsonList.map((e) => CategoryModel.fromJson(e)).toList();
        notifyListeners();
      } else {
        _categories = [];
        notifyListeners();
      }

      _categories = await _service.getCategories();
      
      final jsonString = jsonEncode(_categories.map((e) => e.toJson()).toList());
      await _storage.writeData('categories_cache.json', jsonString);

      _error = null;
    } catch (e) {
      _error = 'Lỗi kết nối khi lấy danh mục';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createCategory(String name, int type, String icon, {double? budgetAmount}) async {
    try {
      final newCategory = await _service.createCategory(name: name, type: type, icon: icon, budgetAmount: budgetAmount);
      _categories.add(newCategory);
      
      final jsonString = jsonEncode(_categories.map((e) => e.toJson()).toList());
      await _storage.writeData('categories_cache.json', jsonString);
      
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> deleteCategory(String id) async {
    try {
      await _service.deleteCategory(id);
      _categories.removeWhere((c) => c.id == id);
      
      final jsonString = jsonEncode(_categories.map((e) => e.toJson()).toList());
      await _storage.writeData('categories_cache.json', jsonString);
      
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      throw Exception(_error);
    }
  }
}
