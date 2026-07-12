import 'package:flutter/material.dart';
import 'dart:convert';
import '../models/transaction_model.dart';
import '../models/voice_analysis_model.dart';
import '../services/transaction_service.dart';
import '../../../core/local_storage/file_storage_service.dart';

class TransactionProvider with ChangeNotifier {
  final TransactionService _service = TransactionService();
  final FileStorageService _storage = FileStorageService();
  
  List<TransactionModel> _transactions = [];
  bool _isLoading = false;
  String? _error;

  String _searchQuery = '';
  DateTime? _startDate;
  DateTime? _endDate;

  List<TransactionModel> get transactions => _transactions;
  bool get isLoading => _isLoading;
  String? get error => _error;

  String get searchQuery => _searchQuery;
  DateTime? get startDate => _startDate;
  DateTime? get endDate => _endDate;

  List<TransactionModel> get filteredTransactions {
    return _transactions.where((t) {
      bool matchesSearch = true;
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        matchesSearch = (t.categoryName.toLowerCase().contains(query)) ||
            (t.note?.toLowerCase().contains(query) ?? false);
      }
      
      bool matchesDate = true;
      if (_startDate != null && _endDate != null) {
        final endOfDay = DateTime(_endDate!.year, _endDate!.month, _endDate!.day, 23, 59, 59);
        final startOfDay = DateTime(_startDate!.year, _startDate!.month, _startDate!.day);
        matchesDate = t.transactionDate.isAfter(startOfDay.subtract(const Duration(seconds: 1))) && 
                      t.transactionDate.isBefore(endOfDay.add(const Duration(seconds: 1)));
      }

      return matchesSearch && matchesDate;
    }).toList();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setDateRange(DateTime? start, DateTime? end) {
    _startDate = start;
    _endDate = end;
    notifyListeners();
  }

  Future<void> loadTransactions() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Load offline cache first
      final cacheData = await _storage.readData('transactions_cache.json');
      if (cacheData != null) {
        final List<dynamic> jsonList = jsonDecode(cacheData);
        _transactions = jsonList.map((e) => TransactionModel.fromJson(e)).toList();
        notifyListeners();
      } else {
        _transactions = [];
        notifyListeners();
      }

      // Fetch from API
      _transactions = await _service.getTransactions();
      
      // Save cache
      final jsonString = jsonEncode(_transactions.map((e) => e.toJson()).toList());
      await _storage.writeData('transactions_cache.json', jsonString);
      
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createTransaction({
    required String walletId,
    required String categoryId,
    required int type,
    required double amount,
    String? note,
    required DateTime transactionDate,
  }) async {
    try {
      final newTransaction = await _service.createTransaction(
        walletId: walletId,
        categoryId: categoryId,
        type: type,
        amount: amount,
        note: note,
        transactionDate: transactionDate,
      );
      
      _transactions.insert(0, newTransaction);
      
      // Update cache
      final jsonString = jsonEncode(_transactions.map((e) => e.toJson()).toList());
      await _storage.writeData('transactions_cache.json', jsonString);
      
      notifyListeners();
      return true;
    } catch (e) {
      if (e.toString().contains('Lỗi kết nối mạng')) {
        // Offline / Error logic: Write to sync queue
        final queueItem = {
          'action': 'create_transaction',
          'data': {
            'walletId': walletId,
            'categoryId': categoryId,
            'type': type,
            'amount': amount,
            'note': note,
            'transactionDate': transactionDate.toIso8601String(),
          }
        };
        await _addToSyncQueue(queueItem);
        // Do not overwrite _error here, just let the UI know it's queued
        return false; // Return false so UI knows it's offline/error
      } else {
        // Backend actually responded with an error, throw it so UI can show it
        throw e;
      }
    }
  }

  Future<bool> deleteTransaction(String id) async {
    try {
      await _service.deleteTransaction(id);
      _transactions.removeWhere((t) => t.id == id);
      
      final jsonString = jsonEncode(_transactions.map((e) => e.toJson()).toList());
      await _storage.writeData('transactions_cache.json', jsonString);
      
      notifyListeners();
      return true;
    } catch (e) {
      final queueItem = {
        'action': 'delete_transaction',
        'data': { 'id': id }
      };
      await _addToSyncQueue(queueItem);
      // Do not overwrite _error here
      return false;
    }
  }

  Future<VoiceAnalysisModel?> analyzeVoice(String text, String model) async {
    try {
      return await _service.analyzeVoice(text, model);
    } catch (e) {
      debugPrint('analyzeVoice error: $e');
      return null;
    }
  }

  Future<void> _addToSyncQueue(Map<String, dynamic> item) async {
    try {
      List<dynamic> queue = [];
      final queueData = await _storage.readData('sync_queue.json');
      if (queueData != null) {
        queue = jsonDecode(queueData);
      }
      queue.add(item);
      await _storage.writeData('sync_queue.json', jsonEncode(queue));
    } catch (e) {
      debugPrint('Failed to write to sync queue: $e');
    }
  }
}
