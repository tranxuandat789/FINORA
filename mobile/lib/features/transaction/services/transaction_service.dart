import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../models/transaction_model.dart';
import '../models/voice_analysis_model.dart';

class TransactionService {
  final ApiClient _apiClient = ApiClient();

  Future<List<TransactionModel>> getTransactions() async {
    try {
      final response = await _apiClient.dio.get('/api/transactions');
      if (response.data['success'] == true) {
        final List<dynamic> data = response.data['data'];
        return data.map((json) => TransactionModel.fromJson(json)).toList();
      }
      throw Exception(response.data['message'] ?? 'Lỗi tải danh sách giao dịch');
    } on DioException catch (e) {
      if (e.response != null && e.response?.data is Map<String, dynamic>) {
        throw Exception(e.response?.data['message'] ?? 'Lỗi server');
      }
      throw Exception('Lỗi kết nối mạng');
    }
  }

  Future<TransactionModel> createTransaction({
    required String walletId,
    required String categoryId,
    required int type,
    required double amount,
    String? note,
    required DateTime transactionDate,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        '/api/transactions',
        data: {
          'walletId': walletId,
          'categoryId': categoryId,
          'type': type,
          'amount': amount,
          'note': note,
          'transactionDate': transactionDate.toIso8601String(),
        },
      );
      if (response.data['success'] == true) {
        return TransactionModel.fromJson(response.data['data']);
      }
      throw Exception(response.data['message'] ?? 'Lỗi tạo giao dịch');
    } on DioException catch (e) {
      if (e.response != null && e.response?.data is Map<String, dynamic>) {
        throw Exception(e.response?.data['message'] ?? 'Lỗi server');
      }
      throw Exception('Lỗi kết nối mạng');
    }
  }

  Future<void> deleteTransaction(String id) async {
    try {
      final response = await _apiClient.dio.delete('/api/transactions/$id');
      if (response.data['success'] != true) {
        throw Exception(response.data['message'] ?? 'Lỗi xóa giao dịch');
      }
    } on DioException catch (e) {
      if (e.response != null && e.response?.data is Map<String, dynamic>) {
        throw Exception(e.response?.data['message'] ?? 'Lỗi server');
      }
      throw Exception('Lỗi kết nối mạng');
    }
  }

  Future<VoiceAnalysisModel> analyzeVoice(String text, String model) async {
    try {
      final response = await _apiClient.dio.post(
        '/api/transactions/analyze-voice',
        data: {
          'text': text,
          'model': model,
        },
      );
      if (response.data['success'] == true) {
        return VoiceAnalysisModel.fromJson(response.data['data']);
      }
      throw Exception(response.data['message'] ?? 'Lỗi phân tích giọng nói');
    } on DioException catch (e) {
      if (e.response != null && e.response?.data is Map<String, dynamic>) {
        throw Exception(e.response?.data['message'] ?? 'Lỗi server');
      }
      throw Exception('Lỗi kết nối mạng');
    }
  }
}
