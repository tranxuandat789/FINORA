# MEDIUM Q7 – Truyền tham số (Data Passing)
> **Câu hỏi gốc:** Phân tích cách truyền dữ liệu vào `{...}`. Tại sao tham số này phải được cấu hình là `required` hoặc `nullable`? Có cách nào truyền dữ liệu không qua tham số hàm (constructor) không?

---

## Trường hợp 1: `{...}` = **AddTransactionScreen** (voiceData)

**Thầy hỏi:** Trong `AddTransactionScreen`, tham số `voiceData` có kiểu dữ liệu gì? Tại sao nó lại cho phép `null` (nullable)?

**Trả lời:**
```dart
class AddTransactionScreen extends StatefulWidget {
  final Map<String, dynamic>? voiceData;

  const AddTransactionScreen({Key? key, this.voiceData}) : super(key: key);
  // ...
}
```

**Phân tích kiểu và lý do Nullable:**
- Tham số này có kiểu `Map<String, dynamic>?` (từ điển dạng Key-Value) và **có dấu chấm hỏi `?` (Nullable)**.
- Khi người dùng bấm nút "+" bình thường trên màn hình Dashboard, ứng dụng gọi:
  ```dart
  Navigator.push(context, MaterialPageRoute(builder: (_) => const AddTransactionScreen()));
  ```
  Không truyền `voiceData` → `voiceData` mang giá trị `null`.
- KHI VÀ CHỈ KHI người dùng tương tác với "Chú ong ghi âm", và có kết quả AI, màn hình mới được gọi kèm tham số:
  ```dart
  AddTransactionScreen(voiceData: {'amount': 50000, 'note': 'Trà sữa', ...})
  ```
Nếu cài đặt `required`, nút "+" bình thường sẽ báo lỗi do không truyền cục data giọng nói vào.

---

## Trường hợp 2: `{...}` = **CategoryBottomSheet** (selectedType)

**Thầy hỏi:** Trong `CategoryBottomSheet`, biến `selectedType` dùng để làm gì? Tại sao bắt buộc (required)?

**Trả lời:**
```dart
class CategoryBottomSheet extends StatelessWidget {
  final int selectedType; // 1: Thu nhập, 2: Chi tiêu

  const CategoryBottomSheet({Key? key, required this.selectedType}) : super(key: key);
}
```

**Tại sao Required:**
- `selectedType` quyết định việc lấy danh sách danh mục (VD đang thêm giao dịch chi tiêu thì phải lấy các icon "Đi chợ", "Đổ xăng", không thể hiện icon "Lương").
- Thuộc tính `required` ép buộc bất kỳ ai gọi `CategoryBottomSheet` **phải trả lời câu hỏi**: "Anh muốn mở bảng danh mục cho loại giao dịch nào?".
- Nếu quên truyền (hoặc null), lưới danh mục không biết lọc theo logic gì → lỗi logic nghiệp vụ.

---

## Trường hợp 3: `{...}` = **AddCategoryScreen** (type)

**Thầy hỏi:** Màn hình `AddCategoryScreen` nhận tham số `type`. Tại sao trường `type` lại thiết lập cứng màu nền của nút thay vì để người dùng chọn trong form?

**Trả lời:**
```dart
class AddCategoryScreen extends StatefulWidget {
  final int type;
  const AddCategoryScreen({Key? key, required this.type}) : super(key: key);
}
```

Trường `type` truyền từ AddTransaction (Thu/Chi) → BottomSheet → sang tận AddCategory.
- Nếu bạn đang muốn thêm giao dịch CHỈ TIÊU mà bấm "Thêm danh mục", danh mục tạo ra **bắt buộc** phải là danh mục chi tiêu.
- Do đó, UI nhận trực tiếp tham số `type` để hiển thị nhãn màu xanh/đỏ (chỉ đọc) mà không cho phép user đổi loại. User muốn tạo danh mục Thu nhập thì phải quay ra ngoài đổi loại giao dịch trước.
- Cách thiết kế này khóa rủi ro (Data Integrity), giảm thao tác lỗi từ user.

---

## Trường hợp 4: Truyền dữ liệu xuyên không (Không qua Constructor)

**Thầy hỏi:** Có cách nào truyền cục `userProfile` (Avatar, Tên) từ file đăng nhập `LoginScreen` sang `DashboardScreen` mà không truyền qua constructor `DashboardScreen({this.user})` không?

**Trả lời:**
**CÓ.** App hiện tại ĐANG làm theo cách này. Việc truyền qua constructor giữa các màn hình xa nhau sinh ra lỗi "Prop Drilling" (nhồi tham số qua nhiều tầng vô nghĩa).

Cách truyền không qua tham số: **Dùng State Management (Provider)**.

1. **Ở LoginScreen:** Gọi API thành công → ném cục Data vào Provider.
   ```dart
   context.read<AuthProvider>().setUser(userData);
   ```
2. **Ở DashboardScreen:** Khởi tạo mà không cần biến gì. Khi cần lấy tên, đọc thẳng từ kho lưu trữ chung.
   ```dart
   final fullName = context.read<AuthProvider>().user?['fullName'];
   ```

**Ưu điểm:**
- Các màn hình không phụ thuộc tham số của nhau (Decoupled).
- Data luôn được đồng bộ (nếu user update avatar ở ProfileScreen, Dashboard tự động nhảy theo mà không cần bắn tham số lùi lại).
- Đây là cốt lõi của Kiến trúc Provider/Riverpod.
