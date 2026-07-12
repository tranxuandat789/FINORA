# MEDIUM Q6 – Điều hướng (Navigation)
> **Câu hỏi gốc:** Phân tích cách chuyển màn hình từ `{A}` sang `{B}`. Tại sao dùng `Navigator.push` thay vì `pushReplacement`? Làm sao để truyền dữ liệu giữa hai màn hình này?

---

## Trường hợp 1: `{A}` = **DashboardScreen** → `{B}` = **AddTransactionScreen** (Bấm dấu +)

**Thầy hỏi:** Tại sao nút "+" trên Dashboard dùng `Navigator.push` thay vì `Navigator.pushReplacement` để chuyển sang trang Thêm giao dịch? Nếu lưu giao dịch thành công, làm sao để Dashboard biết mà load lại data?

**Trả lời:**
**Vì sao dùng `push`:**
- Màn hình Dashboard là màn hình gốc (Root Screen). Giao dịch mới chỉ là một form pop-up phụ.
- Dùng `push` sẽ xếp chồng (stack) AddTransactionScreen lên trên Dashboard. Khi xong, chỉ cần gọi `Navigator.pop(context)` để tháo màn hình ra và quay về Dashboard.
- Nếu dùng `pushReplacement`, màn hình Dashboard bị **hủy khỏi bộ nhớ**. Khi back lại, ứng dụng sẽ tắt hoặc phải khởi tạo lại toàn bộ Dashboard từ đầu (chớp màn hình, load API lại tốn thời gian).

**Làm sao để Dashboard biết load lại:**
Cơ chế `await` của Navigator:
```dart
// dashboard_screen.dart
onPressed: () async {
  await Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => const AddTransactionScreen()),
  );
  // Dòng code dưới đây chỉ chạy KHI VÀ CHỈ KHI AddTransactionScreen đã bị pop()
  if (mounted) {
    context.read<DashboardProvider>().loadDashboardData();
  }
}
```

---

## Trường hợp 2: `{A}` = **LoginScreen** → `{B}` = **DashboardScreen**

**Thầy hỏi:** Khi đăng nhập thành công, app gọi `Navigator.pushReplacement`. Tại sao không gọi `push`?

**Trả lời:**
```dart
// login_screen.dart
Navigator.pushReplacement(
  context,
  MaterialPageRoute(builder: (_) => const DashboardScreen()),
);
```

- Login là bước rào chắn. Đăng nhập xong, ta **không muốn user bấm nút Back trên điện thoại để quay lại màn hình Login** nữa.
- Hàm `pushReplacement` (hoặc `pushAndRemoveUntil`) hủy hẳn `LoginScreen` khỏi lịch sử (History Stack) và thay thế bằng `DashboardScreen`.
- Nếu dùng `push`, `LoginScreen` vẫn sống ngầm bên dưới, làm rò rỉ bộ nhớ, và sai luồng UX cơ bản.

---

## Trường hợp 3: `{A}` = **AddTransactionScreen** → `{B}` = **CategoryBottomSheet** (Nửa màn hình)

**Thầy hỏi:** Mở BottomSheet chọn danh mục dùng hàm gì? Làm sao để truyền `categoryId` từ BottomSheet ngược lại về AddTransactionScreen?

**Trả lời:**
Sử dụng `showModalBottomSheet` thay vì `Navigator.push`. 
Thực chất BottomSheet cũng là một Route trong Navigation Stack.

**Truyền xuôi (A → B):** Truyền qua constructor.
```dart
// Truyền selectedType vào BottomSheet để lọc danh sách
builder: (context) => CategoryBottomSheet(selectedType: _selectedType)
```

**Truyền ngược (B → A):** Dùng biến trả về (Return Value).
Bên `CategoryBottomSheet` trả giá trị về qua hàm `pop(data)`:
```dart
onTap: () {
  Navigator.pop(context, category_object); // Trả object về
}
```

Bên `AddTransactionScreen` đứng chờ và nhận giá trị:
```dart
final selectedCategory = await showModalBottomSheet<CategoryModel>(...);

if (selectedCategory != null) { // Nhận được dữ liệu
  setState(() {
    _selectedCategoryId = selectedCategory.id;
    _selectedCategoryName = selectedCategory.name;
  });
}
```

---

## Trường hợp 4: `{A}` = **AddTransactionScreen** → `{B}` = **VoiceInputBottomSheet** (Nhấn nút Mic)

**Thầy hỏi:** Khi phân tích xong giọng nói, làm sao BottomSheet tự đóng và nhét text vào các ô nhập số tiền?

**Trả lời:**
Tương tự như chọn danh mục. Khi AI phân tích trả về cục JSON, BottomSheet đóng và ném dữ liệu về:
```dart
// Đóng và ném data (VoiceAnalysisModel) về
Navigator.pop(context, voiceResult);
```

Màn hình `AddTransaction` bắt lấy cục data này:
```dart
void _showVoiceInput() async {
  final result = await showModalBottomSheet<VoiceAnalysisModel>(...);

  if (result != null) {
    setState(() {
      _amountController.text = result.amount.toString();
      _noteController.text = result.note ?? '';
      _selectedCategoryId = result.categoryId;
      _selectedCategoryName = result.categoryName;
      // UI tự động ăn data vào text fields
    });
  }
}
```

---

## Trường hợp 5: `{A}` = Các Tab điều hướng trong **DashboardScreen** (Bottom Navigation Bar)

**Thầy hỏi:** Khi nhấn các tab ở thanh dưới cùng (Trang chủ / Giao dịch / Phân tích / Cá nhân), màn hình chuyển qua lại nhưng KHÔNG dùng `Navigator.push`. Tại sao?

**Trả lời:**
Thanh Bottom Navigation quản lý các màn hình dưới dạng **Page Caching / Stack cục bộ** (List Widget) trong biến state `_selectedIndex`.

```dart
final List<Widget> _pages = [
  const _DashboardTab(),
  const TransactionScreen(),
  const AnalyticsScreen(),
  const ProfileScreen(),
];

// Trong body:
body: _pages[_selectedIndex],
```
Khi nhấn tab khác:
```dart
onTap: () {
  setState(() { _selectedIndex = index; });
}
```

**Tại sao không dùng Navigator:**
Nếu dùng `Navigator.push` mỗi khi nhấn tab, bộ nhớ sẽ phình to ra vì các tab cứ xếp chồng lên nhau (Tab 1 → Tab 2 → Tab 1 → Tab 2).
Việc hoán đổi index của mảng Widget giúp các màn hình được giữ ngang hàng.
Để tối ưu hơn, Flutter có thể dùng `IndexedStack` để giữ nguyên state (scroll offset) của các màn hình khi chuyển đổi mà không phải khởi tạo lại.
