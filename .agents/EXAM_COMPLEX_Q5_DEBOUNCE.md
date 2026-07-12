# COMPLEX Q5 – Live-code Debounce
> **Câu hỏi gốc:** Hiện tại ở màn hình Tìm kiếm / Phân tích giọng nói, mỗi lần người dùng gõ phím / đọc một chữ là ứng dụng lại gọi API một lần (gây spam Server). Hãy viết nhanh một cơ chế `Debounce` để giải quyết vấn đề này.

---

## Giải pháp & Phân tích Live-code

`Debounce` là kỹ thuật trì hoãn việc gọi hàm cho đến khi người dùng ngừng thao tác trong một khoảng thời gian nhất định (ví dụ 500ms). Dưới đây là cách triển khai.

### 1. Triển khai Class Debouncer (Tiện ích dùng chung)

Nên tạo một file tiện ích riêng `lib/core/utils/debouncer.dart` để mọi nơi trong app đều có thể dùng.

```dart
import 'dart:async';
import 'package:flutter/foundation.dart';

class Debouncer {
  final int milliseconds;
  Timer? _timer;

  Debouncer({required this.milliseconds});

  void run(VoidCallback action) {
    // Nếu có một timer đang chạy (user đang gõ liên tục), hủy nó đi
    if (_timer != null) {
      _timer!.cancel();
    }
    
    // Đặt lại một timer mới. Chỉ khi user DỪNG gõ đủ thời gian (milliseconds), action mới được gọi.
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }
  
  void dispose() {
    _timer?.cancel();
  }
}
```

### 2. Áp dụng vào TextField (Ví dụ: Thanh tìm kiếm giao dịch)

Giả sử bạn có màn hình tìm kiếm giao dịch theo ghi chú (chưa có trong source gốc, nhưng rất hay bị hỏi thêm).

```dart
class TransactionSearchScreen extends StatefulWidget {
  @override
  _TransactionSearchScreenState createState() => _TransactionSearchScreenState();
}

class _TransactionSearchScreenState extends State<TransactionSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  
  // Khởi tạo Debouncer, đợi 500ms sau khi user ngừng gõ mới gọi API
  final Debouncer _debouncer = Debouncer(milliseconds: 500);

  @override
  void dispose() {
    _searchController.dispose();
    _debouncer.dispose(); // Bắt buộc để tránh memory leak
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debouncer.run(() {
      // Hàm này chỉ chạy khi user đã ngừng gõ 500 mili-giây
      if (query.isNotEmpty) {
        context.read<TransactionProvider>().searchTransactions(query);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          onChanged: _onSearchChanged, // Gắn sự kiện OnChange
          decoration: InputDecoration(
            hintText: 'Tìm kiếm ghi chú, số tiền...',
          ),
        ),
      ),
      body: // ... list kết quả
    );
  }
}
```

### 3. Các câu hỏi vặn (Gotchas) từ Giám khảo

**Hỏi: Biến `_timer` tại sao lại có dấu chấm hỏi `Timer?`**
- **Trả lời:** Chấm hỏi nghĩa là Nullable. Khi mới khởi tạo, chưa có hành động gõ phím nào thì timer chưa tồn tại (giá trị là `null`). Việc dùng `?` là bắt buộc trong Dart Null Safety. Trước khi hủy timer ta dùng dấu `!` (bang operator) `_timer!.cancel()` vì ta đã kiểm tra `if (_timer != null)` trước đó.

**Hỏi: Sự khác biệt giữa `Debounce` và `Throttle` là gì?**
- **Trả lời:** 
  - **Debounce:** "Đợi mày làm xong hết trò rồi tao mới làm 1 lần". Ví dụ: Gõ tìm kiếm. Chỉ khi user **ngừng gõ** 500ms API mới bắn.
  - **Throttle:** "Tao chỉ làm 1 lần mỗi chu kỳ thời gian, mặc kệ mày kêu bao nhiêu lần". Ví dụ: Nút Bắn súng trong game, giới hạn tốc độ 1 viên/giây. Dù user spam bấm 100 lần/giây, app chỉ chạy hàm bắn 1 lần mỗi giây.

**Hỏi: Nếu user gõ rất nhanh "abc" xong bấm nút "Back" thoát màn hình ngay lập tức. Chuyện gì xảy ra?**
- **Trả lời:** 500ms sau, bộ hẹn giờ Timer mới kích hoạt khối code gọi API. Lúc này do user đã bấm thoát, màn hình (State) đã bị hủy (unmounted). Nếu ta gọi API rồi cố cập nhật giao diện (như gọi Snackbar), app sẽ văng Crash "setState() after dispose()".
**Cách khắc phục triệt để:** Bắt buộc phải gọi hàm `_debouncer.dispose();` (chứa `_timer?.cancel()`) trong hàm `dispose()` của màn hình. Kéo theo Timer bị hủy ngay khi thoát màn hình, code API sẽ không bao giờ bị kích hoạt trễ nữa.
