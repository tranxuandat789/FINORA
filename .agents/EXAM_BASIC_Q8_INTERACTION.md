# BASIC Q8 – Sự kiện tương tác
> **Câu hỏi gốc:** Để thay đổi hành động khi click/tap vào `{...}`, cần tìm đến hàm nào và file nào trong source code?

---

## Trường hợp 1: `{...}` = Nút **"Lưu giao dịch"** trong AddTransactionScreen

**Thầy hỏi:** Để thay đổi hành động khi bấm nút "Lưu giao dịch", cần tìm hàm nào và file nào?

**Trả lời:**
- **File:** `add_transaction_screen.dart`
- **Hàm:** `_saveTransaction()` (dòng ~131)
- **Gắn tại:** `ElevatedButton.onPressed: _saveTransaction`

```dart
// add_transaction_screen.dart dòng ~254-262
ElevatedButton(
  onPressed: _saveTransaction,   // ← tìm hàm _saveTransaction()
  style: ElevatedButton.styleFrom(
    backgroundColor: const Color(0xFF2563EB),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
  ),
  child: Text('Lưu giao dịch', ...),
),
```

Hàm `_saveTransaction()` thực hiện:
1. Validate số tiền (không null, > 0)
2. Validate categoryId, walletId
3. Gọi `TransactionProvider.createTransaction()`
4. Hiện SnackBar thành công/lỗi và `Navigator.pop()`

---

## Trường hợp 2: `{...}` = Nút **"Tiền chi / Tiền thu"** trong AddTransactionScreen

**Thầy hỏi:** Để thay đổi hành động khi tap vào nút "Tiền chi" hoặc "Tiền thu", cần tìm ở đâu?

**Trả lời:**
- **File:** `add_transaction_screen.dart`
- **Widget:** `InkWell` bọc 2 nút (dòng ~192, ~207)
- **Handler:** `onTap: () => setState(() => _selectedType = 2)` (Tiền chi)

```dart
// add_transaction_screen.dart dòng ~192-219
Row(
  children: [
    Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedType = 2),  // ← TAP TIỀN CHI
        child: Container(
          decoration: BoxDecoration(
            color: _selectedType == 2 ? Color(0xFFEF4444) : ...,  // đỏ khi active
          ),
          child: Text('Tiền chi'),
        ),
      ),
    ),
    SizedBox(width: 12),
    Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedType = 1),  // ← TAP TIỀN THU
        child: Container(
          decoration: BoxDecoration(
            color: _selectedType == 1 ? Color(0xFF10B981) : ...,  // xanh khi active
          ),
          child: Text('Tiền thu'),
        ),
      ),
    ),
  ],
),
```

Khi tap, chỉ thay `_selectedType` → `setState()` rebuild UI, không gọi API.

---

## Trường hợp 3: `{...}` = Nút **mic (giọng nói)** trên AppBar AddTransactionScreen

**Thầy hỏi:** Để thay đổi hành động khi bấm icon mic xanh trên AppBar, tìm ở đâu?

**Trả lời:**
- **File:** `add_transaction_screen.dart`
- **Widget:** `IconButton` trong `AppBar.actions` (dòng ~177-181)
- **Hàm:** `_showVoiceInput()` (dòng ~100)

```dart
// add_transaction_screen.dart dòng ~177-181
actions: [
  IconButton(
    icon: const Icon(Icons.mic, color: Color(0xFF2563EB)),
    onPressed: _showVoiceInput,   // ← tìm hàm _showVoiceInput()
  ),
],
```

`_showVoiceInput()` mở `VoiceInputBottomSheet` và xử lý kết quả trả về để điền form.

---

## Trường hợp 4: `{...}` = Chọn **danh mục** trong AddTransactionScreen

**Thầy hỏi:** Khi tap vào dòng "Chọn danh mục", hành động được xử lý ở đâu?

**Trả lời:**
- **File:** `add_transaction_screen.dart`
- **Hàm:** `_selectCategory()` (dòng ~84)
- **Gắn tại:** `_buildField(Icons.category, 'Danh mục', ..., _selectCategory, ...)` (dòng ~238)

```dart
// add_transaction_screen.dart dòng ~84-98
void _selectCategory() async {
  final selectedCategory = await showModalBottomSheet<CategoryModel>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => CategoryBottomSheet(selectedType: _selectedType),
  );
  if (selectedCategory != null) {
    setState(() {
      _selectedCategoryId = selectedCategory.id;
      _selectedCategoryName = selectedCategory.name;
    });
  }
}
```

Hàm `_buildField()` bọc `InkWell` với `onTap: onTap` → khi tap vào dòng Danh mục → gọi `_selectCategory()`.

---

## Trường hợp 5: `{...}` = FAB nút **"+"** trên DashboardScreen

**Thầy hỏi:** Để thay đổi hành động khi bấm nút "+" (FAB xanh), tìm ở đâu?

**Trả lời:**
- **File:** `dashboard_screen.dart`
- **Widget:** `FloatingActionButton` (dòng ~64)

```dart
// dashboard_screen.dart dòng ~64-74
floatingActionButton: FloatingActionButton(
  onPressed: () async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddTransactionScreen()),
    );
    if (mounted) {
      context.read<DashboardProvider>().loadDashboardData();  // refresh sau khi thêm
    }
  },
  backgroundColor: const Color(0xFF2563EB),
  child: const Icon(Icons.add, color: Colors.white, size: 28),
),
```

Sau khi `await Navigator.push()` (user quay về), tự động reload dashboard data.

---

## Trường hợp 6: `{...}` = Các mục **Bottom Navigation** (Trang chủ, Giao dịch, Phân tích, Cá nhân)

**Thầy hỏi:** Khi tap vào tab "Giao dịch" ở bottom nav, hành động được xử lý ở đâu?

**Trả lời:**
- **File:** `dashboard_screen.dart`
- **Hàm:** `_buildBottomNavItem()` → `onTap` → `setState(() { _selectedIndex = index; })`

```dart
// dashboard_screen.dart dòng ~103-128
Widget _buildBottomNavItem({required IconData icon, required String label, required int index}) {
  final bool isActive = _selectedIndex == index;
  return InkWell(
    onTap: () {
      setState(() {
        _selectedIndex = index;  // ← thay đổi tab hiện tại
      });
    },
    child: Column( ... ),
  );
}
```

`_pages[_selectedIndex]` trong `body: Stack(children: [_pages[_selectedIndex], ...]` tự động render đúng màn hình.

---

## Trường hợp 7: `{...}` = Nút **"Ghi chi tiêu"** trong Action Menu Dashboard

**Thầy hỏi:** Khi tap vào nút "Ghi chi tiêu" trong action menu, hàm nào được gọi?

**Trả lời:**
- **File:** `dashboard_screen.dart`
- **Widget:** `_buildActionItem()` với `onTap` callback (dòng ~381)

```dart
// dashboard_screen.dart dòng ~381-387
_buildActionItem(
  Icons.receipt_long, 'Ghi chi tiêu', 
  const Color(0xFF10B981), Colors.white, isDark, 
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddTransactionScreen()),
    ).then((_) {
      if (context.mounted) {
        context.read<DashboardProvider>().loadDashboardData();
      }
    });
  }
),
```

Tương tự FAB, nhưng dùng `.then()` thay vì `await` để refresh dashboard sau.

---

## Trường hợp 8: `{...}` = Nút **"Mục tiêu"** trong Action Menu Dashboard

**Thầy hỏi:** Khi tap vào nút "Mục tiêu", điều hướng đến đâu? Tìm code ở đâu?

**Trả lời:**
- **File:** `dashboard_screen.dart` (dòng ~378-380)

```dart
_buildActionItem(Icons.track_changes, 'Mục tiêu', 
  const Color(0xFF8B5CF6), Colors.white, isDark, 
  onTap: () {
    Navigator.push(
      context, 
      MaterialPageRoute(builder: (_) => const SavingGoalsScreen())
    );
  }
),
```

→ Điều hướng sang `SavingGoalsScreen` (`lib/features/goal/screens/saving_goals_screen.dart`).

---

## Trường hợp 9: `{...}` = Nút **"Xem báo cáo chi tiết"** trong Donut Chart Card

**Thầy hỏi:** Khi tap vào "Xem báo cáo chi tiết", điều hướng thế nào? Tìm code ở đâu?

**Trả lời:**
- **File:** `dashboard_screen.dart` (dòng ~559-582)

```dart
// dashboard_screen.dart dòng ~559
Builder(
  builder: (ctx) => GestureDetector(
    onTap: () {
      // Tìm DashboardScreenState cha và switch sang tab Analytics (index 2)
      final dashState = ctx.findAncestorStateOfType<_DashboardScreenState>();
      dashState?.switchToTab(2);   // ← switch sang tab Phân tích
    },
    child: Container(
      child: Text('Xem báo cáo chi tiết', ...),
    ),
  ),
)
```

Thay vì `Navigator.push()`, dùng `findAncestorStateOfType` để switch bottom nav tab → không tạo route mới.

---

## Trường hợp 10: `{...}` = Nút **con ong FloatingVoiceButton** (tap thông thường)

**Thầy hỏi:** Khi user tap (không nhấn giữ) vào con ong, hành động là gì? Code ở đâu?

**Trả lời:**
- **File:** `floating_voice_button.dart`
- **Handler:** `GestureDetector.onTap` (dòng ~304-307)

```dart
// floating_voice_button.dart dòng ~304-307
onTap: () {
  SnackBarUtils.showTopSnackBar(context, 'Nhấn giữ chú ong để ghi âm nhé!');
  _resetInactivity();
},
```

Tap thường chỉ hiện hướng dẫn. **Nhấn giữ** mới kích hoạt ghi âm:
```dart
onLongPressStart: (_) async {
  // Bắt đầu ghi âm...
  await _voiceService.startListening(...);
},
onLongPressEnd: (_) {
  _handleLongPressEnd();  // dừng ghi âm + phân tích AI
},
```

---

## Trường hợp 11: `{...}` = Nút **"Đăng nhập"** trong LoginScreen

**Thầy hỏi:** Khi bấm nút "Đăng nhập", hành động được xử lý ở đâu?

**Trả lời:**
- **File:** `login_screen.dart`
- **Widget:** `PrimaryButton.onPressed` bên trong `Consumer<AuthProvider>` (dòng ~173-195)

```dart
// login_screen.dart
PrimaryButton(
  text: auth.isLoading ? 'Đang đăng nhập...' : 'Đăng nhập',
  onPressed: (auth.isLoading || auth.isGoogleLoading)
      ? () {}  // ← disabled khi đang loading
      : () {
          if (_formKey.currentState!.validate()) {
            auth.login(
              _emailController.text,
              _passwordController.text,
              onSuccess: () {
                SnackBarUtils.showTopSnackBar(context, 'Đăng nhập thành công!', isSuccess: true);
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const DashboardScreen()));
              },
              onError: (msg) {
                SnackBarUtils.showTopSnackBar(context, msg, isSuccess: false);
              },
            );
          }
        },
),
```

Luồng: `PrimaryButton.onPressed` → validate form → `AuthProvider.login()` → callback `onSuccess/onError`.

---

## Trường hợp 12: `{...}` = Nút **"Thêm danh mục mới"** trong CategoryBottomSheet

**Thầy hỏi:** Khi tap vào nút "Thêm mới" trong BottomSheet chọn danh mục, điều hướng thế nào?

**Trả lời:**
- **File:** `category_bottom_sheet.dart`
- **Hàm:** `_buildAddCategoryButton()` (dòng ~113)

```dart
// category_bottom_sheet.dart dòng ~114-118
Widget _buildAddCategoryButton(BuildContext context, bool isDark) {
  return InkWell(
    onTap: () {
      Navigator.pop(context);   // ← đóng BottomSheet trước
      Navigator.push(context, MaterialPageRoute(
        builder: (_) => AddCategoryScreen(type: widget.selectedType),
      ));
    },
    child: Column( ... ),
  );
}
```

Thứ tự quan trọng: **pop BottomSheet trước** rồi mới push màn hình mới. Nếu không pop trước, navigation stack sẽ là: AddTransaction → CategoryBottomSheet → AddCategory (3 layer).
