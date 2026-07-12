# COMPLEX Q7 – Memory Leak
> **Câu hỏi gốc:** Ứng dụng chạy rất nhanh lúc mới mở, nhưng nếu người dùng dùng liên tục 30 phút, mở qua lại màn hình Thêm Giao Dịch hàng chục lần thì app bị giật lag và hao pin nhanh. Phân tích nguyên nhân (Memory Leak) và cách khắc phục trong mã nguồn hiện tại.

---

## 1. Dấu hiệu và Nguyên nhân (Leak)

**Thầy hỏi:** Màn hình `AddTransactionScreen` chứa 2 `TextEditingController`. Code hiện tại trong hàm `dispose` chỉ gọi `_amountController.dispose();`. Điều gì sẽ xảy ra sau khi đóng mở màn hình này 50 lần?

**Trả lời:**
Đây là hiện tượng **Rò rỉ bộ nhớ (Memory Leak)** kinh điển trong Flutter.

Khi mở màn hình `AddTransactionScreen`, hàm `initState` hoặc phần khởi tạo class đã sinh ra một loạt các Controller:
```dart
final TextEditingController _amountController = TextEditingController();
final TextEditingController _noteController = TextEditingController();
```

Khi bấm nút Back (thoát màn hình), Flutter sẽ tháo màn hình khỏi widget tree và chạy hàm `dispose()`.
```dart
@override
void dispose() {
  _amountController.dispose();
  // THIẾU _noteController.dispose();
  super.dispose();
}
```

**Chuyện gì xảy ra?**
- Mỗi `TextEditingController` mang theo các Listener, FocusNode riêng và kết nối tới C/C++ engine của thiết bị để bắt sự kiện bàn phím.
- Việc quên không dispose `_noteController` khiến Garbage Collector (Bộ thu gom rác của Dart) **không thể xóa** controller này khỏi RAM (do vẫn còn ngầm liên kết với listener).
- User mở màn hình 50 lần → Tồn tại 50 cái `_noteController` rác (zombie) chạy ngầm.
- Lâu dần, RAM bị nhồi nhét đầy. Máy điện thoại phải cật lực phân bổ RAM, gây hiện tượng khựng khung hình (Jank), tụt FPS, nóng máy, hao pin, cuối cùng hệ điều hành sẽ thẳng tay đóng (kill) ứng dụng vì lỗi "Out of Memory" (OOM).

**Cách khắc phục:**
Trong bất kỳ màn hình `StatefulWidget` nào, hễ có khai báo các đối tượng dòng chảy (Controller, Timer, StreamSubscription, AnimationController), bắt buộc phải có câu lệnh `.cancel()` hoặc `.dispose()` tương ứng ở hàm `dispose()`.

---

## 2. Rò rỉ qua Animation/Timer ở `FloatingVoiceButton`

**Thầy hỏi:** Trong nút con ong `FloatingVoiceButton.dart` có một đống Ticker, Timer, AnimationController. Đoạn code `dispose()` của nó đã ổn chưa? Có chỗ nào hở sườn không?

**Trả lời:**
Đoạn code trong `dispose()` của con ong:
```dart
@override
void dispose() {
  _bobbingController.dispose();
  _flightController.dispose();
  _lottieController.dispose();
  _lottieTicker.dispose();
  _inactivityTimer?.cancel();
  _idleRestTimer?.cancel();
  super.dispose();
}
```
Về lý thuyết, danh sách dispose khá đầy đủ. TẤT CẢ các timer và animation đã được dọn sạch.

Nhưng có một **Code Smell (Bẫy Rò Rỉ Mềm)** nằm ở biến `mounted`:
```dart
_inactivityTimer = Timer(const Duration(seconds: 5), () {
  if (mounted && !_isDragging && !_isRecording) {
     _triggerIdleFlight();
  }
});
```
Việc kiểm tra `mounted` bên trong Timer callback đã cứu cánh cho việc ném Exception. Tuy nhiên, nếu user bấm thoát màn hình giữa chừng lúc đếm giây thứ 2, thì đến giây thứ 5 callback này **VẪN ĐƯỢC CHẠY** dưới nền (mặc dù nó chặn lại ở chữ `mounted` và không báo lỗi màn hình).
Đây gọi là rò rỉ xung nhịp vi xử lý (CPU wakeups).
Giải pháp đúng nhất luôn là gọi `cancel()` trên mọi Timer đang chạy khi hàm `dispose` kích hoạt, chính xác như code đang làm.

---

## 3. Lỗi quên Remove Listener

**Thầy hỏi:** Trong `AddTransactionScreen`, ở hàm `initState`, code gắn một hàm vô danh (anonymous callback) vào listener của số tiền:
`_amountController.addListener(() { print('Đang gõ...'); });`
Nếu không remove nó ở `dispose`, hậu quả là gì? Làm sao để remove?

**Trả lời:**
Nếu bạn truyền một hàm vô danh `() { ... }` vào `addListener`, **bạn vĩnh viễn không thể remove được nó**!

```dart
// Lỗi phổ biến:
_amountController.addListener(() {
  setState(() { ... });
});

@override
void dispose() {
  // Lấy gì để truyền vào hàm removeListener() bây giờ??
  // _amountController.removeListener( ??? );
  _amountController.dispose();
  super.dispose();
}
```

Nếu chạy như trên, khi dispose `_amountController`, có khả năng listener kia (chứa lệnh `setState`) vẫn bị giam trong bộ nhớ và lỡ nó vô tình được đánh thức, nó sẽ quăng lỗi vỡ mật "setState() called after dispose".

**Cách Refactor (Bắt buộc dùng hàm có tên):**
```dart
// 1. Tạo hàm có tên
void _onAmountChanged() {
  setState(() { ... });
}

@override
void initState() {
  // 2. Gắn tên
  _amountController.addListener(_onAmountChanged);
}

@override
void dispose() {
  // 3. Gỡ tên TRƯỚC KHI hủy controller
  _amountController.removeListener(_onAmountChanged);
  _amountController.dispose();
}
```
Luôn nhớ nguyên tắc: **Cái gì sinh ra cuối cùng thì phải bị tiêu diệt đầu tiên**. Remove Listener → Dispose Controller → Super Dispose.
