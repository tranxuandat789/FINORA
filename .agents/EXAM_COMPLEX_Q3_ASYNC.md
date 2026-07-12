# COMPLEX Q3 – Sửa lỗi Async/Await
> **Câu hỏi gốc:** Cho đoạn code giả lập bị lỗi Unhandled Exception, màn hình trắng xoá (White Screen of Death) hoặc Crash. Bằng cách quan sát luồng Async/Await trong `{...}`, chỉ ra dòng gây lỗi và cách sửa triệt để.

---

## Trường hợp 1: `{...}` = `Provider` kết hợp `initState`

**Thầy hỏi:** Thầy có đoạn code sau ở màn hình `DashboardScreen`, khi mở lên app bị **crash đỏ lòm**. Lỗi ở đâu và tại sao?

```dart
@override
void initState() {
  super.initState();
  // Đoạn code lỗi:
  final data = context.read<DashboardProvider>().loadDashboardData();
  print(data.expenses.length); // Muốn in ra số lượng chi tiêu
}
```

**Trả lời:**
Lỗi này cực kỳ nghiêm trọng và có hai nguyên nhân kết hợp làm app crash ngay lập tức.

**Lỗi 1: Gọi hàm Provider chưa an toàn trong `initState`.**
Trong vòng đời (Lifecycle) của Flutter, ở thời điểm `initState`, Widget con chưa được gắn hoàn toàn (attach) vào Widget Tree. Do đó lệnh `context.read()` có thể ném Exception: `dependOnInheritedWidgetOfExactType<_InheritedProviderScope>... was called before _DashboardScreenState.initState() completed`.
**Cách sửa 1:** Bọc vào PostFrameCallback:
```dart
WidgetsBinding.instance.addPostFrameCallback((_) {
  context.read<DashboardProvider>().loadDashboardData();
});
```

**Lỗi 2: Hiểu sai bản chất Async/Await.**
Hàm `loadDashboardData()` trong provider là một hàm `Future<void>`.
Lệnh gọi `final data = ...` ở trên trả về một đối tượng `Future`, KHÔNG PHẢI trả về data thật.
Do đó lệnh `data.expenses` (truy cập thuộc tính của Future) sẽ gây lỗi Compile Error hoặc NoSuchMethodError. Hơn nữa, vì chạy ngầm (async), dòng print sẽ chạy TRƯỚC KHI api trả kết quả về.

**Cách sửa Triệt Để:**
Không được bắt lấy data trực tiếp từ hàm load. Màn hình phải đợi Provider gọi `notifyListeners()` và Consumer tự động vẽ lại.
Nếu chỉ cần log, hãy làm như sau:
```dart
@override
void initState() {
  super.initState();
  WidgetsBinding.instance.addPostFrameCallback((_) async {
    await context.read<DashboardProvider>().loadDashboardData();
    // Sau khi await, data đã được load vào biến provider.data
    final provider = context.read<DashboardProvider>();
    print(provider.data?.expenses.length ?? 0);
  });
}
```

---

## Trường hợp 2: `{...}` = Code gọi API xóa giao dịch

**Thầy hỏi:** Có đoạn code nút "Xóa" như sau, chạy bị lỗi "setState() called after dispose()". Tại sao bị lỗi và sửa thế nào?

```dart
ElevatedButton(
  onPressed: () async {
    showLoadingDialog(context); // Bật loading xoay xoay
    
    // Gọi API xóa tốn 3 giây
    await TransactionService().deleteTransaction(id); 
    
    Navigator.pop(context); // Tắt loading dialog
    
    setState(() {
      // Cập nhật lại giao diện
      transactions.removeWhere((t) => t.id == id);
    });
  },
  child: Text('Xóa'),
)
```

**Trả lời:**
**Nguyên nhân:** Lỗi xảy ra khi trong lúc 3 giây chờ API (`await`), người dùng bấm nút **Back vật lý** trên điện thoại.
Hành động Back sẽ hủy màn hình hiện tại (gọi hàm `dispose()`).
Thế nhưng, sau 3 giây, dòng code bên dưới chữ `await` tiếp tục chạy. Nó cố gắng gọi `Navigator.pop(context)` và `setState()` trên một màn hình **đã chết**. Hệ quả là Flutter quăng Exception chói lóa.

**Cách sửa (The Golden Rule của Async trong Flutter):**
Luôn kiểm tra `mounted` sau mỗi lệnh `await` khi có ý định động chạm vào UI (`context` hoặc `setState`).

**Code đúng:**
```dart
ElevatedButton(
  onPressed: () async {
    showLoadingDialog(context); 
    
    await TransactionService().deleteTransaction(id); 
    
    if (!mounted) return; // KHIÊN CHẮN LỖI (BẮT BUỘC)
    
    Navigator.pop(context); // Tắt dialog an toàn
    
    setState(() {
      transactions.removeWhere((t) => t.id == id);
    });
  },
)
```

---

## Trường hợp 3: `{...}` = `FutureBuilder` và re-build vĩnh cửu

**Thầy hỏi:** Thầy thay `Consumer` bằng `FutureBuilder` để load giao dịch như đoạn code dưới. Nó chạy được nhưng màn hình giật tung chảo, API bị gọi liên tục hàng trăm lần mỗi giây (Spam Server). Tại sao?

```dart
// Code lỗi trong TransactionScreen.dart
Widget build(BuildContext context) {
  return FutureBuilder(
    // Gọi hàm async TRỰC TIẾP trong hàm build
    future: TransactionService().getTransactions(), 
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) return CircularProgressIndicator();
      return ListView.builder(...);
    }
  );
}
```

**Trả lời:**
Đây là một trong những lỗi chí mạng nhất của dev Flutter (Infinite Loop Rebuild).

**Nguyên nhân:**
Hàm `build()` của Flutter có thể được gọi ra **rất nhiều lần** một cách vô cớ (do bàn phím bật lên, hiệu ứng cuộn, thay đổi kích thước màn hình).
Mỗi lần `build()` chạy, lệnh `TransactionService().getTransactions()` lại được thực thi lại từ đầu.
Hàm getTransactions gọi API, trả về Future mới → `FutureBuilder` nhận diện data mới → Yêu cầu màn hình vẽ lại → Gọi `build()` → Lại gọi API. Tạo thành vòng lặp vô tận đánh sập Server.

**Cách sửa:**
Biến `Future` bắt buộc phải được gán ở `initState`, không bao giờ được khởi tạo trong hàm `build()`.

```dart
// Code đúng
late Future<List<TransactionModel>> _futureTransactions;

@override
void initState() {
  super.initState();
  // Khởi tạo và gọi API ĐÚNG MỘT LẦN duy nhất
  _futureTransactions = TransactionService().getTransactions(); 
}

Widget build(BuildContext context) {
  return FutureBuilder(
    future: _futureTransactions, // Chỉ nhận biến truyền vào
    builder: (context, snapshot) { ... }
  );
}
```

---

## Trường hợp 4: Xử lý Promise/Future.wait (Gửi song song)

**Thầy hỏi:** Khi người dùng bấm đồng bộ (Sync), ta phải upload 50 giao dịch offline lên server. Code hiện tại dùng vòng lặp `for` và `await` từng cái một. Mất tận 10 giây. Làm sao để tối ưu xuống còn 2 giây?

```dart
// Code hiện tại bị chậm:
for (var item in syncQueue) {
  await ApiClient().post('/api/transactions', item.data);
}
```

**Trả lời:**
Cách hiện tại (Sequential Execution) bắt giao dịch thứ 2 phải chờ giao dịch thứ 1 hoàn thành xong hoàn toàn mới được gửi. Thời gian bằng tổng 50 request cộng lại.

**Cách sửa (Concurrent Execution):**
Bắn cả 50 request lên Server *CÙNG MỘT LÚC* bằng `Future.wait`.

```dart
// Code tối ưu (Nhanh gấp 5-10 lần):
final List<Future> uploadTasks = [];

for (var item in syncQueue) {
  // Gán task vào mảng, KHÔNG DÙNG await ở đây
  uploadTasks.add(ApiClient().post('/api/transactions', item.data));
}

try {
  // Gom lại và chờ tất cả cùng xong
  await Future.wait(uploadTasks);
  print('Đồng bộ thành công tất cả!');
} catch (e) {
  print('Có ít nhất một giao dịch bị lỗi.');
}
```
Lưu ý kỹ thuật: Cách này có thể làm nghẽn Server nếu mảng lên tới hàng nghìn request, lúc đó cần chia "batch" (mỗi lần bắn song song 20 cái).
