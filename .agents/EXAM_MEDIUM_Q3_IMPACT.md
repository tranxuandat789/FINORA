# MEDIUM Q3 – Tác động chéo (Impact Analysis)
> **Câu hỏi gốc:** Nếu muốn thêm một trường mới (ví dụ: `image_url` hoặc `isFavorite`) vào `{...}`, cần phải sửa những file nào, từ Model, UI cho đến Backend? Việc thêm trường này có phá vỡ tính năng cũ không?

---

## Trường hợp 1: `{...}` = Giao dịch (Transaction) – Thêm trường `image_url`

**Thầy hỏi:** Nếu tôi muốn thêm chức năng "Đính kèm ảnh hóa đơn" (lưu chuỗi `image_url`) vào một giao dịch, tôi phải cập nhật những layer nào, file nào?

**Trả lời:**
Đây là bài toán sửa DB schema và truyền data dọc theo toàn bộ hệ thống. Phải sửa từ Backend đến Frontend.

**1. Tầng Backend (.NET):**
- **Model / Entity (`Transaction.cs`):** Thêm property `public string? ImageUrl { get; set; }`.
- **Database (Entity Framework):** Chạy lệnh `Add-Migration AddImageUrl` và `Update-Database` để thêm cột vào bảng SQL.
- **DTOs (`CreateTransactionDto.cs`, `TransactionResponseDto.cs`):** Thêm trường `ImageUrl` để API có thể nhận và trả về dữ liệu này.

**2. Tầng Data / Model Flutter:**
- **Model (`transaction_model.dart`):**
  - Khai báo: `final String? imageUrl;`
  - Constructor: Cập nhật hàm khởi tạo.
  - Sửa hàm `fromJson()`: `imageUrl: json['imageUrl'] as String?,`
  - Sửa hàm `toJson()`: `'imageUrl': imageUrl,`

**3. Tầng State / Service Flutter:**
- **`TransactionProvider.dart`:** Cập nhật hàm `createTransaction()` và `updateTransaction()` để nhận thêm tham số `String? imageUrl`.
- Cập nhật chỗ lưu offline `_addToSyncQueue` để gom thêm trường này.

**4. Tầng UI Flutter:**
- **`AddTransactionScreen.dart`:** Thêm UI cho phép chọn ảnh (dùng thư viện `image_picker`), hiển thị ảnh xem trước. Truyền `imageUrl` vào nút "Lưu giao dịch".
- **`TransactionScreen.dart`:** Cập nhật list item để hiện icon ghim nếu giao dịch này có `imageUrl != null`.

**Có phá vỡ tính năng cũ không?**
- **KHÔNG**, nếu ta thiết kế trường `imageUrl` là kiểu *Nullable* (`String?`). Những giao dịch cũ không có ảnh sẽ tự động có `imageUrl = null` và parse JSON không bị lỗi.

---

## Trường hợp 2: `{...}` = Danh mục (Category) – Thêm trường `iconColor`

**Thầy hỏi:** Hiện tại Danh mục chỉ có icon (String). Nếu muốn user tự chọn màu cho icon đó (thêm trường `iconColor`), phải sửa các file nào?

**Trả lời:**
Tương tự giao dịch, tác động xuyên suốt.

**1. Tầng Backend (.NET):**
- Sửa entity `Category.cs`: thêm `public string? IconColor { get; set; }` (lưu dạng chuỗi HEX VD: `#FF0000`).
- Update DB, sửa DTOs.

**2. Tầng Model Flutter (`category_model.dart`):**
- Thêm `final String? iconColor;` (do Flutter đọc màu HEX phải viết helper chuyển đổi `Color` ↔ `String`).
- Update `fromJson`, `toJson`.

**3. Tầng UI Flutter:**
- **`AddCategoryScreen.dart`:** Thêm hàng chọn màu (danh sách các vòng tròn màu). Truyền mã màu xuống Provider khi nhấn "Lưu danh mục".
- **`CategoryBottomSheet.dart`:** Thay vì dùng màu xanh mặc định, đổi thành:
  ```dart
  Icon(icon, color: cat.iconColor != null ? HexColor(cat.iconColor!) : defaultColor)
  ```
- **`DashboardScreen.dart`:** Biểu đồ Donut phải đọc trường `iconColor` của danh mục (nếu thiết kế biểu đồ đồng màu với danh mục).

---

## Trường hợp 3: `{...}` = Người dùng (User / Auth) – Thêm `avatarUrl`

**Thầy hỏi:** Hiện tại app chỉ lưu tên `fullName` ở Local Storage để hiện trên Dashboard. Muốn thêm `avatarUrl` để lấy từ backend hoặc Google, cần sửa đâu?

**Trả lời:**
**1. Tầng Backend (.NET):**
- Sửa User model, khi login Google/App trả về object user kèm trường `AvatarUrl`.

**2. Tầng Auth Flutter (`auth_provider.dart`):**
- Khi gọi `_repository.login()`, API trả về `response['user']`.
- Thêm logic lưu trọn vẹn object này vào SharedPreferences:
  ```dart
  prefs.setString('user', jsonEncode(response['user']));
  ```
- Không cần sửa Model vì ở đây đang dùng `Map<String, dynamic>`.

**3. Tầng UI Flutter (`dashboard_screen.dart`):**
- Cập nhật hàm `_buildAppBar()`:
  ```dart
  final avatarUrl = authProvider.user?['avatarUrl'];
  CircleAvatar(
    backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
    child: avatarUrl == null ? Icon(Icons.person) : null,
  )
  ```

---

## Trường hợp 4: `{...}` = Cập nhật thư viện `Provider` / Flutter SDK

**Thầy hỏi:** Nếu tôi cập nhật bản Flutter SDK mới, hay đổi thư viện `Provider` sang `Riverpod`, tác động sẽ như thế nào?

**Trả lời:**
Tác động **CỰC KỲ LỚN (Massive Impact)**.

- **Đổi Provider sang Riverpod:** Phải viết lại TOÀN BỘ logic State Management. Xóa hết các file trong folder `providers/`, sửa toàn bộ hàm `initState`, xóa toàn bộ `Consumer`, `context.read`, `context.watch` ở TẤT CẢ các file giao diện.
- **Cập nhật Flutter SDK:** Nếu Flutter deprecate một số widget (ví dụ đợt đổi `RaisedButton` sang `ElevatedButton`), phải sửa toàn app. Gói `google_fonts` hoặc `dio` có thể yêu cầu tăng version Dart.

Đây là lý do các project lớn thường tạo ra **Tầng Wrapper/Abstraction** cho các thư viện core để giảm tác động chéo. Ở FINORA, UI đang dính chặt (tight-coupled) với `Provider`.

---

## Trường hợp 5: `{...}` = Xóa trường `note` khỏi Giao dịch (Backend tự đổi)

**Thầy hỏi:** Nếu Backend thấy trường `note` (Ghi chú) không cần thiết và xóa đi trong JSON response, Mobile có bị văng (crash) không?

**Trả lời:**
**KHÔNG bị crash** nếu viết `fromJson` chuẩn (dùng Nullable `String?`).

Trong `transaction_model.dart`:
```dart
note: json['note'] as String?,
```
Nếu backend xóa trường này, `json['note']` sẽ trả về `null`. Nhờ toán tử ép kiểu an toàn `as String?`, Dart gán `null` cho `note` một cách êm đẹp.
Bên UI, `Text(transaction.note ?? '')` tự động hiển thị chuỗi rỗng.

**NHƯNG NẾU** code viết:
```dart
note: json['note'] as String, // Không có dấu hỏi
```
App sẽ lập tức **BỊ CRASH ĐỎ MÀN HÌNH** (TypeError: Null is not a subtype of type String). Đó là lý do mọi trường không bắt buộc từ API đều phải parse kiểu `Nullable`.
