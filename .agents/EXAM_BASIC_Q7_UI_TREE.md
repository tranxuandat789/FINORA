# BASIC Q7 – Cấu trúc UI Tree
> **Câu hỏi gốc:** Giao diện `{...}` đang được code gộp chung vào một hàm `build()` khổng lồ hay đã được tách ra các Widget con? Việc tách file/class mang lại ích lợi gì cho màn hình này?

---

## Trường hợp 1: `{...}` = **DashboardScreen** (Trang chủ)

**Thầy hỏi:** Giao diện Dashboard được tổ chức thế nào? Gộp chung hay tách Widget con?

**Trả lời:**
Dashboard được **tách rất tốt** thành nhiều lớp:

**Cấp độ file:**
- `DashboardScreen` (StatefulWidget) → quản lý bottom nav + tab switching
- `_DashboardTab` (StatelessWidget, cùng file) → nội dung tab Trang chủ
- `DonutChartPainter` (CustomPainter, cùng file) → vẽ biểu đồ tròn

**Cấp độ hàm private trong `_DashboardTab`:**
```dart
build()
  ├── _buildAppBar()        → AppBar tùy chỉnh
  ├── _buildBalanceCard()   → Thẻ số dư xanh
  ├── _buildActionMenu()    → 3 nút tròn
  │     └── _buildActionItem()  → từng nút
  ├── _buildSpendingAnalytics() → Khu phân tích
  │     └── _buildDonutChartCard()
  │           └── _buildLegendItem()  → chú thích
  └── _buildRecentTransactions() → Giao dịch gần đây
        └── _buildTransactionItem()
        └── _buildTransactionDivider()
```

**Ích lợi:**
- Dễ tìm và sửa từng phần (muốn sửa balance card chỉ vào `_buildBalanceCard()`)
- `build()` sạch, dễ đọc cấu trúc tổng thể
- Mỗi hàm nhỏ → dễ test độc lập

---

## Trường hợp 2: `{...}` = **AddTransactionScreen**

**Thầy hỏi:** Giao diện AddTransactionScreen đã tách Widget chưa? Cấu trúc ra sao?

**Trả lời:**
**Tách một phần** – có hàm helper private `_buildField()` nhưng vẫn còn nhiều code trong `build()`:

```dart
// Cấu trúc build() của AddTransactionScreen
build()
  └── Scaffold
        ├── AppBar (inline)
        └── SingleChildScrollView
              └── Column
                    ├── Row [2 nút Tiền chi / Tiền thu] (inline ~30 dòng)
                    ├── TextField số tiền (inline)
                    ├── _buildField(Icons.category, ...) → hàm helper
                    ├── _buildField(Icons.note, ...) → hàm helper
                    ├── _buildField(Icons.calendar_today, ...) → hàm helper
                    └── ElevatedButton "Lưu giao dịch" (inline)
```

`_buildField()` là helper tái sử dụng cho 3 dòng (Danh mục, Ghi chú, Ngày):
```dart
Widget _buildField(IconData icon, String label, String value, VoidCallback? onTap, 
                   {Widget? child, required bool isDark}) {
  return InkWell( ... Row [icon container + Column [label + value]] ... );
}
```

**Có thể cải thiện thêm:** Tách 2 nút `Tiền chi / Tiền thu` thành Widget riêng `TransactionTypeSelector`.

---

## Trường hợp 3: `{...}` = **TransactionScreen** (Danh sách giao dịch)

**Thầy hỏi:** Mỗi item giao dịch trong TransactionScreen có được tách Widget không?

**Trả lời:**
**Chưa tách** – item giao dịch được build inline trong `itemBuilder`:

```dart
// transaction_screen.dart
itemBuilder: (context, index) {
  final transaction = provider.transactions[index];
  return Container(   // ← ~40 dòng code inline
    margin: ...,
    padding: ...,
    decoration: BoxDecoration(...),
    child: Row(
      children: [
        Container(icon tròn),
        SizedBox(width: 16),
        Expanded(Column(tên + note)),
        Column(số tiền + ngày),
      ],
    ),
  );
},
```

**Lý tưởng nên tách thành:**
```dart
class TransactionListItem extends StatelessWidget {
  final TransactionModel transaction;
  const TransactionListItem({required this.transaction});
  @override
  Widget build(BuildContext context) { ... }
}
```

**Lợi ích khi tách:**
- `ListView.builder` chỉ gọi `TransactionListItem.build()` khi cần
- Dễ thêm feature (swipe to delete, long press menu)
- Tái sử dụng ở màn hình khác (dashboard recent transactions)

---

## Trường hợp 4: `{...}` = **AddCategoryScreen** (Màn hình thêm danh mục)

**Thầy hỏi:** Giao diện AddCategoryScreen được tổ chức thế nào? Có tách Widget con không?

**Trả lời:**
**Chưa tách** – toàn bộ build() là 1 hàm dài ~100 dòng, không có hàm helper hay Widget riêng:

```dart
// add_category_screen.dart - build() là 1 khối dài
build()
  └── Scaffold
        ├── AppBar (inline)
        └── SingleChildScrollView
              └── Column
                    ├── Text "Loại danh mục"
                    ├── Container (hiển thị Thu nhập/Chi tiêu) [inline ~10 dòng]
                    ├── Text "Tên danh mục" + TextField [inline]
                    ├── if (widget.type == 2) [Budget field - inline ~15 dòng]
                    ├── Text "Chọn Icon"
                    ├── GridView.builder [inline ~25 dòng]
                    └── ElevatedButton [inline]
```

**Có thể tách thành:**
```dart
// Widget con đề xuất
class _CategoryTypeTag extends StatelessWidget { ... }
class _IconPicker extends StatelessWidget { ... }
```

---

## Trường hợp 5: `{...}` = **CategoryBottomSheet**

**Thầy hỏi:** `CategoryBottomSheet` đã tách Widget con chưa? Phần nào đã được tách?

**Trả lời:**
**Tách một phần** – có hàm `_buildAddCategoryButton()` và `_getIcon()`:

```dart
// category_bottom_sheet.dart
build()
  └── Container (bottom sheet wrapper)
        ├── Handle bar (inline ~5 dòng)
        ├── Text tiêu đề (inline)
        ├── Divider (inline)
        └── Consumer<CategoryProvider>
              └── GridView.builder
                    └── itemBuilder:
                          ├── _buildAddCategoryButton() ← ĐÃ TÁCH
                          └── InkWell (icon item) ← còn inline ~25 dòng
```

`_buildAddCategoryButton()` xử lý nút "Thêm mới" riêng – logic đặc biệt (điều hướng sang `AddCategoryScreen`).
`_getIcon(String? iconName)` là helper convert string → `IconData`.

**Có thể cải thiện:** Tách `_buildCategoryItem()` cho mỗi ô icon.

---

## Trường hợp 6: `{...}` = **FloatingVoiceButton**

**Thầy hỏi:** `FloatingVoiceButton` với 415 dòng code, cấu trúc có ổn không? Gộp hay đã tách?

**Trả lời:**
**Gộp chung** – toàn bộ logic UI + animation + business logic trong 1 file, 1 class:

```dart
// floating_voice_button.dart - 1 class duy nhất
_FloatingVoiceButtonState
  ├── initState()    → setup 4 controllers + ticker
  ├── dispose()      → cleanup
  ├── _updateSpeed() → logic tốc độ animation
  ├── _resetInactivity() → Timer reset
  ├── _triggerIdleFlight() → bay tự động
  ├── _handleLongPressEnd() → xử lý ghi âm + gọi API
  └── build()        → LayoutBuilder → Stack → AnimatedPositioned → GestureDetector → Lottie
```

**Đây là Technical Debt** – file quá dài, khó maintain. Lý tưởng nên tách:
- `VoiceAnimationController` → quản lý 4 animation controllers
- `FloatingBehavior` → logic bay tự động
- `VoiceRecordingHandler` → xử lý ghi âm và phân tích

---

## Trường hợp 7: `{...}` = **LoginScreen**

**Thầy hỏi:** Trong LoginScreen, `PrimaryButton` và `CustomTextField` được dùng từ đâu? Có phải Widget tái sử dụng không?

**Trả lời:**
**Đã tách thành Widget tái sử dụng:**

```dart
// login_screen.dart - dùng shared widgets
import 'package:mobile/features/auth/widgets/custom_text_field.dart';
import 'package:mobile/features/auth/widgets/primary_button.dart';

// Trong build():
CustomTextField(
  controller: _emailController,
  label: 'Email',
  hintText: 'example@gmail.com',
  keyboardType: TextInputType.emailAddress,
  validator: (value) { ... },
),
PrimaryButton(
  text: 'Đăng nhập',
  onPressed: () { ... },
),
```

`CustomTextField` và `PrimaryButton` ở `features/auth/widgets/` và được tái sử dụng trong `LoginScreen`, `SignupScreen`, `ResetPasswordScreen`.

**Đây là cách tổ chức đúng** – shared widget trong feature folder, tránh duplicate code.

---

## Trường hợp 8: `{...}` = **DonutChartPainter** trong Dashboard

**Thầy hỏi:** `DonutChartPainter` là gì và tại sao nó được tách riêng thành class?

**Trả lời:**
`DonutChartPainter` extends `CustomPainter` – vẽ biểu đồ tròn thủ công bằng Canvas:

```dart
// dashboard_screen.dart - cuối file
class DonutChartPainter extends CustomPainter {
  final List<CategoryExpense> expenses;
  final List<Color> colors;
  
  @override
  void paint(Canvas canvas, Size size) {
    // Vẽ từng cung tròn theo expenses
    for (int i = 0; i < expenses.length; i++) {
      double sweepAngle = expenses[i].percentage * 2 * 3.14159;
      Paint paint = Paint()..color = colors[i]..strokeWidth = 16.0;
      canvas.drawArc(...);
    }
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
```

**Tại sao tách:**
- `CustomPainter` có interface riêng (`paint()`, `shouldRepaint()`) → không thể inline
- Logic vẽ phức tạp → tách để dễ test và debug
- Tương lai có thể extract ra file riêng `donut_chart_painter.dart`

---

## Trường hợp 9: `{...}` = **_DashboardTab** vs **DashboardScreen** (2 class cùng file)

**Thầy hỏi:** Tại sao `_DashboardTab` lại là class riêng thay vì 1 hàm trong `DashboardScreen`?

**Trả lời:**
`DashboardScreen` cần quản lý **bottom navigation** (StatefulWidget để giữ `_selectedIndex`). Nếu gộp toàn bộ Dashboard content vào cùng 1 class:
- `build()` rất dài (600+ dòng)
- Mỗi lần `_selectedIndex` thay đổi, toàn bộ content rebuild không cần thiết

Tách thành `_DashboardTab` (StatelessWidget):
```dart
class DashboardScreen extends StatefulWidget { ... }  // quản lý nav
class _DashboardTab extends StatelessWidget { ... }    // content tab 0

// _pages trong DashboardScreen:
final List<Widget> _pages = [
  const _DashboardTab(),     // tab 0
  const TransactionScreen(), // tab 1
  const AnalyticsScreen(),   // tab 2
  const ProfileScreen(),     // tab 3
];
```

`_DashboardTab` là `StatelessWidget` → không rebuild khi `_selectedIndex` thay đổi (Flutter có thể cache widget).

---

## Trường hợp 10: `{...}` = **Consumer<TransactionProvider>** trong TransactionScreen

**Thầy hỏi:** Tại sao TransactionScreen dùng `Consumer<TransactionProvider>` thay vì dùng `context.watch()` trực tiếp trong `build()`?

**Trả lời:**
Cả hai cách đều rebuild widget khi provider thay đổi. Trong `TransactionScreen`:

```dart
// transaction_screen.dart dòng ~36
body: Consumer<TransactionProvider>(
  builder: (context, provider, child) {
    // child không rebuild nếu được pass vào
    if (provider.isLoading...) ...
    return ListView.builder(...);
  },
),
```

**Ưu điểm `Consumer` so với `context.watch()`:**
1. **Phạm vi rebuild nhỏ hơn**: chỉ phần bên trong `Consumer.builder` rebuild, không phải toàn bộ `build()` của màn hình
2. **`child` parameter**: Widget tĩnh có thể pass vào `child` và không bị rebuild
3. **Rõ ràng hơn**: Code tường minh "phần này phụ thuộc vào TransactionProvider"

Trong trường hợp này, `AppBar` không cần rebuild khi transactions thay đổi → `Consumer` là lựa chọn tốt.
