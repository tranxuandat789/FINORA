# MEDIUM Q5 – Null Safety & Parse JSON
> **Câu hỏi gốc:** Đoạn code parse JSON trong model `{...}` xử lý Null Safety như thế nào? Nếu trường `{...}` không có trong cục JSON trả về hoặc bị null, ứng dụng có lỗi không?

---

## Trường hợp 1: `{...}` = `TransactionModel` – Trường `note` (Ghi chú)

**Thầy hỏi:** Trong `TransactionModel.fromJson`, nếu JSON từ Server trả về không chứa trường `note` hoặc `note: null`, app xử lý thế nào? Có crash không?

**Trả lời:**
**KHÔNG Crash.** Code xử lý trường hợp này bằng cách khai báo biến `note` là Nullable (`String?`):

```dart
// transaction_model.dart
class TransactionModel {
  final String id;
  // ...
  final String? note; // ← Nullable type (có dấu hỏi)

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] as String,
      // ...
      note: json['note'] as String?, // ← Ép kiểu an toàn (as String?)
    );
  }
}
```
Khi JSON không có `note` → `json['note']` trả về `null`. Nhờ ép kiểu `as String?`, Dart chấp nhận giá trị `null` và gán cho biến `note`.

Bên phía UI:
```dart
// transaction_screen.dart
Text(transaction.note ?? '') // ← Toán tử fallback (??)
```
UI kiểm tra nếu `note` là `null` thì hiển thị chuỗi rỗng `''`.

---

## Trường hợp 2: `{...}` = `TransactionModel` – Trường `amount` (Số tiền)

**Thầy hỏi:** Nếu JSON Server bị thiếu trường `amount`, app có bị lỗi không? Tại sao?

**Trả lời:**
**CÓ CRASH (Quăng Exception đỏ màn hình).**

```dart
// transaction_model.dart
final double amount; // ← Non-nullable

factory TransactionModel.fromJson(Map<String, dynamic> json) {
  return TransactionModel(
    amount: (json['amount'] as num).toDouble(), // ← Lỗi xảy ra ở đây
  );
}
```
Lý do:
- JSON thiếu `amount` → `json['amount']` trả về `null`.
- Đoạn code `(null as num)` vi phạm Null Safety. Dart quăng lỗi `TypeError: Null is not a subtype of type 'num'`.

**Cách phòng tránh lỗi (Defensive Programming):**
Đưa giá trị mặc định vào hàm `fromJson`:
```dart
amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
```
Như vậy nếu thiếu, giá trị sẽ là `0.0` và app không sập.

---

## Trường hợp 3: `{...}` = `CategoryModel` – Kiểu `isDefault`

**Thầy hỏi:** Trong Model danh mục, biến `isDefault` xử lý từ JSON ra sao? Nếu Backend trả về số `1` hoặc `0` thay vì `true`/`false`, code hiện tại chạy được không?

**Trả lời:**
```dart
// category_model.dart
final bool isDefault;

factory CategoryModel.fromJson(Map<String, dynamic> json) {
  return CategoryModel(
    isDefault: json['isDefault'] as bool? ?? false,
  );
}
```
**Phân tích:**
- Nếu Server trả JSON không có trường `isDefault` → `null` → giá trị lấy mặc định là `false`. Chạy tốt!
- Nếu Server trả JSON: `isDefault: false` hoặc `true` → Chạy tốt!
- **Nếu Server trả `isDefault: 1` hoặc `0`** → **CRASH**.
  Bởi vì `json['isDefault']` mang giá trị `int`, khi chạy `as bool?` Dart sẽ báo lỗi Type mismatch (`int is not a subtype of bool`).

**Cách sửa để tương thích kiểu int/bool:**
```dart
isDefault: (json['isDefault'] == true || json['isDefault'] == 1),
```

---

## Trường hợp 4: `{...}` = `DashboardDataModel` – Phân tích kiểu DateTime

**Thầy hỏi:** Ngày tháng (`transactionDate`) từ Server trả về định dạng chuỗi `"2025-05-12T14:30:00Z"`. Dart parse chuỗi này sang `DateTime` thế nào? Nếu chuỗi null hoặc sai format thì sao?

**Trả lời:**
Code xử lý:
```dart
// transaction_model.dart
transactionDate: DateTime.parse(json['transactionDate'] as String),
```

- Trả về đúng format ISO-8601: Hàm `DateTime.parse()` đọc mượt mà.
- **Chuỗi Null:** `json['transactionDate'] as String` ném lỗi vì không dùng `String?`.
- **Sai format** (Ví dụ: `"12/05/2025"`): `DateTime.parse()` ném `FormatException`. 

**Nên xử lý an toàn hơn:**
```dart
DateTime? date;
try {
  date = DateTime.parse(json['transactionDate'].toString());
} catch (_) {
  date = DateTime.now(); // Fallback an toàn
}
transactionDate: date,
```

---

## Trường hợp 5: `{...}` = AuthProvider – User Profile

**Thầy hỏi:** Trong `AuthProvider`, khi decode thông tin User lưu ở `SharedPreferences`, nếu JSON lưu bị sai format, đăng nhập có bị lỗi văng không?

**Trả lời:**
```dart
// auth_provider.dart
Future<void> checkAuthStatus() async {
  final prefs = await SharedPreferences.getInstance();
  final userStr = prefs.getString('user');
  if (userStr != null && token != null) {
    _user = Map<String, dynamic>.from(jsonDecode(userStr));
  }
}
```
Trong quá trình khởi động app, `checkAuthStatus()` được gọi. 
- Nếu `userStr` mang chuỗi JSON hỏng (do bản cập nhật cũ bị lỗi ghi), hàm `jsonDecode(userStr)` sẽ quăng `FormatException`.
- Do không có khối `try-catch`, Exception này làm Provider lỗi, User có thể kẹt mãi ở màn hình Loading (Splash Screen) hoặc quăng lỗi màn hình đỏ.

**Khắc phục:** Bao bọc bằng `try-catch`:
```dart
try {
  _user = Map<String, dynamic>.from(jsonDecode(userStr));
} catch (e) {
  _user = null;
  token = null;
  // Bắt user login lại
}
```

---

## Trường hợp 6: `{...}` = Dữ liệu Trống từ Dashboard Analytics

**Thầy hỏi:** Trong `DashboardDataModel`, mảng phân tích chi tiêu `expenses` được ép kiểu từ JSON List. Nếu user không có chi tiêu nào, API trả mảng rỗng `[]` hoặc `null`, app có vỡ biểu đồ không?

**Trả lời:**
```dart
// dashboard_model.dart
expenses: (json['expenses'] as List<dynamic>?)
        ?.map((e) => CategoryExpense.fromJson(e as Map<String, dynamic>))
        .toList() ?? [],
```
Đoạn code trên xử lý Null Safety **Cực Kỳ Tốt**:
1. Lấy mảng từ JSON ép dạng tuỳ chọn: `as List<dynamic>?`.
2. Dùng toán tử `?.map`: Nếu mảng `null`, không gọi map, nhảy thẳng về null.
3. Dùng toán tử fallback `?? []`: Nếu kết quả trước đó là `null`, trả về mảng rỗng `[]`.

Bên phía `DashboardScreen.dart`, nếu `expenses.isEmpty`, code không vẽ `DonutChartPainter` mà hiện dòng "Chưa có chi tiêu nào" → UI **hoàn toàn an toàn**.
