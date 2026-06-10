import 'package:flutter/material.dart';
import 'dart:convert';
import '../../../core/local_storage/file_storage_service.dart';
import '../../transaction/services/transaction_service.dart';

class SyncProvider with ChangeNotifier {
  final FileStorageService _storage = FileStorageService();
  final TransactionService _transactionService = TransactionService();

  bool _isSyncing = false;
  int _pendingCount = 0;
  String? _error;

  bool get isSyncing => _isSyncing;
  int get pendingCount => _pendingCount;
  String? get error => _error;

  SyncProvider() {
    checkPendingItems();
  }

  Future<void> checkPendingItems() async {
    try {
      final data = await _storage.readData('sync_queue.json');
      if (data != null) {
        final List<dynamic> queue = jsonDecode(data);
        _pendingCount = queue.length;
      } else {
        _pendingCount = 0;
      }
      notifyListeners();
    } catch (e) {
      _pendingCount = 0;
    }
  }

  Future<bool> syncNow() async {
    if (_isSyncing || _pendingCount == 0) return false;

    _isSyncing = true;
    _error = null;
    notifyListeners();

    try {
      final data = await _storage.readData('sync_queue.json');
      if (data == null) {
        _isSyncing = false;
        notifyListeners();
        return true;
      }

      List<dynamic> queue = jsonDecode(data);
      List<dynamic> failedItems = [];

      for (var item in queue) {
        try {
          final action = item['action'];
          final payload = item['data'];

          if (action == 'create_transaction') {
            await _transactionService.createTransaction(
              walletId: payload['walletId'],
              categoryId: payload['categoryId'],
              type: payload['type'],
              amount: payload['amount'].toDouble(),
              note: payload['note'],
              transactionDate: DateTime.parse(payload['transactionDate']),
            );
          } else if (action == 'delete_transaction') {
            await _transactionService.deleteTransaction(payload['id']);
          }
          // If successful, we don't add to failedItems
        } catch (e) {
          debugPrint('Sync item failed: $e');
          if (e.toString().contains('Lỗi kết nối mạng')) {
            failedItems.add(item); // Keep it for next sync if it's a network error
          } else {
            // If it's a server error (e.g. invalid WalletId), discard it so the queue doesn't get stuck forever
            debugPrint('Discarding invalid sync item');
          }
        }
      }

      if (failedItems.isEmpty) {
        await _storage.deleteData('sync_queue.json');
        _pendingCount = 0;
      } else {
        await _storage.writeData('sync_queue.json', jsonEncode(failedItems));
        _pendingCount = failedItems.length;
        _error = 'Một số mục không thể đồng bộ. Sẽ thử lại sau.';
      }

      _isSyncing = false;
      notifyListeners();
      return failedItems.isEmpty;
    } catch (e) {
      _isSyncing = false;
      _error = 'Lỗi đồng bộ: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }
}
