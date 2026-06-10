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

| Token | Hex | Dùng cho |
|---|---|---|
| `primary` | `#246BFD` | CTA buttons, active states, links, progress bars |
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

| Token | Hex | Dùng cho |
|---|---|---|
| `success` | `#10B981` | Income, completed goals, positive change |
| `success-light` | `#D1FAE5` / `#E8FFF3` | Success chip background |
| `warning` | `#F59E0B` | Warning budgets, spending categories |
| `warning-light` | `#FEF3C7` | Warning chip background |
| `danger` | `#EF4444` | Error states, withdraw button |
| `danger-light` | `#FEE2E2` / `#FFF0F0` | Error chip background |
| `purple` | `#8B5CF6` | Goals icon, pie chart segment |
| `purple-light` | `#F3E8FF` | Purple chip background |

### Chart Colors (in order)

```
#246BFD  →  Ăn uống / primary
#10B981  →  Mua sắm / success
#8B5CF6  →  Giải trí / purple
#60A5FA  →  Đi lại / blue-light
#F59E0B  →  Khác / warning
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
- Link/accent màu `#246BFD`
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
// main.dart — ConstrainedBox
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
// Structure: 4 items + 1 FAB (center docked)
// Items: Trang chủ | Giao dịch | [FAB] | Phân tích | Cá nhân

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

### Budget (Ngân sách) — In Progress

| Screen | File | Description |
|---|---|---|
| Budget List | `budget/screens/` | Danh sách ngân sách theo tháng |
| Create Budget | `budget/screens/` | Tạo ngân sách mới |

### Transaction (Giao dịch) — In Progress

| Screen | File | Description |
|---|---|---|
| Transaction List | `transaction/screens/` | Lịch sử giao dịch + filter |
| Create Transaction 1 | `transaction/screens/` | Chọn loại, số tiền |
| Create Transaction 2 | `transaction/screens/` | Chọn ví, danh mục, note |

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
                                        ├── Tab 1: (Giao dịch — placeholder)
                                        ├── Tab 2: AnalyticsScreen
                                        └── Tab 3: ProfileScreen
```

### Route pattern

Toàn bộ dùng `Navigator.push / pushReplacement` với `MaterialPageRoute`.  
Chưa dùng named routes — nếu mở rộng, nên migrate sang `GoRouter`.

---

## 9. Assets

### Images (`assets/images/`)

| File | Dùng cho |
|---|---|
| `Logo.png` | App logo (24×24), dashboard avatar |
| `DashboardIcon.png` | Floating coin icon trong balance card (110×110) |
| `google_logo.png` | Google OAuth button icon (24×24) |
| `goal_hawaii.png` | Placeholder avatar mục tiêu |

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
│       ├── providers/  # ChangeNotifier providers
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
color: const Color(0xFF246BFD)

// ✅ Luôn có errorBuilder cho Image.asset
errorBuilder: (_, __, ___) => const Icon(Icons.beach_access, ...)

// ✅ Wrap scrollable content trong SafeArea
body: SafeArea(child: SingleChildScrollView(...))

// ✅ Bottom padding cho danh sách tránh bị che bởi nav bar
const SizedBox(height: 80)
```

### State Management

- **Provider** (`ChangeNotifier`) cho auth state
- Màn hình local state dùng `StatefulWidget` + `setState()`
- Chưa integrate data providers cho Goal/Budget — cần thêm khi kết nối API

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

- `withOpacity()` → Flutter >= 3.27 deprecates this. Cân nhắc migrate sang `withValues(alpha: ...)` khi upgrade SDK.
- `Colors.black.withOpacity(0.04)` → vẫn hoạt động, chỉ hiện warning

---

## Changelog

| Date | Version | Changes |
|---|---|---|
| 2026-06-07 | v0.1 | Init project, Onboarding + Auth screens |
| 2026-06-07 | v0.2 | Dashboard, Analytics, Profile screens |
| 2026-06-10 | v0.3 | Saving Goals List + Goal Detail screens |

---

*Maintained by FINORA Team — last updated 2026-06-10*
