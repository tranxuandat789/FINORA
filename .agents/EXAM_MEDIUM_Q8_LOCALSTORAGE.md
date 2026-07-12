# MEDIUM Q8 – Lưu trữ cục bộ (Local Storage)
> **Câu hỏi gốc:** Dữ liệu tạm thời (cache) ở `{...}` được lưu ở đâu trên điện thoại? Sự khác biệt giữa việc dùng SharedPreferences và SQLite/File là gì? Khi gỡ app thì dữ liệu này có mất không?

---

## Trường hợp 1: `{...}` = Lịch sử Giao dịch (FileStorageService)

**Thầy hỏi:** Trong ứng dụng này, dữ liệu danh sách giao dịch cache được lưu bằng thư viện nào? (SharedPreferences hay SQLite hay ghi File?). So sánh nó với SQLite. Khi gỡ app có mất không?

**Trả lời:**
**Cơ chế lưu trữ:**
Dữ liệu danh sách giao dịch (Transactions Cache) đang được lưu thông qua `FileStorageService` (tự viết). Đọc code trong `file_storage_service.dart`, lớp này **thực chất sử dụng `SharedPreferences`** nhưng bọc (wrap) dưới dạng chuỗi JSON thay vì lưu file thực sự trong thư mục App (`path_provider`).

```dart
// file_storage_service.dart
Future<void> writeData(String fileName, dynamic data) async {
  final prefs = await SharedPreferences.getInstance();
  final String jsonData = jsonEncode(data);
  await prefs.setString('cache_$fileName', jsonData); // Lưu dưới dạng String dài
}
```

**Sự khác biệt với SQLite:**
- **SharedPreferences (hoặc JSON String lưu local):** Dễ cấu hình, chỉ việc chuyển List/Map thành String. **Nhược điểm:** Tốc độ chậm nếu danh sách quá dài (ví dụ file JSON nặng 5MB thì lúc deserialize sẽ gây đơ UI). Không thể query "Lấy giao dịch ngày 12", phải đọc toàn bộ cục JSON ra RAM rồi mới map.
- **SQLite (sqflite):** Cấu trúc bảng SQL chặt chẽ. Hỗ trợ Query, Index. Tốc độ rất nhanh cho mảng dữ liệu cực lớn. Nhược điểm: Setup phức tạp, phải viết nhiều mã SQL thô (hoặc dùng ORM như Drift/Isar).

**Khi gỡ ứng dụng:**
**Có mất toàn bộ.** Khi gỡ app (Uninstall), OS (Android/iOS) sẽ xóa thư mục sandbox của app. Cả SQLite hay SharedPreferences đều bị xóa sạch (trừ khi dùng dịch vụ sao lưu đám mây iCloud/Google Drive của OS). Tuy nhiên dữ liệu thật nằm ở Backend, login lại sẽ có lại.

---

## Trường hợp 2: `{...}` = Hàng đợi đồng bộ Offline (Sync Queue)

**Thầy hỏi:** Hàng đợi Sync Queue (lưu các giao dịch lúc mất mạng) được lưu ở đâu? Nếu lưu bằng SharedPreferences mà chuỗi này lớn dần, rủi ro là gì?

**Trả lời:**
Sync Queue cũng được lưu qua `FileStorageService` (`SharedPreferences` với key `cache_sync_queue.json`).

```dart
// Ví dụ format lưu
[
  {"action": "create_transaction", "data": {...}},
  {"action": "delete_transaction", "data": {"id": "123"}}
]
```

**Rủi ro khi lưu hàng đợi vào SharedPreferences:**
1. **Giới hạn kích thước:** Một số OS giới hạn dung lượng lưu trữ của một Key trong `SharedPreferences` (thường vài MB). Nếu user offline đi du lịch dài ngày, thêm hàng nghìn chi tiêu (hoặc đính kèm ảnh base64 lớn), việc lưu chuỗi JSON lớn có thể sụp đổ (Out Of Memory) hoặc bị cắt đứt.
2. **Crash hỏng dữ liệu (Corruption):** Trong lúc đang lưu chuỗi JSON vào bộ nhớ flash, nếu user force close app, toàn bộ chuỗi JSON dài có thể bị ghi hỏng (Invalid JSON). Mở app lên decode bị `FormatException`, làm mất toàn bộ dữ liệu giao dịch offline của user.

**Giải pháp:**
Với hàng đợi đồng bộ quan trọng như giao dịch tài chính, ứng dụng chuyên nghiệp sẽ dùng **SQLite** (lưu từng row) hoặc **Hive / Isar** (NoSQL Database). Mỗi giao dịch là một Record độc lập, không sợ lỗi JSON nguyên cục.

---

## Trường hợp 3: `{...}` = Token xác thực (Auth Token)

**Thầy hỏi:** Token dùng để xác thực (`accessToken`) được lưu ở đâu? Việc lưu này có an toàn không?

**Trả lời:**
```dart
// auth_provider.dart
final prefs = await SharedPreferences.getInstance();
await prefs.setString('token', response['token']);
```

Token được lưu thẳng vào `SharedPreferences` (dạng Text thô).

**Việc này KHÔNG an toàn tuyệt đối.**
- SharedPreferences lưu dữ liệu vào một file XML trần (Ví dụ: `/data/data/com.example.app/shared_prefs/FlutterSharedPreferences.xml`).
- Trên máy bình thường: An toàn do Sandbox của OS bảo vệ (các app khác không đọc được).
- **Trên máy đã Root / Jailbreak:** Hacker hoặc các app mã độc có thể đọc file XML này và đánh cắp JWT Token, chiếm đoạt phiên đăng nhập.

**Giải pháp bảo mật (Security Upgrade):**
Nên đổi từ `shared_preferences` sang thư viện `flutter_secure_storage`. Thư viện này lưu chuỗi bằng cách mã hóa (dùng KeyStore trên Android, Keychain trên iOS).

---

## Trường hợp 4: `{...}` = Theme Setting (Dark Mode)

**Thầy hỏi:** Biến thiết lập Dark Mode `isDarkMode` lưu như thế nào? Tại sao lại cần lưu vào đĩa cứng thay vì chỉ giữ trên RAM?

**Trả lời:**
```dart
// theme_provider.dart
await prefs.setBool('is_dark_mode', isOn);
```

**Lý do lưu vào đĩa cứng (SharedPreferences):**
Mọi biến giữ trên RAM (khai báo `bool isDark = true;`) sẽ **bị xóa rỗng (reset)** khi ứng dụng bị tắt hoàn toàn khỏi trình đa nhiệm.

Nếu không lưu vào đĩa cứng: 
- User chọn bật Dark Mode vào ban đêm.
- Tắt app đi ngủ. Sáng mai mở app lại, biến RAM khởi tạo lại từ đầu (mặc định Light Mode), làm chói mắt user.

**Cách hoạt động tối ưu:**
Lưu dưới dạng kiểu Boolean nguyên thủy rất nhẹ. Trong hàm khởi tạo (`ThemeProvider()`), ta đọc file đĩa `prefs.getBool` trước rồi mới vẽ UI.
