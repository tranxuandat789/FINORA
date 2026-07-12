# BASIC Q9 – Quản lý Theme
> **Câu hỏi gốc:** Màu sắc và Font chữ của khu vực `{...}` đang được set cứng (hardcode) hay lấy từ Theme chung của toàn app? Có thể sửa cấu hình này ở đâu?

---

## Trường hợp 1: `{...}` = Font chữ toàn bộ app (Inter)

**Thầy hỏi:** Font "Inter" được dùng khắp nơi trong app là hardcode hay từ Theme? Muốn đổi font toàn app thành "Roboto", cần sửa ở đâu?

**Trả lời:**
Font **HARDCODE** tại từng Widget – dùng `GoogleFonts.inter(...)` trực tiếp:

```dart
// add_transaction_screen.dart (ví dụ điển hình)
Text('Thêm giao dịch', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 18))
Text('Số tiền', style: GoogleFonts.inter(color: ..., fontSize: 14))
```

Không có `ThemeData.textTheme` tập trung. Để đổi sang "Roboto":
- Phải tìm và thay **từng** `GoogleFonts.inter()` → `GoogleFonts.roboto()`
- Đây là **Technical Debt**: lý tưởng nên define font trong `ThemeData`:

```dart
// Cách cải thiện - trong main.dart hoặc theme config:
ThemeData(
  textTheme: GoogleFonts.interTextTheme(), // ← set 1 lần cho toàn app
)
// Sau đó dùng: Text('...', style: Theme.of(context).textTheme.bodyMedium)
```

---

## Trường hợp 2: `{...}` = Màu nền **Dark Mode** / **Light Mode** trong AddTransactionScreen

**Thầy hỏi:** Màu nền `#111827` (dark) và `Colors.white` (light) trong AddTransactionScreen lấy từ đâu? ThemeProvider quản lý thế nào?

**Trả lời:**
Màu nền **HARDCODE** nhưng **điều kiện** lấy từ `ThemeProvider`:

```dart
// add_transaction_screen.dart dòng ~169-170
final isDark = context.watch<ThemeProvider>().isDarkMode;
return Scaffold(
  backgroundColor: isDark ? const Color(0xFF111827) : Colors.white,
  // ...
);
```

`ThemeProvider` chỉ cung cấp **boolean `isDarkMode`**, không cung cấp màu cụ thể.
Mỗi màn hình tự quyết định màu nào dùng cho dark/light.

**ThemeProvider** ở `core/providers/theme_provider.dart`:
```dart
class ThemeProvider extends ChangeNotifier {
  bool get isDarkMode => _themeMode == ThemeMode.dark;
  
  Future<void> toggleTheme(bool isOn) async {
    _themeMode = isOn ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
    // Lưu vào SharedPreferences
    await prefs.setBool('is_dark_mode', isOn);
  }
}
```

---

## Trường hợp 3: `{...}` = Màu xanh chủ đạo `#2563EB` (primary blue)

**Thầy hỏi:** Màu xanh `#2563EB` được dùng rất nhiều (FAB, nút Save, icon mic...) có được define tập trung không? Muốn đổi màu chủ đạo của toàn app, cần sửa bao nhiêu chỗ?

**Trả lời:**
Màu `#2563EB` được **HARDCODE** tại từng Widget, KHÔNG có file Constants tập trung:

```dart
// dashboard_screen.dart - FAB
backgroundColor: const Color(0xFF2563EB)
// add_transaction_screen.dart - nút Save
backgroundColor: const Color(0xFF2563EB)
// login_screen.dart - màu text link
color: const Color(0xFF2563EB)
// transaction_screen.dart - loading indicator
CircularProgressIndicator(color: Color(0xFF2563EB))
// category_bottom_sheet.dart - nút Thêm mới
border: Border.all(color: Color(0xFF818CF8)) // tông xanh tím biến thể
```

Muốn đổi màu chủ đạo → phải sửa **20+ chỗ** trong nhiều file.

**Cách cải thiện:** Tạo file `lib/core/constants/app_colors.dart`:
```dart
class AppColors {
  static const primary = Color(0xFF2563EB);
  static const income = Color(0xFF10B981);
  static const expense = Color(0xFFEF4444);
  static const darkBackground = Color(0xFF111827);
  static const darkCard = Color(0xFF1F2937);
}
```

---

## Trường hợp 4: `{...}` = Màu xanh thu nhập `#10B981` và đỏ chi tiêu `#EF4444`

**Thầy hỏi:** Màu xanh cho thu nhập và đỏ cho chi tiêu có được define tập trung không?

**Trả lời:**
**HARDCODE** tại nhiều nơi, không tập trung:

```dart
// add_transaction_screen.dart - nút Tiền thu active
color: _selectedType == 1 ? const Color(0xFF10B981) : ...
// add_transaction_screen.dart - nút Tiền chi active  
color: _selectedType == 2 ? const Color(0xFFEF4444) : ...
// transaction_screen.dart - màu icon
isIncome ? const Color(0xFF10B981) : const Color(0xFFEF4444)
// transaction_screen.dart - màu số tiền
isIncome ? const Color(0xFF10B981) : const Color(0xFFEF4444)
// dashboard_screen.dart - màu trong recent transactions
isIncome ? const Color(0xFF10B981) : const Color(0xFFEF4444)
// add_category_screen.dart - màu loại danh mục
widget.type == 1 ? const Color(0xFF10B981) : const Color(0xFFEF4444)
```

Đây là **pattern nhất quán** nhưng chưa tập trung. Khi cần đổi màu income/expense phải sửa ~10 chỗ.

---

## Trường hợp 5: `{...}` = Background màu tối `#111827`, `#1F2937`, `#374151` trong Dark Mode

**Thầy hỏi:** Ba màu dark mode khác nhau (`#111827`, `#1F2937`, `#374151`) dùng cho mục đích gì? Có tập trung không?

**Trả lời:**
Ba màu này tạo **hệ thống phân cấp màu sắc** trong dark mode:
- `#111827` (dark-900) → nền chính của Scaffold, AppBar
- `#1F2937` (dark-800) → card, container cấp 1
- `#374151` (dark-700) → input field, badge, container cấp 2

Ví dụ trong `add_transaction_screen.dart`:
```dart
// Scaffold background (tối nhất)
backgroundColor: isDark ? const Color(0xFF111827) : Colors.white,

// Input field background (ít tối hơn)
fillColor: isDark ? const Color(0xFF374151) : const Color(0xFFF3F4F6),
```

Chúng được **HARDCODE** nhưng dùng nhất quán (mọi màn hình đều dùng chung pattern này). Có thể tập trung vào `AppColors`.

---

## Trường hợp 6: `{...}` = Theme được toggle trong **ProfileScreen** (dark/light switch)

**Thầy hỏi:** Khi user bật/tắt dark mode trong Profile, `ThemeProvider` hoạt động thế nào? Widget nào rebuild?

**Trả lời:**
```dart
// ThemeProvider.toggleTheme()
Future<void> toggleTheme(bool isOn) async {
  _themeMode = isOn ? ThemeMode.dark : ThemeMode.light;
  notifyListeners();    // ← notify tất cả listeners
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool('is_dark_mode', isOn); // lưu preference
}
```

Trong `main.dart`, `ThemeProvider` được watch ở cấp cao nhất:
```dart
// main.dart (giả định)
MaterialApp(
  themeMode: context.watch<ThemeProvider>().themeMode,
  theme: ThemeData.light(),
  darkTheme: ThemeData.dark(),
)
```

Khi `notifyListeners()` → `MaterialApp` rebuild → toàn bộ app đổi theme.

Các màn hình dùng `context.watch<ThemeProvider>().isDarkMode` → rebuild khi theme thay đổi.

---

## Trường hợp 7: `{...}` = Màu gradient trong **Balance Card** Dashboard

**Thầy hỏi:** Màu xanh `#2563EB` của thẻ số dư và ảnh overlay `Dashboard1.png` đến từ đâu? Có lấy từ Theme không?

**Trả lời:**
Màu nền thẻ **HARDCODE** và ảnh nền cũng là **asset cứng**:

```dart
// dashboard_screen.dart dòng ~300-313
BoxDecoration(
  color: const Color(0xFF2563EB),      // ← hardcode
  borderRadius: BorderRadius.circular(24),
  boxShadow: [
    BoxShadow(
      color: const Color(0xFF0D6EFD).withValues(alpha: 0.3),  // ← hardcode
      blurRadius: 20,
    ),
  ],
  image: const DecorationImage(
    image: AssetImage('assets/images/Dashboard1.png'),  // ← asset cứng
    fit: BoxFit.cover,
  ),
),
```

Balance card KHÔNG kiểm tra `isDark` → luôn xanh dù dark hay light mode. Đây là thiết kế cố ý (balance card luôn nổi bật).

---

## Trường hợp 8: `{...}` = Font size và weight trong **TransactionScreen** item

**Thầy hỏi:** Font size 14, 12 và FontWeight.w600 trong mỗi item giao dịch có được định nghĩa trong TextTheme không?

**Trả lời:**
**HARDCODE** inline trong mỗi `Text` widget:

```dart
// transaction_screen.dart dòng ~87-88
Text(transaction.categoryName, 
  style: GoogleFonts.inter(
    fontSize: 14,              // ← hardcode
    fontWeight: FontWeight.w600, // ← hardcode
    color: isDark ? Colors.white : const Color(0xFF111827)
  )
),
Text(transaction.note ?? '',
  style: GoogleFonts.inter(
    fontSize: 12,              // ← hardcode
    color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280)
  )
),
```

Không dùng `Theme.of(context).textTheme`. Đây là tradeoff phổ biến trong Flutter projects nhỏ/medium – dễ lập trình hơn nhưng khó maintain hơn khi scale.

---

## Trường hợp 9: `{...}` = Màu `#9CA3AF` (gray text) dùng cho placeholder/subtitle

**Thầy hỏi:** Màu `#9CA3AF` dùng ở rất nhiều chỗ (text phụ, hint text, icon tắt), có được tập trung không?

**Trả lời:**
**HARDCODE** tại nhiều nơi, nhưng **nhất quán** – là màu `gray-400` theo Tailwind palette:

```dart
// dashboard_screen.dart - label nhỏ
color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280)
// transaction_screen.dart - note text
color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280)
// add_category_screen.dart - label
color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280)
// bottom nav bar - inactive item
color: isActive ? const Color(0xFF2563EB) : const Color(0xFF9CA3AF)
```

Pattern `isDark ? #9CA3AF : #6B7280` xuất hiện ít nhất 15 lần trong dự án.

**Cải thiện:** Define extension hoặc static getter:
```dart
extension AppColorScheme on bool {
  Color get subtitleColor => this ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280);
}
// Dùng: isDark.subtitleColor
```

---

## Trường hợp 10: `{...}` = Màu active/inactive trong **Icon Grid** AddCategoryScreen

**Thầy hỏi:** Icon được chọn trong AddCategoryScreen đổi màu nền thành xanh `#2563EB`, màu đó hardcode hay từ Theme?

**Trả lời:**
**HARDCODE** trong `itemBuilder`:

```dart
// add_category_screen.dart dòng ~150-155
Container(
  decoration: BoxDecoration(
    color: isSelected 
        ? const Color(0xFF2563EB)   // ← hardcode - active
        : (isDark ? const Color(0xFF374151) : const Color(0xFFF3F4F6)),  // inactive
    shape: BoxShape.circle,
  ),
  child: Icon(
    iconData['icon'],
    color: isSelected 
        ? Colors.white              // ← hardcode
        : (isDark ? const Color(0xFFD1D5DB) : const Color(0xFF4B5563)),  // inactive
  ),
),
```

Để sửa màu selected: mở file `add_category_screen.dart` → tìm `isSelected ? const Color(0xFF2563EB)` → đổi màu.

---

## Trường hợp 11: `{...}` = Border radius `12`, `16`, `24` dùng khắp app

**Thầy hỏi:** Giá trị `borderRadius: 12`, `16`, `24` có được define tập trung không?

**Trả lời:**
**HARDCODE** nhưng theo quy ước nhất quán:
- `12` → input fields, small cards
- `16` → buttons, medium cards
- `24` → large cards (balance card, action menu, recent transactions)

Ví dụ:
```dart
// Nút lưu - radius 16
shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))
// Balance card - radius 24
borderRadius: BorderRadius.circular(24)
// Input field - radius 12
border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))
```

Không có file constants riêng. Muốn đổi: tìm `BorderRadius.circular(16)` bằng IDE search.
