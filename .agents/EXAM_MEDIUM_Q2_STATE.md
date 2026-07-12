# MEDIUM Q2 – Quản lý State
> **Câu hỏi gốc:** Trong file `{...}`, làm sao để UI biết khi nào dữ liệu đã thay đổi để vẽ lại? Hàm `notifyListeners()` (nếu có) đóng vai trò gì?

---

## Trường hợp 1: `{...}` = **TransactionProvider**

**Thầy hỏi:** Trong `TransactionProvider`, khi gọi `loadTransactions()`, UI (`TransactionScreen`) biết lúc nào cần hiện icon loading, lúc nào hiện danh sách bằng cách nào? Vai trò của `notifyListeners()`?

**Trả lời:**
`TransactionProvider` kế thừa `ChangeNotifier`. Giao tiếp giữa logic và UI dựa trên pattern **Observer (Quan sát)**.

**Quá trình thông báo UI:**
1. Khi bắt đầu hàm `loadTransactions()`, ta set `_isLoading = true;` và gọi **`notifyListeners();`**.
   - UI (bị bọc bởi `Consumer<TransactionProvider>`) nhận được tín hiệu "có sự thay đổi", nó gọi lại hàm `build()`.
   - UI check `if (provider.isLoading)` → vẽ ra `CircularProgressIndicator`.
2. Provider tiếp tục gọi API ngầm (`await _service.getTransactions()`).
3. Khi có dữ liệu, set `_transactions = ...; _isLoading = false;` và gọi lại **`notifyListeners();`**.
   - UI tiếp tục nhận được tín hiệu, gọi lại `build()`.
   - Lần này UI check `!provider.isLoading` và có data → vẽ ra `ListView.builder`.

**Vai trò của `notifyListeners()`:**
Nó là "còi báo động" của Provider. Nếu gán biến `_isLoading = true` mà **không gọi** `notifyListeners()`, UI sẽ **không bao giờ biết** trạng thái đã thay đổi và sẽ không vẽ lại giao diện.

---

## Trường hợp 2: `{...}` = **AddTransactionScreen** (State nội bộ)

**Thầy hỏi:** Trong `AddTransactionScreen`, khi người dùng nhấn chọn "Tiền chi" / "Tiền thu", app đổi màu nút lập tức. Việc này có dùng Provider hay `notifyListeners()` không? Tại sao?

**Trả lời:**
**KHÔNG dùng Provider hay `notifyListeners()`**, mà dùng **`setState()`** của `StatefulWidget`.

**Lý do:**
Biến `_selectedType` (1 cho Tiền thu, 2 cho Tiền chi) là **Local State** (trạng thái cục bộ) – chỉ một mình màn hình `AddTransactionScreen` quan tâm, không màn hình nào khác cần chia sẻ biến này.

**Cách hoạt động:**
```dart
onTap: () => setState(() => _selectedType = 2)
```
Hàm `setState()` trong Flutter sẽ đánh dấu (markNeedsBuild) class State này là "cần cập nhật". Ở frame tiếp theo, Flutter sẽ gọi lại hàm `build()` của màn hình, nút "Tiền chi" kiểm tra thấy `_selectedType == 2` nên hiển thị màu đỏ.

**Tóm tắt:**
- Dùng `setState` cho state cục bộ (form input, toggle button).
- Dùng `Provider` (`ChangeNotifier`) cho state toàn cục (danh sách giao dịch, thông tin user).

---

## Trường hợp 3: `{...}` = **ThemeProvider**

**Thầy hỏi:** Trong `ThemeProvider`, tại sao biến `_themeMode` phải là private và cần có getter `themeMode`? Làm sao để toàn app biết theme vừa đổi?

**Trả lời:**
**Tại sao phải private (`_themeMode`) và có getter (`themeMode`):**
Để **bảo vệ tính toàn vẹn của state**. 
Nếu để `public`, bất kỳ ai cũng có thể viết: `themeProvider.themeMode = ThemeMode.dark;`. Lệnh gán này **không kích hoạt** `notifyListeners()`, khiến UI không bao giờ cập nhật (app bị lỗi hiển thị bất đồng bộ).

Cách đúng là ép mọi sự thay đổi phải đi qua hàm `toggleTheme()`:
```dart
Future<void> toggleTheme(bool isOn) async {
  _themeMode = isOn ? ThemeMode.dark : ThemeMode.light;
  notifyListeners(); // ← BẮT BUỘC
  // ... lưu local storage ...
}
```

**Làm sao toàn app biết:**
`MaterialApp` trong `main.dart` được bọc bởi `Consumer<ThemeProvider>` (hoặc dùng `context.watch<ThemeProvider>()`):
```dart
MaterialApp(
  themeMode: context.watch<ThemeProvider>().themeMode,
  // ...
)
```
Khi `notifyListeners()` được gọi, `MaterialApp` rebuild → Flutter vẽ lại toàn bộ cây Widget với bộ Theme mới.

---

## Trường hợp 4: `{...}` = **DashboardScreen** (Consumer vs context.read)

**Thầy hỏi:** Trong `DashboardScreen`, có chỗ dùng `Consumer<DashboardProvider>`, có chỗ lại dùng `context.read<DashboardProvider>()`. Phân biệt 2 cách lấy State này?

**Trả lời:**
Hai cách phục vụ hai mục đích hoàn toàn khác nhau:

**1. `Consumer<DashboardProvider>` (Tương đương `context.watch`):**
- **Nơi dùng:** Dùng bao bọc khu vực cần vẽ lại UI (thẻ số dư, biểu đồ).
- **Mục đích:** Để **lắng nghe** (listen) sự thay đổi. Khi provider gọi `notifyListeners()`, Widget bên trong `Consumer` sẽ tự động `rebuild()`.

**2. `context.read<DashboardProvider>()`:**
- **Nơi dùng:** Dùng trong sự kiện như `onPressed`, `onRefresh`, hoặc `initState`.
- **Mục đích:** Chỉ để **truy cập 1 lần** (đọc thuộc tính hoặc gọi hàm như `loadDashboardData()`). Nó **không đăng ký lắng nghe** → Dù provider có `notifyListeners()`, nơi gọi `context.read()` cũng KHÔNG BỊ rebuild.

**Lỗi thường gặp:** Nếu gọi `context.watch()` hoặc `Consumer` trong `initState` hoặc ngoài hàm `build`, ứng dụng sẽ văng lỗi vì Flutter cấm đăng ký lắng nghe sai vị trí vòng đời.

---

## Trường hợp 5: `{...}` = **Consumer** trong `TransactionScreen` (Tối ưu Rebuild)

**Thầy hỏi:** Tại sao `TransactionScreen` lại dùng `Consumer<TransactionProvider>` bao bọc phần `body` thay vì bọc ngoài cả `Scaffold`?

**Trả lời:**
Đây là chiến lược **Tối ưu hóa Rebuild (Performance Optimization)**.

Nếu bọc ngoài `Scaffold`:
```dart
Widget build(BuildContext context) {
  return Consumer<TransactionProvider>(
    builder: (context, provider, child) {
      return Scaffold(
        appBar: AppBar(title: Text('Giao dịch')),
        body: ListView(...),
      );
    }
  );
}
```
Mỗi khi danh sách giao dịch thay đổi (`notifyListeners()`), toàn bộ `Scaffold` và `AppBar` tĩnh đều phải vẽ lại một cách không cần thiết, tiêu tốn CPU.

Cách đang làm đúng:
```dart
Scaffold(
  appBar: AppBar(title: Text('Giao dịch')), // Phần tĩnh, KHÔNG vẽ lại
  body: Consumer<TransactionProvider>(      // Chỉ phần này vẽ lại
    builder: (context, provider, child) => ListView(...),
  ),
);
```
Chỉ phần `body` (danh sách) chịu ảnh hưởng của `TransactionProvider`, do đó khi `notifyListeners()` chạy, chỉ khu vực `body` thay đổi, giúp app chạy mượt hơn rất nhiều.

---

## Trường hợp 6: `{...}` = Lỗi gọi `notifyListeners()` giữa lúc đang vẽ

**Thầy hỏi:** Điều gì sẽ xảy ra nếu ta gọi hàm `loadTransactions()` chứa `notifyListeners()` bên trong hàm `build()` của màn hình?

**Trả lời:**
Ứng dụng sẽ bị **Crash / Quăng Exception đỏ lòm**: `setState() or markNeedsBuild() called during build`.

**Lý do:**
Hàm `build()` của màn hình đang trong quá trình lắp ráp giao diện (khóa khung hình). Giữa lúc đó, bạn gọi `loadTransactions()` làm kích hoạt `notifyListeners()`. Provider la lên "Vẽ lại đi!", nhưng Flutter sẽ phàn nàn: "Tôi đang vẽ dở tay khung hình hiện tại rồi, làm sao bắt đầu vẽ lại từ đầu được!".

**Cách giải quyết:**
Đây là lý do mọi hàm fetch data khởi tạo phải nằm trong `initState()` và bọc bởi `addPostFrameCallback`:
```dart
@override
void initState() {
  super.initState();
  WidgetsBinding.instance.addPostFrameCallback((_) {
    // Chờ vẽ xong frame đầu tiên mới gọi load data
    context.read<TransactionProvider>().loadTransactions();
  });
}
```

---

## Trường hợp 7: `{...}` = **CategoryProvider** và `CategoryBottomSheet`

**Thầy hỏi:** Khi xóa một danh mục thông qua `CategoryProvider`, làm sao để `CategoryBottomSheet` tự biến mất ô đó? Có cần viết lại hàm `setState` ở màn hình không?

**Trả lời:**
**Tuyệt đối KHÔNG cần `setState()`** ở `CategoryBottomSheet`.

**Luồng hoạt động:**
1. User bấm xóa (giả sử có tính năng này).
2. Gọi `context.read<CategoryProvider>().deleteCategory(id);`
3. Trong Provider, danh sách `_categories` bị cập nhật: `_categories.remove(...)`.
4. Provider gọi `notifyListeners()`.
5. `CategoryBottomSheet` vốn đang bọc `GridView` bằng `Consumer<CategoryProvider>`. Nó lập tức nhận lệnh vẽ lại.
6. Nó lấy list `provider.categories` mới (đã mất đi một ô) và render ra lưới danh mục mới.

Tất cả diễn ra hoàn toàn tự động theo cơ chế **React-ive** (Phản ứng). Đây là thế mạnh lớn nhất của quản lý State tập trung so với truyền dữ liệu qua callback (`setState` tay chân).

---

## Trường hợp 8: `{...}` = Cập nhật 2 trạng thái liên tiếp trong Provider

**Thầy hỏi:** Trong `loadTransactions()`, có chỗ gọi `_isLoading = true; notifyListeners();`, sau đó bắt data xong lại gọi `_isLoading = false; notifyListeners();`. Có thể bỏ gọi `notifyListeners()` lần 1 được không?

**Trả lời:**
**KHÔNG ĐƯỢC bỏ.** Nếu bỏ lần 1, UI sẽ không bao giờ biết app đang vào trạng thái "Tải dữ liệu" để hiện vòng tròn xoay `CircularProgressIndicator`.

Nếu bỏ `notifyListeners()` lần 1:
- User bấm mở màn hình.
- `_isLoading = true` ngầm, UI vẫn thấy giao diện trắng (hoặc danh sách rỗng cũ).
- 2 giây sau (gọi API xong), `_isLoading = false`, `notifyListeners()` chạy. UI bùm một phát xuất hiện danh sách giao dịch.
- Trải nghiệm người dùng (UX) rất tệ, user tưởng app bị đơ trong 2 giây đó.

Việc gọi `notifyListeners()` nhiều lần là thiết kế tiêu chuẩn để UI phản ánh chính xác **từng giai đoạn** của tiến trình xử lý (Đang tải → Có lỗi / Có dữ liệu).
