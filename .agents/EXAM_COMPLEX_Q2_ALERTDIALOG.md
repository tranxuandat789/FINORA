# COMPLEX Q2 – Live-code AlertDialog
> **Câu hỏi gốc:** Viết nhanh một hàm `showDeleteConfirmDialog(BuildContext context, String id)` để hiển thị 1 cái `AlertDialog` hỏi "Bạn có chắc muốn xoá?". Nếu bấm Có thì gọi api xoá và hiện Snackbar, bấm Không thì tắt popup.

---

## Giải pháp & Phân tích Live-code

Đây là kỹ năng viết UI và gọi logic bất đồng bộ cơ bản. Dưới đây là cách triển khai hoàn chỉnh (đáp ứng đúng luồng xử lý của `TransactionProvider` hiện tại).

### 1. Code Triển khai

Bạn có thể chèn đoạn code này vào file `transaction_screen.dart` hoặc tạo một `utils/dialog_utils.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile/core/utils/snackbar_utils.dart';
import 'package:mobile/features/transaction/providers/transaction_provider.dart';

void showDeleteConfirmDialog(BuildContext context, String transactionId) {
  showDialog(
    context: context,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: const Text('Bạn có chắc chắn muốn xóa giao dịch này không? Hành động này không thể hoàn tác.'),
        actions: [
          // Nút Không
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop(); // Tắt popup
            },
            child: const Text('Không', style: TextStyle(color: Colors.grey)),
          ),
          // Nút Có
          TextButton(
            onPressed: () async {
              // 1. Tắt popup ngay lập tức để UI mượt
              Navigator.of(dialogContext).pop();
              
              // 2. Gọi hàm xóa (async)
              // Lưu ý dùng context của màn hình chính, KHÔNG dùng dialogContext
              final success = await context.read<TransactionProvider>().deleteTransaction(transactionId);
              
              // 3. Hiện SnackBar kết quả
              if (context.mounted) {
                if (success) {
                  SnackBarUtils.showTopSnackBar(context, 'Đã xóa giao dịch thành công!', isSuccess: true);
                  // (Tùy chọn) Gọi DashboardProvider update nếu số dư thay đổi
                } else {
                  SnackBarUtils.showTopSnackBar(context, 'Có lỗi xảy ra hoặc đã lưu xóa offline.', isSuccess: false);
                }
              }
            },
            child: const Text('Có, xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      );
    },
  );
}
```

### 2. Các cạm bẫy (Gotchas) khi thầy "bắt lỗi"

Thầy giáo có thể hỏi vặn lại các lỗi phổ biến sau khi bạn viết xong code:

**Hỏi: Tại sao nút "Có" lại `pop()` trước khi gọi API? Nếu API lỗi thì sao?**
- **Trả lời:** Nếu để hàm `await` chạy trước `pop()`, màn hình sẽ bị "treo" (đứng cứng) một cái hộp thoại mà user không tương tác được trong vài giây. Tắt hộp thoại đi ngay mang lại UX tốt hơn (có thể hiện Loading xoay vòng ở list). Nếu API lỗi, ta hiện SnackBar thông báo. Tuy nhiên, cách tốt nhất là trong thời gian `await`, đổi nút "Có" thành `CircularProgressIndicator` (cần dùng `StatefulBuilder` bên trong dialog).

**Hỏi: Nếu dùng `dialogContext` thay cho `context` trong hàm `context.read<TransactionProvider>()` có được không?**
- **Trả lời:** Rất dễ LỖI. Nếu bạn đã `Navigator.pop(dialogContext)` xong, cái context đó trở thành "Dead context" (đã bị gỡ khỏi widget tree). Việc gọi `dialogContext.read()` sau đó sẽ throw Exception. Luôn phải dùng `context` gốc của màn hình (truyền vào từ tham số hàm).

**Hỏi: Tại sao lại cần `if (context.mounted)` trước khi gọi SnackBar?**
- **Trả lời:** Lời gọi API xóa `await deleteTransaction` có thể mất 3 giây. Trong 3 giây đó, người dùng lỡ tay bấm nút Back (thoát khỏi màn hình danh sách giao dịch). Màn hình chính đã bị hủy (unmounted). Lúc đó gọi hiển thị SnackBar trên một màn hình đã chết sẽ làm ứng dụng bị Crash. Lệnh kiểm tra `mounted` là bắt buộc.

---

### 3. (Mở rộng) Nâng cấp Dialog bằng StatefulBuilder (Hiển thị Loading bên trong Dialog)

Nếu thầy yêu cầu "Khi bấm Có, nút Có biến thành vòng tròn xoay, không tắt Dialog cho đến khi xóa xong", bạn phải sửa code như sau:

```dart
void showDeleteConfirmDialog(BuildContext context, String transactionId) {
  showDialog(
    context: context,
    barrierDismissible: false, // Không cho bấm ra ngoài để tắt
    builder: (BuildContext dialogContext) {
      bool isDeleting = false; // Local state của Dialog

      return StatefulBuilder( // Dùng cái này để setState cho riêng Dialog
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Xác nhận xóa'),
            content: const Text('Bạn có chắc chắn muốn xóa giao dịch này?'),
            actions: [
              TextButton(
                onPressed: isDeleting ? null : () => Navigator.pop(dialogContext),
                child: const Text('Không'),
              ),
              ElevatedButton(
                onPressed: isDeleting ? null : () async {
                  setState(() => isDeleting = true); // Hiện loading

                  final success = await context.read<TransactionProvider>().deleteTransaction(transactionId);
                  
                  if (dialogContext.mounted) {
                    Navigator.pop(dialogContext); // Tắt popup khi gọi xong
                  }
                  
                  if (context.mounted) {
                    SnackBarUtils.showTopSnackBar(
                      context, 
                      success ? 'Đã xóa' : 'Lỗi xóa', 
                      isSuccess: success
                    );
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: isDeleting 
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('Có, xóa', style: TextStyle(color: Colors.white)),
              ),
            ],
          );
        }
      );
    },
  );
}
```
Kỹ thuật **StatefulBuilder** là "vũ khí bí mật" để biến một Dialog tĩnh thành một State động mà không cần tạo riêng một Class.
