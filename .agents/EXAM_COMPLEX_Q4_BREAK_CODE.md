# COMPLEX Q4 – Break the code (Tìm lỗi Cố ý)
> **Câu hỏi gốc:** Thầy giáo mở file `{...}`, lén sửa một dòng code rất nhỏ. Ứng dụng lập tức báo lỗi đỏ màn hình, mất tính năng hoặc vòng lặp vô hạn. Hãy xác định dòng code bị sửa, giải thích tại sao lại lỗi, và cách khắc phục.

---

## Tình huống 1: Mất danh sách giao dịch (Trắng màn hình)

**Cảnh bản:** Thầy mở file `transaction_screen.dart`, sửa nhẹ một dòng. Khi bật app lên, màn hình danh sách giao dịch không hiện gì cả (chỉ có chữ "Chưa có giao dịch nào"), dù API vẫn trả về đủ 100 giao dịch. Vòng tròn loading xoay xong rồi mất, không báo lỗi đỏ.

**Phá hoại (Dòng code bị sửa):**
Trong `TransactionProvider.dart` hoặc `TransactionScreen.dart`.
Thay vì trả về `transactions.length`, thầy sửa thành:
```dart
// Code bị sửa ở file transaction_screen.dart
ListView.builder(
  itemCount: 0, // Thầy đã xóa provider.transactions.length và gõ số 0
  itemBuilder: (context, index) { ... }
)
```

**Giải thích:**
`ListView.builder` dựa vào `itemCount` để biết cần chạy vòng lặp bao nhiêu lần. Nếu `itemCount` bằng 0, nó cho rằng danh sách rỗng và bỏ qua hàm `itemBuilder`. Giao diện sẽ hoàn toàn trống trơn dù biến `transactions` bên trong Provider chứa đầy dữ liệu.

**Cách khắc phục:** 
Đổi lại thành `itemCount: provider.transactions.length`.

---

## Tình huống 2: App sập ngay khi gõ số tiền

**Cảnh bản:** Màn hình `AddTransactionScreen`. Cứ mỗi lần chạm vào bàn phím gõ một con số vào ô "Số tiền", ứng dụng lập tức văng lỗi đỏ lòm (Crash) trên điện thoại.

**Phá hoại (Dòng code bị sửa):**
Thầy đã đụng vào hàm `_formatAmount()` chuyên gắn listener cho TextField.
```dart
// Code bị sửa ở add_transaction_screen.dart
void _formatAmount() {
  String text = _amountController.text.replaceAll(RegExp(r'[^0-9]'), '');
  if (text.isNotEmpty) {
    final formatted = NumberFormat('#,###', 'vi_VN').format(int.parse(text));
    
    // Thầy đã comment dòng này (hoặc xóa nó):
    // _amountController.value = TextEditingValue(
    //   text: formatted,
    //   selection: TextSelection.collapsed(offset: formatted.length),
    // );
    
    // Thay bằng dòng này:
    _amountController.text = formatted; // <-- LỖI DO ĐÂY
  }
}
```

**Giải thích:**
Khi gán giá trị mới bằng `_amountController.text = formatted`, nội bộ Flutter sẽ tự động kích hoạt lại hàm Listener (chính là hàm `_formatAmount` này) một lần nữa.
Hệ quả: Hàm kích hoạt Hàm (Đệ quy vô hạn - Infinite Loop Recursion) → Tràn bộ nhớ stack (StackOverflow Error) và sập app.
Cách thứ hai (dùng `TextEditingValue`) là cách gán an toàn giữ nguyên con trỏ chuột và tránh kích hoạt đệ quy sai nếu text không thực sự thay đổi.
Đồng thời, cần kiểm tra `if (_amountController.text != formatted)` trước khi gán.

---

## Tình huống 3: Lỗi giật lag mỗi khi đổi Tab

**Cảnh bản:** Trong màn hình `DashboardScreen` có Bottom Navigation (4 tab). Thầy sửa nhẹ một dòng ở chỗ `_buildBottomNavBar()`. Bây giờ, cứ mỗi lần bấm đổi qua lại giữa các tab, ứng dụng khựng mất 1 giây, vòng tròn Loading xuất hiện từ đầu như mới mở app.

**Phá hoại (Dòng code bị sửa):**
Trong `DashboardScreen.dart`, chỗ quản lý mảng `_pages`.
```dart
// Từ code chuẩn ban đầu (Dùng cache danh sách tĩnh)
// final List<Widget> _pages = [ DashboardTab(), TransactionScreen(), ...];

// Thầy sửa thành hàm tạo mới động:
body: [
  DashboardTab(),
  TransactionScreen(),
  AnalyticsScreen(),
  ProfileScreen(),
][_selectedIndex], // Mảng được tạo mới tinh mỗi lần rebuild!
```

**Giải thích:**
Khi mảng chứa các màn hình được khởi tạo lại ở mỗi lần `build()` chạy (do `setState _selectedIndex`), Flutter hiểu đây là những Widget hoàn toàn MỚI.
Do là Widget mới, Flutter sẽ gọi lại hàm `initState()` của màn hình `TransactionScreen`. 
Hàm `initState` này lại gọi `context.read<TransactionProvider>().loadTransactions()`. Tức là gọi API lấy dữ liệu lại từ đầu, vứt bỏ toàn bộ cache.
Gây ra tình trạng tốn data, giật lag và loading liên tục.

**Cách khắc phục:** 
Đưa mảng các màn hình thành biến thuộc tính class (nằm ngoài hàm `build`), thêm từ khóa `const` vào các Widget để Flutter tái sử dụng Element Tree, hoặc sử dụng `IndexedStack` để bọc.

---

## Tình huống 4: "Người Dùng Bóng Ma" - Lỗi Cache

**Cảnh bản:** Ứng dụng đã hoàn chỉnh. User A đăng xuất. User B lấy máy đó đăng nhập bằng tài khoản của mình. Mở ra trang Dashboard, User B tá hỏa vì vẫn nhìn thấy lịch sử tiêu tiền, số dư và Avatar của User A.

**Phá hoại (Dòng code bị sửa):**
Thầy vào file `auth_provider.dart` hoặc `profile_screen.dart`, tìm hàm `logout()` và xóa/comment một dòng.

```dart
// Hàm logout bị sửa:
Future<void> logout() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove('token');
  await prefs.remove('user');
  
  // Dòng bị xóa:
  // await FileStorageService.clearAll();  <-- THẦY XÓA DÒNG NÀY

  _user = null;
  token = null;
  notifyListeners();
}
```

**Giải thích:**
Ứng dụng áp dụng thiết kế "Offline-First" (Cache-First). Mọi giao dịch của User A đều được lưu thành file tĩnh trong điện thoại (`transactions_cache.json`).
Khi User B đăng nhập vào, app lập tức truy xuất file cache này và vẽ lên màn hình TRƯỚC KHI gọi API lấy data mới của B.
Nếu mạng yếu, User B sẽ hoàn toàn làm chủ data của User A. Đây là lỗ hổng **Bảo mật rò rỉ dữ liệu (Data Leak) cực kỳ nghiêm trọng**.

**Cách khắc phục:**
Mọi dữ liệu định danh, nhạy cảm (Cache giao dịch, cache thông báo, cấu hình cá nhân) **BẮT BUỘC** phải bị quét sạch (clear/delete file) khỏi Local Storage khi thực hiện hành động `logout`.

---

## Tình huống 5: Vỡ UI vì SingleChildScrollView

**Cảnh bản:** Màn hình `AddTransactionScreen` hiển thị tốt trên iPhone 14 Promax. Thầy chạy thử trên máy giả lập iPhone SE (màn hình lùn bé). Vừa mở màn hình lên, app bị cảnh báo Vàng Đen (Bottom Overflowed by 150 pixels) dưới đáy màn hình, không thể kéo xuống nút "Lưu" được.

**Phá hoại (Dòng code bị sửa):**
Thầy đã xóa Widget `SingleChildScrollView`.
```dart
// Code chuẩn:
body: SingleChildScrollView(
  child: Column( ... )
)

// Code bị thầy phá:
body: Column( ... ) // Bỏ bọc SingleChildScrollView
```

**Giải thích:**
`Column` mặc định có chiều cao linh hoạt, nó sẽ xếp chồng các phần tử từ trên xuống dưới. Nếu tổng chiều cao các phần tử (TextField, Nút, Menu) VƯỢT QUÁ kích thước vật lý của màn hình, `Column` không biết phải làm gì tiếp theo ngoài việc vứt các phần tử đó ra ngoài màn hình và báo lỗi Overflow.
`SingleChildScrollView` là vị cứu tinh: Nó cấp cho `Column` một không gian chiều dọc vô tận, và cho phép user dùng tay vuốt (scroll) lên xuống để xem phần bị che khuất.

**Cách khắc phục:** Nhấn `Alt + Enter` vào chữ Column, chọn "Wrap with Widget", gõ `SingleChildScrollView`.
