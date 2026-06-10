import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../models/category_model.dart';

class CategoryService {
  final Dio _dio = ApiClient().dio;

  Future<List<CategoryModel>> getCategories() async {
    final response = await _dio.get('/api/Categories');
    if (response.statusCode == 200 && response.data['success'] == true) {
      final List<dynamic> data = response.data['data'];
      return data.map((json) => CategoryModel.fromJson(json)).toList();
    }
    throw Exception('Failed to load categories');
  }

  Future<CategoryModel> createCategory({
    required String name,
    required int type,
    String? icon,
    double? budgetAmount,
  }) async {
    final response = await _dio.post(
      '/api/Categories',
      data: {
        'name': name,
        'type': type,
        'icon': icon,
        if (budgetAmount != null) 'budgetAmount': budgetAmount,
      },
    );
    if (response.statusCode == 200 && response.data['success'] == true) {
      return CategoryModel.fromJson(response.data['data']);
    }
    throw Exception(response.data['message'] ?? 'Failed to create category');
  }

  Future<void> deleteCategory(String id) async {
    final response = await _dio.delete('/api/Categories/$id');
    if (response.statusCode != 200 || response.data['success'] != true) {
      throw Exception(response.data['message'] ?? 'Failed to delete category');
    }
  }
}
