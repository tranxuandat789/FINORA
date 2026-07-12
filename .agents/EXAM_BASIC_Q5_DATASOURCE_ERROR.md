# BASIC Q5 – Nguồn dữ liệu & Bắt lỗi
> **Câu hỏi gốc:** Dữ liệu hiển thị ở `{...}` được lấy từ API hay Local Storage? Chỉ ra file chứa hàm gọi dữ liệu. Nếu mất mạng hoặc API lỗi 500, đoạn code nào sẽ xử lý và báo lỗi lên UI?

*(Câu B4 – Responsive bỏ qua vì app chỉ hỗ trợ portrait)*

---

## Trường hợp 1: `{...}` = Danh sách giao dịch trong **TransactionScreen**

**Thầy hỏi:** Dữ liệu danh sách giao dịch được lấy từ đâu? File nào chứa hàm gọi? Mất mạng thì xử lý thế nào?

**Trả lời:**
Dữ liệu lấy từ **cả hai**: Local Storage cache trước, sau đó fetch API.

**Luồng dữ liệu:**
```
TransactionScreen.initState()
  → TransactionProvider.loadTransactions()
    → FileStorageService.readData('transactions_cache.json')  [Local Storage trước]
    → TransactionService.getTransactions() → GET /api/transactions  [API sau]
    → FileStorageService.writeData() [Lưu cache mới]
```

**File chứa hàm gọi:**
- `transaction_provider.dart` → hàm `loadTransactions()`
- `transaction_service.dart` → hàm `getTransactions()`

**Xử lý mất mạng/lỗi 500:**

```dart
// transaction_service.dart dòng ~17-22
} on DioException catch (e) {
  if (e.response != null && e.response?.data is Map<String, dynamic>) {
    throw Exception(e.response?.data['message'] ?? 'Lỗi server');
  }
  throw Exception('Lỗi kết nối mạng');  // ← mất mạng
}
```

```dart
// transaction_provider.dart dòng ~45-49
} catch (e) {
  _error = e.toString();
} finally {
  _isLoading = false;
  notifyListeners();
}
```

UI hiển thị lỗi:
```dart
// transaction_screen.dart dòng ~42-44
if (provider.error != null && provider.transactions.isEmpty) {
  return Center(child: Text(provider.error!, style: GoogleFonts.inter(color: Colors.red)));
}
```

**Quan trọng:** Nếu đã có cache và chỉ mất mạng khi re-fetch, `_transactions` vẫn giữ data từ cache → UI vẫn hiển thị được.

---

## Trường hợp 2: `{...}` = Dashboard (Trang chủ tổng số dư)

**Thầy hỏi:** Dữ liệu tổng số dư, chi tiêu tháng này trong Dashboard lấy từ đâu? Nếu API lỗi 500, màn hình sẽ hiện gì?

**Trả lời:**
Dữ liệu từ `DashboardProvider.loadDashboardData()` gọi API riêng.

**Luồng:**
```
DashboardScreen.initState()
  → DashboardProvider.loadDashboardData()
    → DashboardService → GET /api/dashboard  (hoặc tổng hợp)
```

Xử lý lỗi trong `Consumer<DashboardProvider>`:
```dart
// dashboard_screen.dart dòng ~153-167
if (dashboardProvider.error != null && dashboardProvider.data == null) {
  return Center(
    child: Column(
      children: [
        Icon(Icons.error_outline, color: Colors.red, size: 48),
        Text('Lỗi: ${dashboardProvider.error}'),
        TextButton(
          onPressed: () => context.read<DashboardProvider>().loadDashboardData(),
          child: Text('Thử lại'),  // ← nút retry
        )
      ],
    ),
  );
}
```

Khi lỗi 500: API trả `response.data['message']` → `DashboardService` throw Exception → `DashboardProvider._error = message` → `notifyListeners()` → UI hiện màn hình lỗi + nút "Thử lại".

---

## Trường hợp 3: `{...}` = Danh sách danh mục trong **CategoryBottomSheet**

**Thầy hỏi:** Danh mục hiển thị trong BottomSheet lấy từ đâu? Nếu API lỗi khi load, BottomSheet hiện gì?

**Trả lời:**
Danh mục load bởi `CategoryProvider.loadCategories()`, được gọi trong `DashboardScreen.initState()`:

```dart
// dashboard_screen.dart dòng ~48-50
WidgetsBinding.instance.addPostFrameCallback((_) {
  context.read<DashboardProvider>().loadDashboardData();
  context.read<CategoryProvider>().loadCategories();  // ← load sẵn khi vào app
});
```

**Luồng cache:**
```
CategoryProvider.loadCategories()
  → FileStorageService.readData('categories_cache.json')  [cache trước]
  → CategoryService.getCategories() → GET /api/categories  [API sau]
  → Lưu cache mới
```

**Xử lý lỗi trong CategoryBottomSheet:**
```dart
// category_bottom_sheet.dart dòng ~52-54
if (provider.isLoading && provider.categories.isEmpty) {
  return const Center(child: CircularProgressIndicator());
}
```

Nếu API lỗi: `_error = 'Lỗi kết nối khi lấy danh mục'` nhưng BottomSheet **không có UI hiển thị lỗi** – chỉ hiện lưới trống hoặc lưới từ cache cũ. Đây là điểm có thể cải thiện.

---

## Trường hợp 4: `{...}` = Thông tin người dùng (tên, avatar) trong **DashboardScreen AppBar**

**Thầy hỏi:** Tên người dùng hiển thị trên AppBar Dashboard lấy từ đâu? Nếu không có tên, hiện gì?

**Trả lời:**
Không lấy từ API – lấy trực tiếp từ **SharedPreferences** (đã lưu lúc login):

```dart
// dashboard_screen.dart dòng ~199-200
final authProvider = Provider.of<AuthProvider>(context, listen: false);
final String fullName = authProvider.user?['fullName'] ?? 'Người dùng';
```

`authProvider.user` là `Map<String, dynamic>?` được restore từ SharedPreferences trong `checkAuthStatus()`:

```dart
// auth_provider.dart dòng ~20-36
Future<void> checkAuthStatus() async {
  final prefs = await SharedPreferences.getInstance();
  final userStr = prefs.getString('user');
  if (userStr != null && token != null) {
    _user = Map<String, dynamic>.from(jsonDecode(userStr));
  }
}
```

Nếu `fullName` null → fallback `'Người dùng'` (toán tử `??`).

---

## Trường hợp 5: `{...}` = Kết quả phân tích giọng nói trong **FloatingVoiceButton**

**Thầy hỏi:** Kết quả phân tích giọng nói lấy từ đâu? Nếu AI phân tích thất bại (API lỗi), xử lý thế nào?

**Trả lời:**
Gọi API AI phân tích giọng nói:
```
FloatingVoiceButton._handleLongPressEnd()
  → TransactionProvider.analyzeVoice(text)
    → TransactionService.analyzeVoice(text)
      → POST /api/transactions/analyze-voice  {text: "..."}
```

**Xử lý khi AI thất bại:**
```dart
// transaction_provider.dart dòng ~124-131
Future<VoiceAnalysisModel?> analyzeVoice(String text) async {
  try {
    return await _service.analyzeVoice(text);
  } catch (e) {
    debugPrint('analyzeVoice error: $e');
    return null;  // ← trả về null thay vì throw
  }
}
```

```dart
// floating_voice_button.dart dòng ~197-199
if (result != null) {
  // Mở AddTransactionScreen với data từ AI
} else {
  SnackBarUtils.showTopSnackBar(
    context,
    'Không thể phân tích giọng nói. Vui lòng thử lại.',
    isSuccess: false,
  );
}
```

Nếu lỗi → `result = null` → hiện SnackBar thông báo → không mở màn hình thêm giao dịch.

---

## Trường hợp 6: `{...}` = Thao tác tạo giao dịch trong **AddTransactionScreen**

**Thầy hỏi:** Khi bấm "Lưu giao dịch" và mất mạng, dữ liệu có bị mất không? Code xử lý offline thế nào?

**Trả lời:**
**Không bị mất** – có cơ chế **offline queue**:

```dart
// transaction_provider.dart dòng ~80-95
} catch (e) {
  if (e.toString().contains('Lỗi kết nối mạng')) {
    // Mất mạng → lưu vào sync_queue
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
    await _addToSyncQueue(queueItem);  // lưu vào sync_queue.json
    return false;  // ← UI biết là offline
  } else {
    throw e;  // ← lỗi từ backend (401, 400...) thì throw
  }
}
```

UI phản hồi:
```dart
// add_transaction_screen.dart dòng ~157-159
} else {
  SnackBarUtils.showTopSnackBar(
    context,
    'Không thể kết nối. Giao dịch đã được lưu tạm offline.',
    isSuccess: false,
  );
}
```

Data được lưu vào `sync_queue.json` và sẽ sync lên server khi có mạng trở lại (qua `SyncProvider`).

---

## Trường hợp 7: `{...}` = Giao dịch trong **TransactionProvider** khi API 500

**Thầy hỏi:** Nếu API `/api/transactions` trả về HTTP 500, `TransactionProvider` xử lý thế nào? User có thấy data cũ không?

**Trả lời:**
```dart
// transaction_provider.dart dòng ~25-50
Future<void> loadTransactions() async {
  _isLoading = true;
  _error = null;
  notifyListeners();
  try {
    // Bước 1: Load cache trước (user thấy data ngay)
    final cacheData = await _storage.readData('transactions_cache.json');
    if (cacheData != null) {
      _transactions = jsonList.map((e) => TransactionModel.fromJson(e)).toList();
      notifyListeners();  // UI update ngay với cache
    }
    // Bước 2: Gọi API
    _transactions = await _service.getTransactions();  // ← ném Exception nếu 500
    // Bước 3: Lưu cache mới (chỉ đến đây nếu API thành công)
    await _storage.writeData('transactions_cache.json', ...);
  } catch (e) {
    _error = e.toString();   // ← lưu lỗi
  } finally {
    _isLoading = false;
    notifyListeners();       // ← UI update
  }
}
```

Kết quả khi API 500:
- `_error` = "Exception: Lỗi server"
- `_transactions` vẫn là **data từ cache** (không bị reset về [])
- UI hiện data cũ + không hiện màn hình lỗi (vì `transactions.isNotEmpty`)

---

## Trường hợp 8: `{...}` = Màn hình **LoginScreen** – Xử lý lỗi đăng nhập

**Thầy hỏi:** Khi user nhập sai mật khẩu và API trả về 401, màn hình Login xử lý lỗi thế nào?

**Trả lời:**
```dart
// auth_provider.dart dòng ~62-76
final response = await _repository.login(email, password);
if (response['success'] == true) {
  // Thành công
  onSuccess();
} else {
  onError(response['message'] ?? 'Đăng nhập thất bại');  // ← callback lỗi
}
```

```dart
// login_screen.dart dòng ~187-189
onError: (msg) {
  SnackBarUtils.showTopSnackBar(context, msg, isSuccess: false);
},
```

Luồng: API 401 → `repository.login()` trả `{'success': false, 'message': 'Sai mật khẩu'}` → `onError('Sai mật khẩu')` → SnackBar đỏ hiện ở trên cùng màn hình.

---

## Trường hợp 9: `{...}` = Thao tác xóa giao dịch

**Thầy hỏi:** Khi xóa giao dịch và mất mạng, `deleteTransaction()` xử lý thế nào?

**Trả lời:**
```dart
// transaction_provider.dart dòng ~103-121
Future<bool> deleteTransaction(String id) async {
  try {
    await _service.deleteTransaction(id);
    _transactions.removeWhere((t) => t.id == id);  // xóa khỏi local list
    await _storage.writeData(...);  // cập nhật cache
    notifyListeners();
    return true;
  } catch (e) {
    // Mất mạng → đưa vào sync queue để xóa sau
    final queueItem = {
      'action': 'delete_transaction',
      'data': {'id': id}
    };
    await _addToSyncQueue(queueItem);
    return false;
  }
}
```

**Khác với createTransaction:** `deleteTransaction` KHÔNG kiểm tra `'Lỗi kết nối mạng'` – mọi exception đều vào sync queue. Đây là điểm có thể cải thiện.

---

## Trường hợp 10: `{...}` = Tạo danh mục trong **AddCategoryScreen**

**Thầy hỏi:** Khi bấm "Lưu danh mục" và API lỗi, màn hình hiện gì?

**Trả lời:**
```dart
// add_category_screen.dart dòng ~57-72
final success = await context.read<CategoryProvider>().createCategory(...);

setState(() => _isLoading = false);

if (success && mounted) {
  SnackBarUtils.showTopSnackBar(context, 'Thêm danh mục thành công', isSuccess: true);
  Navigator.pop(context);
} else if (mounted) {
  final err = context.read<CategoryProvider>().error;
  SnackBarUtils.showTopSnackBar(context, err ?? 'Có lỗi xảy ra', isSuccess: false);
}
```

```dart
// category_provider.dart dòng ~59-63
} catch (e) {
  _error = e.toString();   // lưu lỗi
  notifyListeners();
  return false;            // báo thất bại
}
```

Luồng lỗi: API lỗi → `createCategory()` catch → `_error = message` → return `false` → UI đọc `provider.error` → hiện SnackBar đỏ với message lỗi.
