# BASIC Q1 – Blind-test UI
> **Câu hỏi gốc:** Chỉ nhìn giao diện `{...}`, liệt kê các Widget chính cấu thành nên giao diện đó. Để đổi màu hoặc thay đổi icon ở vị trí nào đó, cần mở file nào và sửa thuộc tính nào?

---

## Trường hợp 1: `{...}` = Màn hình **AddTransactionScreen** (Thêm giao dịch)

**Thầy hỏi:** Nhìn vào màn hình Thêm giao dịch, liệt kê các Widget chính. Muốn đổi màu nút "Tiền chi" từ đỏ sang cam, cần mở file nào và sửa thuộc tính nào?

**Trả lời:**
Widget chính của `AddTransactionScreen`:
- `Scaffold` → chứa toàn bộ
- `AppBar` → thanh tiêu đề "Thêm giao dịch" + nút mic (icon xanh)
- `SingleChildScrollView` → cho phép cuộn
- `Row` chứa 2 `InkWell/Container` → nút **Tiền chi** (đỏ) & **Tiền thu** (xanh)
- `TextField` → nhập số tiền, có listener `_formatAmount`
- `_buildField()` (widget helper) → dòng Danh mục, Ghi chú, Ngày
- `ElevatedButton` → nút "Lưu giao dịch" màu xanh `#2563EB`

Để đổi màu nút "Tiền chi" từ đỏ sang cam:
- Mở file: `add_transaction_screen.dart`
- Dòng ~197: `color: _selectedType == 2 ? const Color(0xFFEF4444) : ...`
- Sửa `0xFFEF4444` thành `0xFFFF6B00` (cam)

```dart
// Trước
color: _selectedType == 2 ? const Color(0xFFEF4444) : ...
// Sau
color: _selectedType == 2 ? const Color(0xFFFF6B00) : ...
```

---

## Trường hợp 2: `{...}` = Màn hình **TransactionScreen** (Danh sách giao dịch)

**Thầy hỏi:** Nhìn vào màn hình Danh sách giao dịch, liệt kê các Widget chính. Muốn đổi icon mũi tên lên/xuống sang icon khác, cần mở file nào và sửa thuộc tính nào?

**Trả lời:**
Widget chính của `TransactionScreen`:
- `Scaffold` + `AppBar` → tiêu đề "Giao dịch"
- `Consumer<TransactionProvider>` → lắng nghe state, rebuild khi data thay đổi
- `CircularProgressIndicator` → hiện khi `isLoading = true` và chưa có data
- `ListView.builder` → render danh sách giao dịch
- `Container` (card) → mỗi item giao dịch có `Row` chứa:
  - `Container` hình tròn + `Icon` (mũi tên lên/xuống)
  - `Column` tên danh mục + ghi chú
  - `Column` số tiền + ngày

Để đổi icon mũi tên:
- Mở file: `transaction_screen.dart`
- Dòng ~78: `isIncome ? Icons.arrow_downward : Icons.arrow_upward`
- Sửa thành icon khác ví dụ `Icons.trending_up / Icons.trending_down`

```dart
// Trước
isIncome ? Icons.arrow_downward : Icons.arrow_upward
// Sau
isIncome ? Icons.trending_down : Icons.trending_up
```

---

## Trường hợp 3: `{...}` = Màn hình **AddCategoryScreen** (Thêm danh mục)

**Thầy hỏi:** Nhìn vào màn hình Thêm danh mục, liệt kê các Widget chính. Muốn đổi màu icon được chọn từ xanh dương sang tím, cần sửa ở đâu?

**Trả lời:**
Widget chính của `AddCategoryScreen`:
- `Scaffold` + `AppBar` → tiêu đề "Thêm danh mục" + nút back
- `SingleChildScrollView` + `Column`
- `Container` hiển thị loại (Thu nhập/Chi tiêu)
- `TextField` → nhập tên danh mục
- `TextField` → nhập ngân sách (chỉ hiện khi type == 2)
- `GridView.builder` (5 cột) → lưới icon chọn
- `ElevatedButton` → nút "Lưu danh mục"

Để đổi màu icon được chọn từ xanh sang tím:
- Mở file: `add_category_screen.dart`
- Dòng ~151: `color: isSelected ? const Color(0xFF2563EB) : ...`
- Sửa `0xFF2563EB` thành `0xFF8B5CF6` (tím)

```dart
// Trước
color: isSelected ? const Color(0xFF2563EB) : (isDark ? ...)
// Sau
color: isSelected ? const Color(0xFF8B5CF6) : (isDark ? ...)
```

---

## Trường hợp 4: `{...}` = Màn hình **DashboardScreen** (Trang chủ)

**Thầy hỏi:** Nhìn vào màn hình Trang chủ, liệt kê các Widget chính cấu thành. Muốn thay đổi icon chuông thông báo, cần tìm ở đâu?

**Trả lời:**
Widget chính `DashboardScreen` (class `_DashboardTab`):
- `SafeArea` + `Consumer<DashboardProvider>`
- `RefreshIndicator` → kéo xuống để refresh
- `SingleChildScrollView` → cuộn toàn bộ
- `_buildAppBar()` → avatar + tên + icon đồng bộ + icon chuông
- `_buildBalanceCard()` → thẻ số dư màu xanh + ảnh nền
- `_buildActionMenu()` → 3 nút tròn: Mục tiêu, Ghi chi tiêu, Xem thêm
- `_buildSpendingAnalytics()` → Donut chart + progress bars
- `_buildRecentTransactions()` → danh sách giao dịch gần đây

Để đổi icon chuông:
- Mở file: `dashboard_screen.dart`
- Dòng ~280: `Icon(Icons.notifications_none, ...)`
- Sửa thành `Icons.notifications` hoặc `Icons.notification_important`

```dart
// Trước
Icon(Icons.notifications_none, color: isDark ? ...)
// Sau
Icon(Icons.notifications, color: isDark ? ...)
```

---

## Trường hợp 5: `{...}` = Widget **FloatingVoiceButton** (Nút chú ong)

**Thầy hỏi:** Nhìn vào nút chú ong trên màn hình Trang chủ, liệt kê các Widget chính. Muốn đổi animation Lottie sang ảnh PNG tĩnh, cần sửa ở đâu?

**Trả lời:**
Widget chính của `FloatingVoiceButton`:
- `LayoutBuilder` → lấy kích thước màn hình
- `SizedBox` + `Stack` → chứa tất cả
- `Positioned.fill` + `Listener` → detect chạm mọi nơi để reset timer
- `Positioned` (tooltip) → bong bóng chat "Đang lắng nghe..."
- `AnimatedPositioned` → vị trí bay của con ong
- `AnimatedBuilder` → bobbing (lên xuống)
- `Transform.translate` + `Transform.scale` → hiệu ứng
- `GestureDetector` → xử lý tap, pan, longPress
- `Lottie.asset('assets/images/bee.json')` → animation con ong

Để đổi sang ảnh PNG tĩnh:
- Mở file: `floating_voice_button.dart`
- Dòng ~390: Thay `Lottie.asset(...)` bằng `Image.asset('assets/images/bee.png')`

```dart
// Trước
Lottie.asset('assets/images/bee.json', controller: _lottieController, ...)
// Sau
Image.asset('assets/images/bee.png', width: 70, height: 70, fit: BoxFit.contain)
```

---

## Trường hợp 6: `{...}` = Widget **CategoryBottomSheet** (Chọn danh mục)

**Thầy hỏi:** Nhìn vào Bottom Sheet chọn danh mục, liệt kê các Widget chính. Muốn đổi màu nền của bottom sheet từ trắng sang xám nhạt, cần sửa ở đâu?

**Trả lời:**
Widget chính của `CategoryBottomSheet`:
- `Container` (chiếm 60% chiều cao) → wrapper chính
- `BoxDecoration` với `borderRadius` bo góc trên
- Handle bar nhỏ (4x40) ở đầu
- `Text` tiêu đề "Chọn danh mục..."
- `Divider` ngăn cách
- `Consumer<CategoryProvider>` → lắng nghe danh sách
- `GridView.builder` (4 cột) → lưới danh mục
- `_buildAddCategoryButton()` → ô "Thêm mới" cuối lưới

Để đổi màu nền:
- Mở file: `category_bottom_sheet.dart`
- Dòng ~25: `color: isDark ? const Color(0xFF1F2937) : Colors.white`
- Sửa `Colors.white` thành `const Color(0xFFF3F4F6)`

```dart
// Trước
color: isDark ? const Color(0xFF1F2937) : Colors.white,
// Sau
color: isDark ? const Color(0xFF1F2937) : const Color(0xFFF3F4F6),
```

---

## Trường hợp 7: `{...}` = Màn hình **LoginScreen** (Đăng nhập)

**Thầy hỏi:** Nhìn vào màn hình Đăng nhập, liệt kê các Widget chính. Muốn đổi màu nút "Đăng nhập" từ xanh sang đen, cần mở file nào sửa ở đâu?

**Trả lời:**
Widget chính của `LoginScreen`:
- `Scaffold` + `SafeArea` + `SingleChildScrollView`
- `Form` (có `GlobalKey<FormState>`) → bọc toàn bộ form
- `Row` → logo + nút "Đăng kí"
- `Text` → tiêu đề "Chào mừng trở lại"
- 2x `CustomTextField` → ô Email + Mật khẩu
- `TextButton` "Quên mật khẩu?" (align phải)
- `Consumer<AuthProvider>` + `PrimaryButton` → nút Đăng nhập (có loading state)
- `Divider` + text "Hoặc đăng nhập với"
- `Consumer<AuthProvider>` + `PrimaryButton` + Google icon → nút Google
- `GestureDetector` "Đăng ký ngay" ở dưới

Để đổi màu nút Đăng nhập:
- Mở file: `login_screen.dart` → tìm widget `PrimaryButton`
- Màu thực tế nằm trong: `lib/features/auth/widgets/primary_button.dart`
- Sửa `backgroundColor` trong `ElevatedButton.styleFrom()`

---

## Trường hợp 8: `{...}` = Phần **Action Menu** trên Dashboard (3 nút tròn)

**Thầy hỏi:** Nhìn vào 3 nút tròn "Mục tiêu, Ghi chi tiêu, Xem thêm" trên Dashboard, liệt kê Widget. Muốn đổi icon nút "Mục tiêu" từ track_changes sang star, cần sửa ở đâu?

**Trả lời:**
Widget chính:
- `Container` với `BoxDecoration` bo góc 24, shadow nhẹ
- `Row` với `mainAxisAlignment: MainAxisAlignment.spaceAround`
- 3x `_buildActionItem()` → mỗi item gồm:
  - `GestureDetector` (bắt onTap)
  - `Column` → `Container` hình tròn + `Icon` + `Text` label

Để đổi icon "Mục tiêu":
- Mở file: `dashboard_screen.dart`
- Dòng ~378: `_buildActionItem(Icons.track_changes, 'Mục tiêu', ...)`
- Sửa `Icons.track_changes` thành `Icons.star`

```dart
// Trước
_buildActionItem(Icons.track_changes, 'Mục tiêu', const Color(0xFF8B5CF6), Colors.white, isDark, ...)
// Sau
_buildActionItem(Icons.star, 'Mục tiêu', const Color(0xFF8B5CF6), Colors.white, isDark, ...)
```

---

## Trường hợp 9: `{...}` = Thẻ **Balance Card** trên Dashboard (thẻ số dư xanh)

**Thầy hỏi:** Nhìn vào thẻ xanh hiển thị số dư, liệt kê Widget chính. Muốn đổi màu nền từ xanh `#2563EB` sang gradient tím-xanh, cần sửa ở đâu?

**Trả lời:**
Widget chính `_buildBalanceCard()`:
- `Container` với `margin` + `BoxDecoration`:
  - `color: Color(0xFF2563EB)` (nền xanh)
  - `borderRadius: 24`
  - `boxShadow` bóng đổ
  - `DecorationImage` → ảnh nền `Dashboard1.png`
- `ClipRRect` + `Stack`
- `Column` → Text "Tổng số dư" + Text số tiền + Row phần trăm
- `Positioned` → ảnh `DashboardIcon.png` bên phải

Để đổi sang gradient:
- Mở file: `dashboard_screen.dart` → hàm `_buildBalanceCard()`
- Bỏ `color:` và thay bằng `gradient:`

```dart
// Trước
BoxDecoration(
  color: const Color(0xFF2563EB),
  ...
)
// Sau
BoxDecoration(
  gradient: const LinearGradient(
    colors: [Color(0xFF8B5CF6), Color(0xFF2563EB)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  ),
  ...
)
```

---

## Trường hợp 10: `{...}` = **BottomNavigationBar** (Thanh điều hướng dưới)

**Thầy hỏi:** Nhìn vào thanh điều hướng 4 tab bên dưới, liệt kê Widget chính. Muốn đổi màu icon active từ xanh `#2563EB` sang xanh lá, cần sửa ở đâu?

**Trả lời:**
Widget chính `_buildBottomNavBar()`:
- `BottomAppBar` với `shape: CircularNotchedRectangle()` (tạo hõm cho FAB)
- `SizedBox(height: 64)` + `Row`
- 4x `Expanded` chứa `_buildBottomNavItem()`:
  - `InkWell` + `Column` → Icon + Text label
- `SizedBox(width: 72)` ở giữa (chỗ trống cho FAB)

Màu active/inactive trong `_buildBottomNavItem()`:
```dart
Icon(icon, color: isActive ? const Color(0xFF2563EB) : const Color(0xFF9CA3AF))
```

Để đổi màu active:
- Mở file: `dashboard_screen.dart` → hàm `_buildBottomNavItem()`
- Sửa `0xFF2563EB` thành `0xFF10B981`

```dart
// Trước
color: isActive ? const Color(0xFF2563EB) : const Color(0xFF9CA3AF)
// Sau
color: isActive ? const Color(0xFF10B981) : const Color(0xFF9CA3AF)
```

---

## Trường hợp 11: `{...}` = Widget **Donut Chart** trên Dashboard

**Thầy hỏi:** Nhìn vào biểu đồ tròn phân tích chi tiêu, liệt kê Widget chính. Muốn đổi độ dày của vòng tròn từ 16 sang 24, cần sửa ở đâu?

**Trả lời:**
Widget chính `_buildDonutChartCard()`:
- `Container` với padding + border radius
- `Column` → tiêu đề "Phân tích chi tiêu" + Row "Tháng này"
- `SizedBox(120x120)` + `CustomPaint(painter: DonutChartPainter(...))`
  - Vẽ từng cung tròn theo `expenseByCategory`
- `Center` chứa Column: số tiền tổng + text "Tổng chi"
- `Column` các `_buildLegendItem()` → chú thích màu + %
- `GestureDetector` + Container → nút "Xem báo cáo chi tiết"

`DonutChartPainter` là `CustomPainter` riêng:
- Dòng ~744: `double strokeWidth = 16.0;`
- Sửa thành `24.0`

```dart
// Trước
double strokeWidth = 16.0;
// Sau
double strokeWidth = 24.0;
```
Mở file: `dashboard_screen.dart` → class `DonutChartPainter` → phương thức `paint()`.

---

## Trường hợp 12: `{...}` = Màn hình **SavingGoalsScreen** (Mục tiêu tiết kiệm)

**Thầy hỏi:** Nhìn vào màn hình Mục tiêu tiết kiệm, liệt kê các Widget chính. Muốn thêm icon ở phía trái mỗi goal card, cần mở file nào?

**Trả lời:**
Màn hình `SavingGoalsScreen` nằm ở:
`lib/features/goal/screens/saving_goals_screen.dart`

Widget chính:
- `Scaffold` + `AppBar` → tiêu đề "Mục tiêu tiết kiệm"
- `Consumer<GoalProvider>` (hoặc provider tương ứng)
- `ListView.builder` → danh sách các goal card
- Mỗi card goal thường có: tiêu đề mục tiêu, số tiền hiện tại / mục tiêu, `LinearProgressIndicator`

Để thêm icon:
- Mở file: `saving_goals_screen.dart`
- Tìm widget build card của từng goal
- Bọc Row ngoài cùng để thêm `Icon(Icons.savings, ...)` bên trái
