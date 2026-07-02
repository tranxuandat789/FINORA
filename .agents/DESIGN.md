# FINORA — Design Documentation

> Tài liệu thiết kế UI/UX cho ứng dụng quản lý tài chính cá nhân **FINORA** (Flutter Mobile).  
> Figma source: [Untitled – Figma](https://www.figma.com/design/QOlmLJXUIrwq8bIEvlOiRY/Untitled)

---

## Mục lục

1. [Design Principles](#1-design-principles)
2. [Color System](#2-color-system)
3. [Typography](#3-typography)
4. [Spacing & Layout](#4-spacing--layout)
5. [Border Radius & Elevation](#5-border-radius--elevation)
6. [Component Library](#6-component-library)
7. [Screen Inventory](#7-screen-inventory)
8. [Navigation Architecture](#8-navigation-architecture)
9. [Assets](#9-assets)
10. [Coding Conventions](#10-coding-conventions)
11. [Hướng dẫn Tiếp cận (Accessibility - WCAG 2.2)](#11-hướng-dẫn-tiếp-cận-accessibility---wcag-22)
12. [Trạng thái của Hợp phần (Component States)](#12-trạng-thái-của-hợp-phần-component-states)
13. [Thiết kế Đáp ứng (Responsive Design)](#13-thiết-kế-đáp-ứng-responsive-design)
14. [Hướng dẫn Chuyển động (Motion Guidelines)](#14-hướng-dẫn-chuyển-động-motion-guidelines)
15. [Hệ thống Bóng đổ (Elevation System)](#15-hệ-thống-bóng-đổ-elevation-system)
16. [Hệ thống Biểu tượng (Iconography)](#16-hệ-thống-biểu-tượng-iconography)
17. [Giao diện Sáng/Tối (Theme System - Light/Dark Scheme)](#17-giao-diện-sángtối-theme-system---lightdark-scheme)
18. [Quy tắc Bố cục (Layout Rules)](#18-quy-tắc-bố-cục-layout-rules)
19. [Thiết kế Biểu mẫu (Forms)](#19-thiết-kế-biểu-mẫu-forms)
20. [Cấu trúc Điều hướng (Navigation)](#20-cấu-trúc-điều-hướng-navigation)
21. [Hệ thống Phản hồi (Feedback)](#21-hệ-thống-phản-hồi-feedback)
22. [Hệ thống Biểu đồ (Charts)](#22-hệ-thống-biểu-đồ-charts)

---

## 1. Design Principles

| Nguyên tắc | Mô tả |
|---|---|
| **Clarity First** | Thông tin tài chính phải dễ đọc, rõ ràng. Dùng contrast cao, không rối |
| **Trustworthy Blue** | Màu chủ đạo xanh dương (`#246BFD`) truyền cảm giác tin cậy và chuyên nghiệp |
| **Minimal Chrome** | Tối thiểu các decoration. Nội dung là trọng tâm |
| **Card-based UI** | Mọi nhóm thông tin đều được wrap trong card trắng với shadow nhẹ |
| **Consistent Feedback** | Mọi action đều có visual feedback (loading state, snackbar, button press) |

---

## 2. Color System

### Primary Palette

> [!WARNING]
> **Sự sai lệch màu sắc (Color Drift)**: Figma chỉ định màu primary là `#246BFD` (và `ThemeProvider` sử dụng seed color `0xFF246BFD` để tạo scheme mặc định). Tuy nhiên, hầu hết các widget tương tác cốt lõi trong code triển khai thực tế như `PrimaryButton`, active border của `CustomTextField` và màu highlight của thanh điều hướng phía dưới (Bottom Navigation Bar) đều đang được hardcode cố định với màu xanh dương Tailwind Blue-600 (`#2563EB`).

| Token | Hex | Dùng cho |
|---|---|---|
| `primary` | `#246BFD` | CTA buttons, active states, links, progress bars |
| `primary-interactive` | `#2563EB` | Hardcoded trong code thực tế của các widget tương tác chính |
| `primary-dark` | `#0D6EFD` | Balance card gradient, heavy emphasis |
| `primary-light` | `#E8F3FF` | Chip backgrounds, tag backgrounds |

### Neutral Palette

| Token | Hex | Dùng cho |
|---|---|---|
| `gray-900` | `#111827` | Heading, primary text |
| `gray-800` | `#1A1A2E` | Screen titles |
| `gray-700` | `#374151` | Body text, secondary buttons |
| `gray-600` | `#4B5563` | Subtitles, form labels |
| `gray-500` | `#6B7280` | Helper text, captions |
| `gray-400` | `#9CA3AF` | Placeholder, muted labels |
| `gray-300` | `#D1D5DB` | Borders light |
| `gray-200` | `#E5E7EB` | Dividers, input borders |
| `gray-100` | `#F3F4F6` | Input fill, chip background |
| `gray-50`  | `#F9FAFB` | Page background (light screen) |
| `background` | `#F5F7FA` | Page background (goal, detail screens) |
| `white` | `#FFFFFF` | Card surfaces |

### Semantic Palette

> [!CAUTION]
> **Lỗi tương phản WCAG 2.2**: Success badge dạng Light sử dụng nền xanh `#E8FFF3` (hoặc `#D1FAE5`) với chữ màu xanh ngọc `#10B981` (Green-500). Tỷ lệ tương phản của cặp màu này chỉ đạt ~3.04:1, không đáp ứng chuẩn tối thiểu **WCAG AA (4.5:1)** đối với cỡ chữ thông thường. Nhóm thiết kế khuyến nghị thay đổi màu chữ thành Green-700 (`#047857`) để đảm bảo khả năng tiếp cận tốt hơn.

| Token | Hex | Dùng cho |
|---|---|---|
| `success` | `#10B981` | Income, completed goals, positive change |
| `success-text` | `#047857` | Khuyến nghị dùng màu chữ này trên nền nhạt để đạt chuẩn tương phản AA |
| `success-light` | `#D1FAE5` / `#E8FFF3` | Success chip background |
| `warning` | `#F59E0B` | Warning budgets, spending categories |
| `warning-light` | `#FEF3C7` | Warning chip background |
| `danger` | `#EF4444` | Error states, withdraw button |
| `danger-light` | `#FEE2E2` / `#FFF0F0` | Error chip background |
| `purple` | `#8B5CF6` | Goals icon, pie chart segment |
| `purple-light` | `#F3E8FF` | Purple chip background |

### Chart Colors (in order)

```
#2563EB  →  Ăn uống / primary-interactive
#10B981  →  Mua sắm / success
#F59E0B  →  Giải trí / warning (Amber)
#8B5CF6  →  Đi lại / purple
#EF4444  →  Khác / danger (Red)
#06B6D4  →  Cyan
#F43F5E  →  Rose
#8B5CF6  →  Purple-light
```

---

## 3. Typography

**Font family:** `Poppins` (Google Fonts)  
**Import:** `package:google_fonts/google_fonts.dart`

### Scale

| Role | Size | Weight | Color (default) | Usage |
|---|---|---|---|---|
| `displayLarge` | 32px | Bold (700) | `#111827` | Balance amount on dashboard card |
| `displayMedium` | 28px | Bold (700) | `#111827` | Screen hero number, form title |
| `headlineLarge` | 24px | Bold (700) | `#111827` | Section spending trend |
| `headlineMedium` | 20px | Bold (700) | `#1A1A2E` | Goal name in detail screen |
| `titleLarge` | 18px | Bold (700) | `#1A1A2E` | App bar / screen title |
| `titleMedium` | 16px | Bold (700) | `#111827` | Card section headers |
| `titleSmall` | 14px | SemiBold (600) | `#111827` | Goal card name, transaction title |
| `bodyLarge` | 15px | SemiBold (600) | `#4B5563` | Auth screen subtitle |
| `bodyMedium` | 14px | Medium (500) | `#4B5563` | Form labels, body text |
| `bodySmall` | 13px | Regular (400) | `#6B7280` | Info row label, caption |
| `labelLarge` | 16px | SemiBold (600) | `white` | Button label |
| `labelMedium` | 13px | SemiBold (600) | varies | Filter tab, chip text |
| `labelSmall` | 10–11px | Medium (500) | `#9CA3AF` | Nav bar label, deadline hint |

### Rules

- Không dùng font mặc định hệ thống — luôn wrap bằng `GoogleFonts.poppins()`
- Heading màu `#111827` hoặc `#1A1A2E`
- Label/hint màu `#9CA3AF`
- Link/accent màu `#246BFD` (hoặc `#2563EB`)
- Amount positive: `#10B981` | Amount negative / neutral: `#111827`

---

## 4. Spacing & Layout

### Base Unit: 4px

| Token | Value | Dùng cho |
|---|---|---|
| `xs`  | 4px | Icon gap nhỏ |
| `sm`  | 8px | Label ↔ input, icon ↔ text |
| `md`  | 12px | Inner card padding nhỏ |
| `lg`  | 16px | Card padding, section gap |
| `xl`  | 20px | Screen horizontal padding |
| `2xl` | 24px | Section margin, form field gap |
| `3xl` | 32px | Large section spacing |
| `4xl` | 40px | Bottom safe area padding |

### Screen Padding

```dart
// Horizontal page padding
const EdgeInsets.symmetric(horizontal: 20)

// Auth screens
const EdgeInsets.symmetric(horizontal: 24, vertical: 20)

// Card internal padding
const EdgeInsets.all(16)   // Compact card (goal list)
const EdgeInsets.all(20)   // Standard card
const EdgeInsets.all(24)   // Hero card (balance, summary)
```

### Max Width Constraint

```dart
// main.dart — ConstrainedBox áp dụng cho toàn bộ ứng dụng
constraints: const BoxConstraints(maxWidth: 430)
```

---

## 5. Border Radius & Elevation

### Border Radius

| Token | Value | Dùng cho |
|---|---|---|
| `sm` | 8px | Small chip, calendar icon bg |
| `md` | 12px | Budget tag, small card element |
| `lg` | 16px | Input field, goal card, action button |
| `xl` | 20px | Detail card, filter tab (pill) |
| `2xl` | 24px | Dashboard balance card, action menu |
| `full` | 100px | FAB button, avatar, badge pill |

### Box Shadow

```dart
// Card standard shadow
BoxShadow(
  color: Colors.black.withOpacity(0.04),
  blurRadius: 10,
  offset: Offset(0, 2),
)

// Hero card shadow (blue tinted)
BoxShadow(
  color: Color(0xFF246BFD).withOpacity(0.35),
  blurRadius: 20,
  offset: Offset(0, 8),
)

// Header button shadow
BoxShadow(
  color: Colors.black.withOpacity(0.06),
  blurRadius: 8,
  offset: Offset(0, 2),
)

// CTA button shadow (Đóng góp)
BoxShadow(
  color: Color(0xFF246BFD).withOpacity(0.4),
  blurRadius: 12,
  offset: Offset(0, 4),
)
```

---

## 6. Component Library

### 6.1 PrimaryButton

**File:** `lib/features/auth/widgets/primary_button.dart`

```dart
PrimaryButton(
  text: 'Tạo tài khoản',
  onPressed: () {},
  // isOutlined: false (default) → filled blue button
  // isOutlined: true → white outlined button (Google login)
  // icon: Widget? → optional leading icon
)
```

| Variant | Background | Border | Text Color |
|---|---|---|---|
| Filled (default) | `#2563EB` | none | white |
| Outlined | white | `#E5E7EB` 1px | `#374151` |

**Specs:**
- Height: `56px`
- Width: `double.infinity`
- Border radius: `16px`
- Font: Poppins SemiBold 16px

---

### 6.2 CustomTextField

**File:** `lib/features/auth/widgets/custom_text_field.dart`

```dart
CustomTextField(
  label: 'Email',
  hintText: 'example@gmail.com',
  controller: _emailController,
  keyboardType: TextInputType.emailAddress,
  isPassword: false,
  validator: (v) => ...,
)
```

| State | Border | Fill |
|---|---|---|
| Default / Enabled | `#E5E7EB` 1px | `#F3F4F6` |
| Focused | `#2563EB` 1.5px | `#F3F4F6` |
| Error | `red` 1px | `#F3F4F6` |

**Specs:**
- Border radius: `16px`
- Padding: `16px horizontal / 16px vertical`
- Label: Poppins Medium 14px `#4B5563`
- Hint: Poppins 14px `#9CA3AF`

---

### 6.3 ProgressBar (Goal / Budget)

```dart
ClipRRect(
  borderRadius: BorderRadius.circular(4),  // or 6px for detail
  child: LinearProgressIndicator(
    value: 0.72,
    backgroundColor: Color(0xFFE5E7EB),
    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF246BFD)),
    minHeight: 6,  // list card: 6px | detail card: 8px
  ),
)
```

---

### 6.4 Status Badge / Chip

```dart
Container(
  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
  decoration: BoxDecoration(
    color: Color(0xFFE8F3FF),           // active
    // color: Color(0xFFE8FFF3),        // completed
    borderRadius: BorderRadius.circular(20),
  ),
  child: Text(
    'Đang thực hiện',
    style: GoogleFonts.poppins(
      fontSize: 10,
      fontWeight: FontWeight.w600,
      color: Color(0xFF246BFD),         // active
      // color: Color(0xFF10B981),      // completed
    ),
  ),
)
```

---

### 6.5 Bottom Navigation Bar

```dart
// Cấu trúc: 4 items + 1 FAB ở giữa với vết cắt tròn
// Thứ tự: Trang chủ | Giao dịch | [FAB] | Phân tích | Cá nhân

BottomAppBar(
  shape: CircularNotchedRectangle(),
  notchMargin: 8.0,
  color: Colors.white,
  elevation: 8,
)

FloatingActionButton(
  backgroundColor: Color(0xFF2563EB),
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
  child: Icon(Icons.add, color: Colors.white, size: 28),
)
```

| State | Icon Color | Label Color |
|---|---|---|
| Active | `#2563EB` | `#2563EB` |
| Inactive | `#9CA3AF` | `#9CA3AF` |

**Label:** Poppins 10px  
**Icon size:** 24px

---

### 6.6 Header / AppBar Pattern

```dart
// Custom header — không dùng AppBar mặc định
Padding(
  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
  child: Row(
    children: [
      // Back button (circle, white, shadow)
      // Title (Poppins Bold 18px, centered)
      // Action button (circle, white, shadow) OR SizedBox(width: 36)
    ],
  ),
)
```

---

### 6.7 Hero Summary Card (Blue)

Dùng cho: Dashboard balance, Saving Goals summary

```
Background: #246BFD (hoặc #0D6EFD)
Border radius: 20–24px
Padding: 24px all
Decorative circles: white opacity 0.05–0.15
Shadow: primary color tinted, blurRadius 20, offset (0,8)
```

Text hierarchy:
1. Label nhỏ → Poppins 13px white/85%
2. Amount lớn → Poppins Bold 28–32px white
3. Sub-label → Poppins 13px white/85%

---

### 6.8 Info Row (Detail Screen)

```dart
Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [
    Text(label,  // Poppins 13px #6B7280),
    Text(value,  // Poppins SemiBold 14px #1A1A2E),
  ],
)
// Separated by Divider(color: Color(0xFFF3F4F6), height: 24)
```

---

### 6.9 Action Button Pair (Rút tiền / Đóng góp)

```
[   Rút tiền   ]  [   Đóng góp   ]
  white + border    #246BFD filled
```

```dart
// Rút tiền
decoration: BoxDecoration(
  color: Colors.white,
  borderRadius: BorderRadius.circular(14),
  border: Border.all(color: Color(0xFFE5E7EB)),
)

// Đóng góp
decoration: BoxDecoration(
  color: Color(0xFF246BFD),
  borderRadius: BorderRadius.circular(14),
  boxShadow: [BoxShadow(color: primary/40%, blurRadius: 12, offset: (0,4))],
)
```

---

## 7. Screen Inventory

### Auth Flow

| Screen | File | Description |
|---|---|---|
| Splash | `onboarding/screens/splash_screen.dart` | Logo + auto-navigate |
| Onboarding | `onboarding/screens/onboarding_screen.dart` | 3-step intro carousel |
| Login | `auth/screens/login_screen.dart` | Email/password + Google OAuth |
| Register | `auth/screens/signup_screen.dart` | Full name / email / password / confirm |

### Main App (Dashboard)

| Screen | File | Description |
|---|---|---|
| Dashboard | `dashboard/screens/dashboard_screen.dart` | Home tab, balance card, quick actions, transactions |
| Analytics | `analytics/screens/analytics_screen.dart` | Donut chart + line chart spending |
| Profile | `profile/screens/profile_screen.dart` | User info, settings |

### Goal (Mục tiêu)

| Screen | File | Description |
|---|---|---|
| Saving Goals List | `goal/screens/saving_goals_screen.dart` | Tổng tiền + filter tabs + danh sách mục tiêu |
| Goal Detail | `goal/screens/goal_detail_screen.dart` | Chi tiết + progress + lịch sử đóng góp |

### Budget (Ngân sách)

| Screen | File | Description |
|---|---|---|
| Budget List | `budget/screens/budget_screen.dart` | Danh sách ngân sách theo tháng |
| Category Budget Detail | `budget/screens/category_budget_detail_screen.dart` | Chi tiết ngân sách + chỉnh sửa/xóa ngân sách |

### Transaction (Giao dịch)

| Screen | File | Description |
|---|---|---|
| Add Transaction | `transaction/screens/add_transaction_screen.dart` | Tạo giao dịch (tiền chi/tiền thu), số tiền, danh mục, ví, ghi chú |
| Transaction Tab/Screen | `transaction/screens/transaction_screen.dart` | Lịch sử giao dịch, phân loại theo ngày |

---

## 8. Navigation Architecture

```
SplashScreen
    └── OnboardingScreen
            ├── LoginScreen ──────────────────────┐
            └── SignupScreen ─────────────────────┤
                                                   ▼
                                        DashboardScreen (Bottom Nav)
                                        ├── Tab 0: _DashboardTab
                                        │       └── [Action] Mục tiêu
                                        │               └── SavingGoalsScreen
                                        │                       └── GoalDetailScreen
                                        ├── Tab 1: TransactionScreen (Lịch sử Giao dịch)
                                        │       └── [FAB] AddTransactionScreen
                                        ├── Tab 2: AnalyticsScreen (Phân tích)
                                        └── Tab 3: ProfileScreen (Cá nhân)
```

### Route pattern

Toàn bộ dùng `Navigator.push / pushReplacement` với `MaterialPageRoute`.  
Chưa dùng named routes — nếu mở rộng, nên migrate sang `GoRouter`.

---

## 9. Assets

### Images (`assets/images/`)

| File | Dùng cho |
|---|---|
| `logo.png` | App logo chính thức (icon chất lượng cao) |
| `logo.png` | Avatar mặc định khi không tìm thấy URL |
| `DashboardIcon.png` | Floating coin icon trong balance card (110×110) |
| `google_logo.png` | Google OAuth button icon (24×24) |
| `bee.png` | Ảnh chú ong nghệ (fallback cho giọng nói) |
| `bee.json` | Lottie animation chú ong nghệ |

### Icons

Toàn bộ dùng `Icons.*` từ Material Icons. Không dùng custom icon pack.

| Icon | Dùng cho |
|---|---|
| `Icons.home` | Nav – Trang chủ |
| `Icons.receipt_long` | Nav – Giao dịch |
| `Icons.pie_chart` | Nav – Phân tích |
| `Icons.person` | Nav – Cá nhân |
| `Icons.add` | FAB + Header add button |
| `Icons.arrow_back` | Header back button |
| `Icons.savings` | Saving goals summary card |
| `Icons.track_changes` | Mục tiêu quick action |
| `Icons.calendar_today` | Deadline row |
| `Icons.edit` | Edit target amount |
| `Icons.notifications_none` | Dashboard notification bell |
| `Icons.logout` | Đăng xuất tài khoản |

---

## 10. Coding Conventions

### File Structure

```
lib/
├── core/
│   ├── network/        # ApiClient, dio setup
│   └── utils/          # SnackbarUtils, formatters
├── features/
│   └── <feature>/
│       ├── models/     # Data models / DTOs
│       ├── providers/  # Provider states (ChangeNotifier)
│       ├── screens/    # Full screens (Scaffold)
│       ├── services/   # API service layer
│       └── widgets/    # Reusable widgets (feature-scoped)
└── shared/             # App-wide shared widgets
```

### Widget Guidelines

```dart
// ✅ Luôn dùng GoogleFonts.poppins()
style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600)

// ✅ Luôn dùng const Color với hex code cụ thể
color: const Color(0xFF2563EB) // Ưu tiên cho tương tác hệ thống

// ✅ Luôn có errorBuilder cho Image.asset hoặc Image.network
errorBuilder: (_, __, ___) => const Icon(Icons.error, ...)

// ✅ Wrap scrollable content trong SafeArea
body: SafeArea(child: SingleChildScrollView(...))

// ✅ Bottom padding cho danh sách tránh bị che bởi nav bar
const SizedBox(height: 80)
```

### State Management

- **Provider** (`ChangeNotifier`) quản lý state cục bộ và api (Auth, Budget, Transaction, Category, Theme).
- Màn hình cục bộ dùng `StatefulWidget` + `setState()`.

### Money Formatting

```dart
String formatMoneyFull(int amount) {
  // Output: "2.800.000đ"
  final str = amount.toString();
  final result = StringBuffer();
  int count = 0;
  for (int i = str.length - 1; i >= 0; i--) {
    if (count > 0 && count % 3 == 0) result.write('.');
    result.write(str[i]);
    count++;
  }
  return '${result.toString().split('').reversed.join('')}đ';
}
```

### Deprecation Notes

- `withOpacity()` → Flutter >= 3.27 deprecate phương thức này. Cân nhắc dùng `withValues(alpha: ...)` khi nâng cấp SDK.
- `Colors.black.withOpacity(0.04)` → Vẫn hoạt động trong SDK hiện tại của ứng dụng.

---

## 11. Hướng dẫn Tiếp cận (Accessibility - WCAG 2.2)

### Kích thước Mục tiêu Cảm ứng (Touch Targets)

Để đáp ứng tiêu chuẩn **WCAG 2.2 Success Criterion 2.5.8 (Target Size - Minimum)**, toàn bộ giao diện FINORA tuân thủ nghiêm ngặt kích thước vùng nhấn như sau:
- **Nút bấm chính (Buttons)**: Các nút dạng `PrimaryButton` hoặc nút hành động lớn phải có chiều cao tối thiểu là **56px** (hoặc vùng cảm ứng tương đương 48px).
- **Biểu tượng tương tác (Icons)**: Các nút biểu tượng (như nút Back, IconButton trên AppBar, Switch) phải có vùng nhấn tối thiểu là **48px x 48px**. Nếu kích thước visual của icon nhỏ hơn (ví dụ: 24px), code phải sử dụng thêm `Padding` hoặc thiết lập thuộc tính `constraints: BoxConstraints()` tối thiểu của `IconButton` để tránh gây khó khăn khi thao tác cảm ứng.

### Ràng buộc về Tỷ lệ và Co giãn Chữ (Text Scaling Constraints)

Ứng dụng hỗ trợ co giãn kích thước phông chữ theo cài đặt hệ thống của người dùng để nâng cao khả năng tiếp cận (Accessibility). Tuy nhiên, để tránh phá vỡ giao diện trong các layout cố định:
- Các chữ hiển thị trong Header, AppBar, bottom nav, hoặc nút bấm chính phải được bọc trong widget giới hạn tỉ lệ co giãn chữ tối đa `maxScaleFactor`:
```dart
MediaQuery.withClampedTextScaling(
  minScaleFactor: 1.0,
  maxScaleFactor: 1.3,
  child: child,
)
```
- Các khối nội dung dài (như tên mục tiêu, ghi chú giao dịch) sử dụng thuộc tính `overflow: TextOverflow.ellipsis` kết hợp `maxLines` để tự động thu gọn thay vì làm tràn hoặc vỡ layout của Card chứa chúng.

### Vấn đề Tương phản & Giải pháp Khắc phục (Contrast Ratios)

Trong quá trình đối soát và kiểm thử (Audit), chúng tôi phát hiện một số điểm cần cải thiện về độ tương phản:
1. **Trạng thái Hoàn thành (Success Badge)**: Màu chữ `#10B981` (xanh lục nhạt) trên nền `#E8FFF3` chỉ đạt tỷ lệ tương phản **3.04:1**. 
   - *Giải pháp*: Cập nhật mã màu chữ sang màu xanh sẫm `#047857` (đạt tỷ lệ **4.8:1**), hoàn toàn đáp ứng chuẩn WCAG 2.2 AA.
2. **Placeholder của TextField**: Màu `#9CA3AF` trên nền xám nhạt `#F3F4F6` đạt tỷ lệ tương phản thấp. 
   - *Khuyến nghị*: Chuyển màu placeholder sang `#6B7280` để đạt độ tương phản tốt hơn (> 4.5:1).

---

## 12. Trạng thái của Hợp phần (Component States)

Hệ thống UI FINORA quản lý trạng thái của các widget qua các visual states khác nhau:

### 1. Nút Bấm Chính (PrimaryButton)

- **Trạng thái Mặc định (Default)**: Nền màu xanh dương `#2563EB` (hoặc `#246BFD`), chữ trắng Poppins SemiBold 16px, không viền, có bóng đổ nhẹ.
- **Trạng thái Nhấn (Pressed)**: Màu nền tối đi 10% (xuống khoảng `#1D4ED8`), bóng đổ co hẹp lại để tạo cảm giác nút bị nén xuống mặt phẳng.
- **Trạng thái Bị Vô hiệu hóa (Disabled)**: Nền xám nhạt `#E5E7EB`, chữ màu xám `#9CA3AF`, không có phản hồi cảm ứng, bóng đổ biến mất.
- **Trạng thái Đang tải (Loading)**: Chiều rộng nút giữ nguyên, nhãn chữ ẩn đi và thay thế bằng một vòng xoay tiến trình `CircularProgressIndicator` màu trắng ở giữa (kích thước tối đa 20px).

### 2. Ô Nhập Liệu (CustomTextField)

- **Trạng thái Mặc định (Default / Enabled)**: Đường viền xám mỏng `#E5E7EB` 1px, nền xám nhạt `#F3F4F6`, chữ đen `#111827`.
- **Trạng thái Lấy Nét (Focused)**: Đường viền dày **1.5px** màu xanh dương tương tác `#2563EB`. Nhãn nhô lên (label) có màu tương đương.
- **Trạng thái Vô hiệu hóa (Disabled)**: Nền `#E5E7EB` xám đục, chữ nhạt `#9CA3AF`.
- **Trạng thái Báo lỗi (Error)**: Đường viền chuyển sang màu đỏ `#EF4444` 1px. Dưới ô nhập xuất hiện helper text báo lỗi có màu đỏ Poppins 12px.

### 3. Công Tắc (Switch - Chế độ Tối)

- **Trạng thái Bật (Active)**: Thumb di chuyển sang phải, màu nền track chuyển sang xanh dương `#2563EB`, thumb màu trắng.
- **Trạng thái Tắt (Inactive)**: Thumb di chuyển sang trái, màu nền track màu xám nhạt `#E5E7EB` hoặc đậm hơn tùy thuộc chủ đề sáng/tối.

---

## 13. Thiết kế Đáp ứng (Responsive Design)

Ứng dụng FINORA được tối ưu hóa cho màn hình điện thoại di động thông minh (smartphones).

### Giới hạn Chiều rộng Toàn cục (App-wide Max-width Constraint)

Nhằm đảm bảo giao diện không bị méo mó, co giãn quá đà trên các thiết bị màn hình rộng (như máy tính bảng, điện thoại gập, hoặc khi chạy trên web/desktop), file `main.dart` đã cài đặt một bộ ràng buộc giới hạn chiều rộng tối đa tại root widget:
```dart
ConstrainedBox(
  constraints: const BoxConstraints(maxWidth: 430),
  child: child,
)
```
- Khi chạy trên thiết bị có bề ngang rộng hơn **430px** (ví dụ: máy tính bảng), giao diện ứng dụng sẽ được căn giữa màn hình với các phần lề hai bên tự động canh đều (centered layout).

### Khả năng Thích ứng Chất lỏng (Fluid Layout Adaptations)

- **Grid và Spacing**: Không sử dụng các khoảng cách cố định (hardcoded margin lớn) mà sử dụng hệ thống layout co giãn linh hoạt (`Expanded`, `Flexible` và `Spacer`).
- **Cuộn trang an toàn**: Toàn bộ các màn hình hiển thị biểu mẫu hoặc nội dung động đều được bọc trong `SingleChildScrollView` nhằm ngăn lỗi tràn pixel (Yellow-black striped overflow error) khi bàn phím ảo (virtual keyboard) xuất hiện.

---

## 14. Hướng dẫn Chuyển động (Motion Guidelines)

Chuyển động trong FINORA giúp nâng cao trải nghiệm người dùng, làm ứng dụng mượt mà và trực quan.

### Thời gian và Đường cong Chuyển động (Transitions & Curves)

| Tên Chuyển động | Thời gian | Đường cong (Curve) | Mô tả |
|---|---|---|---|
| **Chuyển trang (Route Transition)** | 300ms | `Curves.easeInOut` | Chuyển động trượt ngang mặc định của hệ thống |
| **Báo động trên cùng (Top SnackBar)** | 300ms | `Curves.easeOutCubic` | Trượt nhanh từ mép trên màn hình xuống dưới |
| **Mở rộng/Thu gọn (Splash Logo)** | 1300ms | `Curves.easeOutCubic` | Thu nhỏ logo dần dần để tạo chiều sâu |
| **Giọng nói (Voice Wave)** | 800ms | Lặp lại | Hiệu ứng đập của sóng âm khi đang lắng nghe |

### Hiệu ứng Splash Screen

Quy trình hoạt ảnh hoạt động trong tổng thời gian **1800ms** (với thời gian chờ khởi tạo ban đầu là **500ms**):
1. **Hoạt ảnh Logo (Scale Animation)**: Logo bắt đầu từ tỷ lệ **2.0** thu nhỏ dần về tỉ lệ **1.0** (Khoảng thời gian: `0.0` - `0.4`, Curve: `Curves.easeOutCubic`).
2. **Hoạt ảnh Chữ (Text Animation)**:
   - Chiều ngang hộp chữ mở rộng dần từ **0.0** đến **1.0** (Khoảng thời gian: `0.4` - `0.8`, Curve: `Curves.easeInOutCubic`).
   - Độ mờ chữ (Opacity) chuyển dần từ **0.0** sang **1.0** (Khoảng thời gian: `0.6` - `1.0`, Curve: `Curves.easeIn`).

### Cơ chế Đè giữ Giọng nói (Push-to-Talk Gesture mechanics)

Màn hình thêm giao dịch bằng giọng nói (`VoiceInputBottomSheet`) áp dụng cơ chế điều khiển thông qua cử chỉ giữ (long press):
- **onLongPressDown (Bắt đầu nói)**:
  - Nền nút Micro đổi màu từ xanh dương `#2563EB` sang màu đỏ báo hiệu ghi âm `#EF4444`.
  - Icon đổi sang dạng không ruột `Icons.mic_none`.
  - Dòng text trạng thái chuyển sang màu đen và đổi nội dung thành `"Đang lắng nghe..."`.
  - Đèn sóng xung quanh nút nhấp nháy liên tục (animated shadow).
- **onLongPressUp / onLongPressCancel (Kết thúc nói)**:
  - Nút Micro hoàn màu về xanh dương `#2563EB`, icon đổi về `Icons.mic`.
  - Gửi dữ liệu âm thanh đã nhận diện để AI phân tích.
  - Hiển thị hiệu ứng tải `CircularProgressIndicator` xoay tròn trong thời gian AI phân tích.
- **Tài sản Lottie (Ong nghệ)**:
  - Khi người dùng giữ ghi âm, ứng dụng phát hoạt ảnh đập cánh tốc độ cao từ tệp cấu hình Lottie `assets/images/bee.json`.
  - Nếu tệp Lottie gặp sự cố tải, giao diện lập tức fallback về hiển thị ảnh tĩnh `assets/images/bee.png` kèm icon microphone nhấp nháy.

---

## 15. Hệ thống Bóng đổ (Elevation System)

Hệ thống bóng đổ trong FINORA phân cấp giao diện theo chiều sâu (Z-axis).

### 1. Bóng đổ Card Tiêu chuẩn (Standard Card Shadow)
- Sử dụng cho các Card thông tin chi tiêu, danh sách mục tiêu.
- Cấu hình:
```dart
BoxShadow(
  color: Colors.black.withOpacity(0.04),
  blurRadius: 10,
  offset: const Offset(0, 4),
)
```

### 2. Bóng đổ Card Nổi bật (Hero Blue Shadow)
- Sử dụng riêng cho Card số dư (Balance Card) và Card tổng hợp ở màn hình chính.
- Cấu hình:
```dart
BoxShadow(
  color: const Color(0xFF246BFD).withOpacity(0.35),
  blurRadius: 20,
  offset: const Offset(0, 8),
)
```

### 3. Bóng đổ Nút Tiêu đề (Header Action Button Shadow)
- Sử dụng cho các nút tròn trên AppBar tự chế (Back, Edit, Settings).
- Cấu hình:
```dart
BoxShadow(
  color: Colors.black.withOpacity(0.06),
  blurRadius: 8,
  offset: const Offset(0, 2),
)
```

### 4. Bóng đổ Nút Kêu gọi Hành động (CTA Button Shadow)
- Sử dụng cho các nút bấm lớn quan trọng cuối màn hình như "Đóng góp", "Tạo giao dịch".
- Cấu hình:
```dart
BoxShadow(
  color: const Color(0xFF246BFD).withOpacity(0.4),
  blurRadius: 12,
  offset: const Offset(0, 4),
)
```

---

## 16. Hệ thống Biểu tượng (Iconography)

Ứng dụng sử dụng bộ Material Icons của Google.

### Kích thước Chuẩn (Icon Sizes)

- **24px**: Kích thước tiêu chuẩn của icon trong danh sách, các trường nhập liệu và Bottom Navigation Bar.
- **26px - 28px**: Kích thước của biểu tượng Floating Action Button (FAB) trung tâm.
- **40px**: Kích thước biểu tượng micro thu âm lớn trong Bottom Sheet nhập liệu bằng giọng nói.

### Ánh xạ Biểu tượng Mục tiêu động (Goal Category mapping)

Lớp `GoalIconMapper` chịu trách nhiệm phân tích dữ liệu dạng chuỗi và trả về widget biểu tượng phù hợp:
- **Ánh xạ tĩnh (Static Icons)**:
  - `'beach_access'` → `Icons.beach_access` (Du lịch)
  - `'flight'` → `Icons.flight` (Vé máy bay)
  - `'home'` → `Icons.home` (Mua nhà)
  - `'school'` → `Icons.school` (Học tập)
  - `'savings'` → `Icons.savings` (Tiết kiệm)
  - `'directions_car'` → `Icons.directions_car` (Mua xe)
  - `'shopping_bag'` → `Icons.shopping_bag` (Mua sắm)
  - `'restaurant'` → `Icons.restaurant` (Ăn uống)
  - `'monitor'` → `Icons.monitor` (Công nghệ)
  - `'favorite'` → `Icons.favorite` (Sức khỏe)
  - `'fitness_center'` → `Icons.fitness_center` (Thể thao)
  - `'motorcycle'` → `Icons.motorcycle` (Xe máy)
  - `'laptop'` → `Icons.laptop` (Thiết bị)
  - `'phone_iphone'` → `Icons.phone_iphone` (Điện thoại)
  - `'chair'` → `Icons.chair` (Nội thất)
  - *Mặc định*: `Icons.star`
- **Ánh xạ động (Dynamic URLs)**:
  - Nếu chuỗi đầu vào bắt đầu bằng `http://` hoặc `https://`, mapper sẽ bọc link ảnh trong `ClipOval` và tải ảnh từ internet thông qua `Image.network`.
  - Có cấu hình `errorBuilder` để tự động trả về biểu tượng `Icons.error` nếu không tải được hình ảnh từ URL.

---

## 17. Giao diện Sáng/Tối (Theme System - Light/Dark Scheme)

Ứng dụng FINORA hỗ trợ chuyển đổi giao diện sáng/tối linh hoạt, lưu trữ cấu hình qua `SharedPreferences` bằng khóa lưu trữ `is_dark_mode`.

### Bảng Ánh xạ Token Màu Sáng / Tối

| Tên Token | Chế độ Sáng (Light Scheme) | Chế độ Tối (Dark Scheme) |
|---|---|---|
| **Scaffold Background** | `#F9FAFB` (Trắng xám) | `#1F2937` (Màu tối) |
| **Card Background** | `#FFFFFF` (Trắng tinh) | `#111827` (Màu đen sẫm) |
| **Text Primary** | `#111827` (Đen đậm) | `#FFFFFF` (Trắng tinh) |
| **Text Secondary** | `#4B5563` (Xám đen) | `#D1D5DB` (Xám nhạt) |
| **Border / Divider** | `#F3F4F6` (Xám nhạt) | `#374151` (Xám đậm) |

> [!CAUTION]
> **Sự bất đồng nhất trong Chế độ Tối (Theme Inversion Quirks)**:
> 1. **Đảo lộn nền Scaffold và AppBar**:
>    - Tại màn hình Ngân sách (`BudgetScreen`), nền Scaffold có màu đen sẫm `#111827` trong khi AppBar có màu xám sáng hơn `#1F2937`.
>    - Tuy nhiên, tại màn hình Lịch sử Giao dịch (`TransactionScreen`), bố cục này bị đảo ngược hoàn toàn (nền Scaffold là xám `#1F2937` và AppBar lại là đen sẫm `#111827`).
> 2. **Lỗi cứng giao diện trong Modal Sửa Ngân Sách**:
>    - Hộp thoại Modal sửa ngân sách trong `category_budget_detail_screen.dart` bị code cứng nền trắng (`Colors.white`) và màu chữ tối, làm ảnh hưởng đến trải nghiệm người dùng khi đang bật chế độ tối.

---

## 18. Quy tắc Bố cục (Layout Rules)

Hệ thống lưới và bố cục của FINORA tuân thủ chặt chẽ:
- **Base Grid**: 4px làm đơn vị cơ bản. Tất cả các chiều cao, khoảng cách và khoảng đệm (paddings) đều là bội số của 4 (ví dụ: 4, 8, 12, 16, 20, 24, 32, 40).
- **Lề trang mặc định (Page Margin)**: Luôn thiết lập khoảng cách lề hai bên trang (horizontal margin) là **20px**.
- **Khoảng cách bên trong Card (Card Gutters)**: Khoảng đệm bên trong các Card thông tin tiêu chuẩn là **16px** hoặc **20px** để cân đối khoảng trống và nội dung.

---

## 19. Thiết kế Biểu mẫu (Forms)

Hệ thống biểu mẫu trong FINORA tích hợp xác thực dữ liệu tại chỗ (inline validation) để đảm bảo chất lượng nhập liệu.

### Quy tắc Xác thực (Validation Patterns)

- **Trường Email**:
  - Không được bỏ trống.
  - Định dạng email hợp lệ theo biểu thức chính quy regex:
    ```dart
    RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
    ```
- **Mật khẩu (Password)**:
  - Độ dài tối thiểu phải đạt từ **6 ký tự** trở lên.
  - Phải trùng khớp giữa hai trường "Mật khẩu" và "Xác nhận mật khẩu" ở màn hình Đăng ký.
- **Số tiền giao dịch / Ngân sách**:
  - Phải nhập ký tự số hợp lệ, giá trị phải lớn hơn `0`.
  - Tự động lọc bỏ các ký tự phân tách hàng nghìn trước khi gửi lên API để tránh lỗi phân tích số thực.

### Trình ẩn/hiện mật khẩu (Password Obfuscation Toggle)

- Ở màn hình Đăng nhập và Đăng ký, các trường mật khẩu đi kèm một icon tương tác `IconButton` ở cuối hộp nhập (suffix icon):
  - Nhấp vào biểu tượng `Icons.visibility_off` để ẩn mật khẩu (dạng ký tự dấu chấm `obscureText: true`).
  - Nhấp vào biểu tượng `Icons.visibility` để hiển thị mật khẩu trực quan dưới dạng ký tự thường (`obscureText: false`).

---

## 20. Cấu trúc Điều hướng (Navigation)

Hệ thống điều hướng trong FINORA sử dụng mô hình điều hướng đa lớp.

### Thanh điều hướng dưới cắt viền (Notched Bottom App Bar)

- Sử dụng widget `BottomAppBar` có đường cắt lõm tròn ở giữa (`shape: CircularNotchedRectangle()`) để ôm trọn viền của nút Floating Action Button (FAB).
- Tham số khoảng cách notch margin là **8.0px** để tạo khoảng hở thẩm mỹ tinh tế giữa FAB và thanh điều hướng.

### Luồng Điều hướng Đè (Modal Overlays / Bottom Sheets)

- **Màn hình chọn Danh mục / Nhập liệu Giọng nói**: Được gọi thông qua phương thức `showModalBottomSheet`.
- **Ràng buộc chiều cao**: Các Bottom Sheet chỉ được phép chiếm tối đa **45% - 50%** chiều cao màn hình để người dùng vẫn cảm nhận được bối cảnh của màn hình bên dưới.
- **Hỗ trợ kéo đóng**: Có một thanh điều khiển màu xám nhỏ `Container` ở mép trên cùng của Bottom Sheet (kích thước **40px x 4px**, bo tròn góc) làm gợi ý trực quan cho thao tác kéo xuống để đóng.

---

## 21. Hệ thống Phản hồi (Feedback)

### 1. Báo động Trượt từ Phía trên (Top SnackBar)

Sử dụng tiện ích tự chế `SnackBarUtils.showTopSnackBar` để hiển thị thông báo khẩn cấp:
- **Hoạt ảnh**: Trượt từ trên đỉnh màn hình xuống sử dụng `SlideTransition` phối hợp với hiệu ứng `Tween<Offset>(begin: Offset(0, -1), end: Offset.zero)`.
- **Độ dài hoạt ảnh**: **300ms** với đường cong chuyển động nhanh `Curves.easeOutCubic`.
- **Tự động đóng**: Ẩn đi sau khoảng thời gian **3 giây** (3-second timeout).
- **Phân loại Trực quan**:
  - *Thành công (Success)*: Nền xanh lục nhạt `#D1FAE5`, viền lục đậm `#10B981`, chữ lục sẫm.
  - *Lỗi (Error)*: Nền đỏ nhạt `#FEE2E2`, viền đỏ đậm `#EF4444`, chữ đỏ sẫm.

### 2. Hộp thoại Xác nhận (Confirmation Dialogs)

Sử dụng `showDialog` với giao diện bo góc tròn **16px**, hỗ trợ chế độ tối đầy đủ:
- **Hủy (Cancel Action)**: Đặt ở góc dưới bên trái nút bấm chính, nhãn chữ màu xám `#6B7280` thông thường.
- **Đồng ý/Đăng xuất**: Nhãn chữ màu đỏ đậm `#EF4444` và có trọng số chữ Bold để nhấn mạnh hành động mang tính hủy hoại.

---

## 22. Hệ thống Biểu đồ (Charts)

FINORA sử dụng hai kỹ thuật vẽ biểu đồ khác nhau để tối đa hóa khả năng hiển thị trực quan dữ liệu tài chính:

### 1. Thư viện fl_chart (Màn hình Phân tích)

- **Biểu đồ hình Bánh (PieChart/Donut)**:
  - Cắt lõm tâm biểu đồ (`centerSpaceRadius: 40`).
  - Khoảng hở giữa các phần bánh là `2px`.
  - Độ rộng vành bánh (radius) là `20px`.
  - Không vẽ tiêu đề chữ trực tiếp trên vành bánh (title: `''`) để tránh rối giao diện, thay vào đó hiển thị danh sách chú giải (Legend) ở bên cạnh kèm tỉ lệ phần trăm làm tròn một chữ số thập phân (`.toStringAsFixed(1)`).
- **Biểu đồ Đường xu hướng (LineChart)**:
  - Lưới dọc bị ẩn đi (`drawVerticalLine: false`), lưới ngang dạng nét đứt màu xám nhạt `#F3F4F6`, độ dày nét vẽ 1px, khoảng giãn nét đứt `[5, 5]`.
  - Trục ngang hiển thị nhãn số ngày cách quãng 5 đơn vị. Trục đứng và hai trục phụ khác bị ẩn nhãn số tiền để giảm độ tải thông tin.
  - Nét vẽ biểu đồ cong mềm mại (`isCurved: true`), màu xanh dương `#2563EB`, độ dày đường vẽ 3px.
  - Bên dưới đường cong được tô chuyển sắc nhẹ (opacity 10% của màu xanh dương) để biểu đồ trông sang trọng hơn.

### 2. Trình Vẽ Thủ Công (Custom DonutChartPainter)

Được sử dụng tại màn hình chính Dashboard để tăng tốc độ dựng hình (rendering) và tối ưu dung lượng:
- **Kỹ thuật tính toán**:
  - Dựng hình trên `Canvas` bằng cách vẽ các cung tròn (`drawArc`) xung quanh điểm tâm có tọa độ `Offset(size.width / 2, size.height / 2)`.
  - Bán kính được tính tự động dựa trên chiều ngang canvas và độ dày nét vẽ:
    ```dart
    double radius = (size.width - strokeWidth) / 2;
    ```
  - **Góc bắt đầu**: Đặt ở góc chính giữa phía trên tương ứng với `-3.14159 / 2` radian (tức góc `-90` độ).
  - **Góc quét (Sweep Angle)**: Tính dựa trên tỷ lệ phần trăm chi tiêu của từng danh mục nhân với tổng chu vi đường tròn bằng radian (`2 * 3.14159` radian):
    ```dart
    double sweepAngle = expenses[i].percentage * 2 * 3.14159;
    ```

---

## Changelog

| Ngày | Phiên bản | Nội dung Thay đổi |
|---|---|---|
| 2026-06-07 | v0.1 | Khởi tạo dự án, màn hình giới thiệu (Onboarding) và Đăng nhập/Đăng ký |
| 2026-06-07 | v0.2 | Hoàn thiện Trang chính, Phân tích biểu đồ và Cá nhân |
| 2026-06-10 | v0.3 | Dựng màn hình Danh sách mục tiêu tích lũy và Chi tiết mục tiêu |
| 2026-07-02 | v1.0 | Đồng bộ hóa toàn bộ tài liệu thiết kế với mã nguồn Flutter thực tế, bổ sung 12 chương thiết kế chi tiết bao gồm Khả năng tiếp cận WCAG 2.2, Chuyển động, Bóng đổ, Trạng thái widget và Toán học biểu đồ |

---

*Biên soạn bởi Đội ngũ Phát triển FINORA — Cập nhật lần cuối ngày 2026-07-02*
