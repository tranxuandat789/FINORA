# BASIC Q6 – Vòng đời Widget (Lifecycle)
> **Câu hỏi gốc:** Hàm `initState` và `dispose` trong màn hình `{...}` đang thực hiện nhiệm vụ gì? Điều gì sẽ xảy ra nếu không có `controller/listener` không được hủy trong `dispose`?

---

## Trường hợp 1: `{...}` = **AddTransactionScreen**

**Thầy hỏi:** `initState` và `dispose` trong `AddTransactionScreen` làm gì? Nếu không dispose `_amountController`, hậu quả là gì?

**Trả lời:**

**`initState` (dòng ~29-57):**
```dart
@override
void initState() {
  super.initState();
  // 1. Gắn listener format số tiền
  _amountController.addListener(_formatAmount);
  // 2. Set wallet mặc định
  _selectedWalletId = '00000000-0000-0000-0000-000000000000';
  _selectedCategoryId = null;
  // 3. Pre-fill từ voice data (nếu được mở từ FloatingVoiceButton)
  if (widget.voiceData != null) {
    if (widget.voiceData!['amount'] != null) { _amountController.text = ...; }
    if (widget.voiceData!['note'] != null) { _noteController.text = ...; }
    // ...
  }
}
```

**`dispose` (dòng ~77-82):**
```dart
@override
void dispose() {
  _amountController.removeListener(_formatAmount);  // ← hủy listener TRƯỚC
  _amountController.dispose();    // ← giải phóng TextEditingController
  _noteController.dispose();      // ← giải phóng TextEditingController
  super.dispose();
}
```

**Nếu KHÔNG dispose:**
- `TextEditingController` tồn tại trong bộ nhớ sau khi màn hình bị đóng
- Listener `_formatAmount` vẫn chạy → mỗi lần text thay đổi, callback vẫn được gọi dù widget đã không còn tồn tại
- Gây **memory leak** – RAM tăng dần nếu user mở/đóng màn hình nhiều lần

---

## Trường hợp 2: `{...}` = **TransactionScreen**

**Thầy hỏi:** `initState` trong `TransactionScreen` làm gì? Tại sao phải dùng `addPostFrameCallback`?

**Trả lời:**

```dart
// transaction_screen.dart dòng ~17-22
@override
void initState() {
  super.initState();
  WidgetsBinding.instance.addPostFrameCallback((_) {
    context.read<TransactionProvider>().loadTransactions();
  });
}
```

**Tại sao `addPostFrameCallback`?**
Trong `initState`, widget **chưa được render hoàn toàn** vào cây widget. Nếu gọi `context.read<>()` trực tiếp trong `initState`, Flutter có thể throw lỗi vì `BuildContext` chưa sẵn sàng cho `Provider`.

`addPostFrameCallback` đảm bảo callback chỉ chạy **sau khi frame đầu tiên được render xong** → `context` đã an toàn để sử dụng.

`TransactionScreen` không có `dispose` riêng vì **không tạo controller hay stream** nào – chỉ đọc từ Provider.

---

## Trường hợp 3: `{...}` = **AddCategoryScreen**

**Thầy hỏi:** `AddCategoryScreen` có `initState` không? `dispose` cần làm gì? Nếu quên dispose `_nameController` thì sao?

**Trả lời:**

`AddCategoryScreen` **KHÔNG có `initState`** tường minh – dùng giá trị khởi tạo trực tiếp:
```dart
final _nameController = TextEditingController();
String _selectedIcon = 'category';
bool _isLoading = false;
final List<Map<String, dynamic>> _availableIcons = [...];
final _budgetController = TextEditingController();
```

**`dispose` được gọi tự động bởi Flutter** khi màn hình bị pop, nhưng **chưa được override** trong code hiện tại → đây là một **bug tiềm ẩn**!

Đúng ra phải có:
```dart
// CẦN THÊM vào AddCategoryScreen
@override
void dispose() {
  _nameController.dispose();
  _budgetController.dispose();
  super.dispose();
}
```

Nếu không dispose:
- 2 `TextEditingController` bị rò rỉ bộ nhớ
- Flutter có thể log warning: `A TextEditingController was garbage collected while still having listeners.`

---

## Trường hợp 4: `{...}` = **FloatingVoiceButton** (nhiều controller)

**Thầy hỏi:** `FloatingVoiceButton` có nhiều controller phức tạp. `initState` và `dispose` làm gì? Nếu thiếu 1 trong các dispose, hậu quả thế nào?

**Trả lời:**

**`initState` (dòng ~64-111):**
```dart
@override
void initState() {
  super.initState();
  // 1. AnimationController cho bobbing (lên xuống)
  _bobbingController = AnimationController(vsync: this, duration: Duration(milliseconds: 1200));
  _bobbingAnimation = Tween<double>(begin: -3.0, end: 3.0).animate(...);
  _bobbingController.repeat(reverse: true);
  
  // 2. AnimationController cho flight (bay sang ngang)
  _flightController = AnimationController(vsync: this, duration: Duration(milliseconds: 4500));
  _flightController.addListener(() { ... setState(...) });
  _flightController.addStatusListener((status) { ... _idleRestTimer = Timer(...) });
  
  // 3. AnimationController cho Lottie
  _lottieController = AnimationController(vsync: this, duration: Duration(seconds: 1));
  
  // 4. Ticker tùy chỉnh (thay thế vsync đơn giản)
  _lottieTicker = createTicker((elapsed) { ... });
  _lottieTicker.start();
}
```

**`dispose` (dòng ~206-215):**
```dart
@override
void dispose() {
  _bobbingController.dispose();
  _flightController.dispose();
  _lottieController.dispose();
  _lottieTicker.dispose();   // ← Ticker phải dispose riêng
  _inactivityTimer?.cancel();  // ← Timer cancel (không dispose, chỉ cancel)
  _idleRestTimer?.cancel();
  super.dispose();
}
```

**Nếu thiếu dispose:**
- `AnimationController` không dispose → **memory leak + vsync vẫn chạy**
- `Ticker` không dispose → tiếp tục gọi callback dù widget đã chết → crash hoặc `setState` trên dead widget
- `Timer` không cancel → timer vẫn fire → gọi `mounted` check không ngăn được nếu callback phức tạp

---

## Trường hợp 5: `{...}` = **DashboardScreen**

**Thầy hỏi:** `initState` trong `DashboardScreen` làm gì? Màn hình này có cần `dispose` không?

**Trả lời:**

```dart
// dashboard_screen.dart dòng ~44-51
@override
void initState() {
  super.initState();
  WidgetsBinding.instance.addPostFrameCallback((_) {
    context.read<DashboardProvider>().loadDashboardData();
    context.read<CategoryProvider>().loadCategories();
  });
}
```

Tương tự `TransactionScreen`: dùng `addPostFrameCallback` để an toàn với context.

`DashboardScreen` **không có `dispose`** vì:
- Không tạo `AnimationController`, `Timer`, `StreamSubscription`
- `_selectedIndex` là `int` đơn giản – tự giải phóng
- `_pages` là `List<Widget>` tĩnh – không cần cleanup

---

## Trường hợp 6: `{...}` = **LoginScreen**

**Thầy hỏi:** `dispose` trong `LoginScreen` làm gì? Nếu không dispose, có bị crash không?

**Trả lời:**

```dart
// login_screen.dart dòng ~24-29
@override
void dispose() {
  _emailController.dispose();
  _passwordController.dispose();
  super.dispose();
}
```

Không có `initState` vì không cần setup thêm gì.

Nếu không dispose:
- 2 controller tồn tại sau khi Login thành công (user push sang Dashboard)
- Không crash ngay nhưng **memory leak** – GC không thể thu hồi
- Nếu user back về Login nhiều lần: ngày càng nhiều controller bị rò rỉ

---

## Trường hợp 7: `{...}` = **TransactionProvider** (không phải Widget)

**Thầy hỏi:** `TransactionProvider` có `initState/dispose` không? Nó có lifecycle riêng không?

**Trả lời:**
`TransactionProvider` kế thừa `ChangeNotifier` – **không có `initState/dispose` theo nghĩa Widget**.

Nhưng `ChangeNotifier` có phương thức `dispose()` để hủy listeners:
```dart
// TransactionProvider sẽ tự động bị dispose khi
// Provider bị xóa khỏi cây widget
// Nhưng app này dùng MultiProvider ở main.dart
// → Provider sống suốt vòng đời app
```

**Vòng đời của Provider** được quản lý bởi `MultiProvider` trong `main.dart` – Provider chỉ bị dispose khi app kết thúc hoặc Provider được remove khỏi widget tree.

---

## Trường hợp 8: `{...}` = Hàm `_formatAmount` trong AddTransactionScreen

**Thầy hỏi:** Nếu không gọi `_amountController.removeListener(_formatAmount)` trong `dispose`, điều gì xảy ra cụ thể?

**Trả lời:**
```dart
// Trong dispose - nếu bỏ removeListener:
@override
void dispose() {
  // _amountController.removeListener(_formatAmount); ← BỎ DÒNG NÀY
  _amountController.dispose();
  _noteController.dispose();
  super.dispose();
}
```

Khi `dispose()` được gọi:
1. `_amountController.dispose()` được gọi → controller bị giải phóng
2. Nhưng listener `_formatAmount` vẫn đang **đăng ký trong internal listener list**
3. Vì controller đã dispose → listener list cũng bị xóa → không crash ngay

Tuy nhiên, thứ tự đúng là **removeListener trước, sau đó dispose**. Nếu không, trong một số trường hợp (ví dụ controller được reuse), listener cũ vẫn tồn tại và gây **double-call** hoặc gọi callback trên widget đã chết.

**Best practice:**
```dart
@override
void dispose() {
  _amountController.removeListener(_formatAmount);  // 1. Remove listener
  _amountController.dispose();                       // 2. Dispose controller
  super.dispose();                                   // 3. Luôn gọi super cuối
}
```

---

## Trường hợp 9: `{...}` = Kiểm tra `mounted` trong **AddTransactionScreen**

**Thầy hỏi:** Trong `_saveTransaction()`, có đoạn `if (mounted) Navigator.pop(context)`. `mounted` là gì và tại sao cần kiểm tra?

**Trả lời:**

```dart
// add_transaction_screen.dart dòng ~155-163
final success = await context.read<TransactionProvider>().createTransaction(...);

if (success) {
  if (mounted) Navigator.pop(context);  // ← kiểm tra mounted
} else {
  if (mounted) SnackBarUtils.showTopSnackBar(...);
}
```

`mounted` là thuộc tính của `State` class, trả về `true` nếu widget **đang còn trong widget tree**.

**Tại sao cần kiểm tra?**
`createTransaction()` là `async` → chờ network request → mất thời gian. Trong khi đó, user có thể:
- Bấm nút Back để đóng màn hình
- App bị minimize

Khi `await` hoàn thành, nếu widget đã bị `dispose()`, mà ta vẫn gọi `Navigator.pop(context)` hoặc `setState()` → **throw exception**: `setState() called after dispose()`.

Kiểm tra `mounted` trước khi tương tác với UI sau `await` là **best practice bắt buộc**.
