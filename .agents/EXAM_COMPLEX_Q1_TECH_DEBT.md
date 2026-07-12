# COMPLEX Q1 – Technical Debt
> **Câu hỏi gốc:** Đoạn code quản lý `{...}` đang gặp vấn đề gì về thiết kế (Code Smell/Technical Debt)? Nếu dự án scale lên 50 màn hình, cách làm này sẽ gây ra thảm họa gì? Hãy đề xuất cách Refactor.

---

## Trường hợp 1: `{...}` = Quản lý màu sắc (Colors) và Fonts

**Thầy hỏi:** Hiện tại app đang dùng `Color(0xFF2563EB)` và `GoogleFonts.inter` ở khắp mọi nơi. Nếu dự án có 50 màn hình, cách làm này gây hậu quả gì? Phải refactor như thế nào?

**Trả lời:**
**Vấn đề (Technical Debt / Code Smell):**
- **Hardcode Magic Values:** Màu sắc và font chữ đang bị "cứng hóa" ngay trong từng widget. Code Smell này gọi là *Shotgun Surgery* – nếu sếp yêu cầu đổi màu chủ đạo từ xanh sang đỏ, dev phải mở 50 file, tìm và thay thế (Find & Replace) thủ công. Việc này dễ sai sót, bỏ sót.
- Không thể làm White-label app (App đổi theme theo từng khách hàng công ty).

**Cách Refactor:**
1. Tạo file `lib/core/constants/app_colors.dart` và `app_text_styles.dart`:
```dart
class AppColors {
  static const primary = Color(0xFF2563EB);
  static const income = Color(0xFF10B981);
  static const expense = Color(0xFFEF4444);
}
```
2. **Khuyên dùng:** Định nghĩa trực tiếp vào `ThemeData` ở `main.dart`:
```dart
ThemeData(
  colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
  textTheme: GoogleFonts.interTextTheme(),
)
```
3. Ở UI, dùng: `Theme.of(context).colorScheme.primary`. Đổi màu chỉ cần sửa ở 1 file duy nhất.

---

## Trường hợp 2: `{...}` = `FloatingVoiceButton`

**Thầy hỏi:** File `floating_voice_button.dart` dài hơn 400 dòng. Các chức năng nào đang bị gộp chung? Nếu scale lên, cần maintain thì phải tách nó ra sao?

**Trả lời:**
**Vấn đề:** Lỗi vi phạm **Single Responsibility Principle (SRP)**. File này đang ôm đồm:
1. Giao diện (Animation, Layout Lottie)
2. Logic kéo thả (Gesture Pan/Drag)
3. Logic bay tự động (Idle Flight mode)
4. Tương tác ghi âm (Voice Recording Service)
5. Business logic gọi API (Analyze Voice) và điều hướng.

Nếu scale, file này sẽ phình to thành "God Class", cực kỳ khó debug. Nếu Lottie bị khựng, người sửa vô tình có thể làm hỏng luôn chức năng thu âm.

**Cách Refactor:**
Tách State ra khỏi UI:
1. **Tạo `VoiceButtonController` (hoặc Provider mới):** Xử lý state `isRecording`, `isAnalyzing`, gọi `startListening()` và gọi `analyzeVoice()`.
2. **Tách Custom Widget `DraggableBeeWidget`:** Chỉ nhận input (drag/tap) và xử lý animation bay/bobbing. Không chứa logic API.
3. **`FloatingVoiceButton`:** Chức năng là một Wrapper kết nối UI `DraggableBeeWidget` và `VoiceButtonController`.

---

## Trường hợp 3: `{...}` = Tiêm phụ thuộc (Dependency Injection) của Service

**Thầy hỏi:** Hiện tại `TransactionProvider` đang gọi trực tiếp `TransactionService()`. Cách khởi tạo này có vấn đề gì khi ta muốn viết Unit Test? Đề xuất cách sửa.

**Trả lời:**
**Vấn đề:**
```dart
class TransactionProvider extends ChangeNotifier {
  final TransactionService _service = TransactionService(); // Khởi tạo cứng
}
```
Lỗi vi phạm **Dependency Inversion Principle (DIP)**. Provider bị trói chặt (Tight-coupling) với một 구현 (Implementation) cụ thể có kết nối Internet thật.
Khi viết Unit Test cho `TransactionProvider`, ta không muốn gọi API thật (sẽ bị chậm, tốn data, lỗi mạng làm test fail). Nhưng vì khai báo cứng nên ta **không thể Mock (làm giả)** được cái Service đó.

**Cách Refactor (Sử dụng DI):**
Sửa hàm khởi tạo để Service được tiêm từ ngoài vào:
```dart
class TransactionProvider extends ChangeNotifier {
  final TransactionService _service; // Chỉ giữ tham chiếu
  
  // Tiêm qua Constructor
  TransactionProvider({required TransactionService service}) : _service = service;
}
```
Tại `main.dart` (hoặc dùng `get_it`):
```dart
ChangeNotifierProvider(
  create: (_) => TransactionProvider(service: TransactionService()), // Bản thật
)
```
Khi test: `TransactionProvider(service: MockTransactionService())` (Bản giả).

---

## Trường hợp 4: `{...}` = `ApiClient` và xử lý Exception

**Thầy hỏi:** Trong `TransactionService`, khi gọi API thất bại, code throw ra string `'Lỗi kết nối mạng'`. Provider lại dùng `if (e.toString().contains('Lỗi kết nối mạng'))` để nhận diện và cho lưu offline. Điều này tệ ở đâu?

**Trả lời:**
**Vấn đề (Code Smell):** *String Typing / Magic Strings*.
Sử dụng một chuỗi String (tiếng Việt) để đối chiếu logic điều khiển luồng là cực kỳ mong manh.
Nếu một bạn dev khác thấy thông báo này "hơi phèn" và sửa thành `'Không có kết nối Internet'` trong file Service. Tự nhiên tính năng lưu Offline trong Provider bị gãy hoàn toàn (vì hàm `contains` trả về `false`).
Hậu quả: Ứng dụng sập dây chuyền mà không báo lỗi compile.

**Cách Refactor:**
Sử dụng **Custom Exceptions**:
```dart
// Định nghĩa Exception rõ ràng
class NetworkException implements Exception {
  final String message;
  NetworkException([this.message = 'Mất kết nối mạng']);
}
class ServerException implements Exception { ... }
```
Trong Service:
```dart
throw NetworkException();
```
Trong Provider (Bắt lỗi an toàn):
```dart
} on NetworkException catch (e) {
  // Chắc chắn 100% là do mạng → Gọi lưu Offline
  await _addToSyncQueue(...);
} catch (e) {
  // Lỗi khác (Server, Parse...)
  _error = e.toString();
}
```
Cách này giúp trình biên dịch kiểm soát kiểu (Type-safe), an toàn tuyệt đối.

---

## Trường hợp 5: `{...}` = Cấu trúc file `dashboard_screen.dart`

**Thầy hỏi:** File `dashboard_screen.dart` chứa `DashboardScreen`, `_DashboardTab`, và `DonutChartPainter`. Chiều dài 800 dòng. Tại sao gom chung? Cần tổ chức lại ra sao?

**Trả lời:**
**Vấn đề:** Gộp chung mọi thứ làm file quá nặng. Khi làm việc nhóm (team nhiều người), hai người sửa Dashboard rất dễ bị Conflict Git.

**Cách Refactor:**
Nên cấu trúc theo dạng thư mục (Folder by Feature) cho riêng Dashboard:
```text
lib/features/dashboard/
  ├── screens/
  │   └── dashboard_screen.dart (Chỉ chứa khung + BottomNav)
  ├── tabs/
  │   └── home_tab.dart (Chính là _DashboardTab cũ)
  ├── widgets/
  │   ├── balance_card.dart
  │   ├── action_menu.dart
  │   ├── spending_analytics.dart
  │   └── recent_transactions.dart
  └── painters/
      └── donut_chart_painter.dart
```
**Ích lợi:**
- Đọc code dễ hiểu hơn (Tên file mô tả đúng chức năng).
- Git conflict được hạn chế.
- Dễ tái sử dụng widget `BalanceCard` nếu màn hình Analytics cũng cần nó.
