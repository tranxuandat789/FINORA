# MEDIUM Q4 – Tối ưu Rebuild (Performance)
> **Câu hỏi gốc:** Đoạn code hiển thị danh sách ở `{...}` nếu chạy với 10,000 phần tử có bị giật (lag) không? Có những kỹ thuật nào trong Flutter để tối ưu hóa việc vẽ giao diện trong trường hợp này?

---

## Trường hợp 1: `{...}` = Danh sách ở **TransactionScreen**

**Thầy hỏi:** Nếu danh sách giao dịch ở `TransactionScreen` có 10,000 item, nó có lag không? App đã áp dụng kỹ thuật nào để chống lag?

**Trả lời:**
**Không lag (hoặc rất ít lag)** vì app đang dùng 2 kỹ thuật tối ưu cốt lõi:

**1. Sử dụng `ListView.builder` (Lazy Loading Widget):**
Thay vì tạo sẵn 10,000 ô Widget cùng lúc bằng `ListView(children: [...])`, `ListView.builder` chỉ render những item **đang nằm trong màn hình** (thêm vài item ở vùng buffer trên/dưới).
Khi vuốt màn hình, các Widget cũ cuộn lên trên sẽ bị hủy (dispose), và Widget mới dưới cùng sẽ được tạo ra. RAM chỉ tốn cho ~10 item thay vì 10,000 item.

**2. Sử dụng `Consumer` thay cho `context.watch` ở cấp cao nhất:**
Trong file `TransactionScreen.dart`:
```dart
body: Consumer<TransactionProvider>(
  builder: (context, provider, child) {
    return ListView.builder(...);
  }
)
```
Nếu `provider` gọi `notifyListeners()`, **chỉ phần `ListView` được vẽ lại**, còn `Scaffold` và `AppBar` tĩnh không bị ảnh hưởng.

---

## Trường hợp 2: `{...}` = Từ khóa `const` trong Widget Tree

**Thầy hỏi:** Ở rất nhiều chỗ như `const SizedBox(height: 16)`, `const Text('...')`, tại sao lại có chữ `const`? Xóa chữ `const` đi app có chạy được không? Có ảnh hưởng gì không?

**Trả lời:**
- Xóa chữ `const` đi **app vẫn chạy bình thường**, không báo lỗi logic.
- **Tác động nếu xóa:** Giảm hiệu năng (Performance).

**Tại sao dùng `const`:**
Khi một Widget được khai báo `const`, Flutter sẽ cấp phát nó **ở thời điểm biên dịch (Compile-time)**.
Trong quá trình app chạy, mỗi khi màn hình phải rebuild (do `setState` hoặc `notifyListeners`), Flutter sẽ dò từ trên xuống dưới cây Widget. Gặp các Widget có `const`, nó biết "Ah, cái này không bao giờ thay đổi" và **nhảy qua luôn, không tốn chu kỳ CPU để vẽ lại**.
Đối với một list dài hoặc màn hình phức tạp như `DashboardScreen`, việc dùng `const` giúp Flutter render ở 60fps mượt mà.

---

## Trường hợp 3: `{...}` = Danh sách GridView trong **CategoryBottomSheet**

**Thầy hỏi:** Màn hình `CategoryBottomSheet` dùng `GridView.builder`. Có cách nào tối ưu hơn nữa không nếu mỗi ô Icon category cần tính toán màu sắc phức tạp?

**Trả lời:**
Hiện tại, `GridView.builder` đã lazy load. Tuy nhiên, nếu hàm `itemBuilder` nặng, ta có thể tối ưu thêm bằng cách tách Item ra thành một **Widget riêng** thay vì code nội tiếp (inline).

```dart
// Thay vì:
itemBuilder: (context, index) {
  return InkWell(
     child: Column( // ... 30 dòng code
  );
}

// Chuyển thành:
itemBuilder: (context, index) => CategoryItemWidget(cat: filteredCategories[index]);
```

**Lợi ích:**
Tạo Class Widget độc lập giúp Flutter tận dụng cơ chế `const` (nếu truyền data tĩnh) và quản lý Element Tree thông minh hơn, hạn chế việc khởi tạo lại cây DOM ẩn.

---

## Trường hợp 4: `{...}` = `Selector` vs `Consumer` trong Provider

**Thầy hỏi:** Trong `DashboardScreen`, nếu biểu đồ `DonutChart` chỉ quan tâm đến danh sách `expenses`, nhưng `DashboardProvider` có cả `recentTransactions`, làm sao để cập nhật `transactions` mà biểu đồ không bị vẽ lại?

**Trả lời:**
Hiện tại, code dùng `Consumer<DashboardProvider>`.
Nhược điểm: Bất cứ field nào (số dư, chart, lịch sử) thay đổi thì **toàn bộ body** của Dashboard bị rebuild.

**Để tối ưu, cần thay bằng `Selector`:**
```dart
Selector<DashboardProvider, List<CategoryExpense>>(
  selector: (context, provider) => provider.data?.expenses ?? [],
  builder: (context, expenses, child) {
    return _buildSpendingAnalytics(expenses);
  },
)
```
- `Selector` chỉ quan tâm đến `expenses`. 
- Nếu `notifyListeners()` chạy nhưng `expenses` không đổi (ví dụ app chỉ load thêm `recentTransactions`), thì khu vực biểu đồ `DonutChart` **từ chối vẽ lại**.

---

## Trường hợp 5: `{...}` = Load danh sách ngầm

**Thầy hỏi:** Nếu backend chưa code xong phân trang, gửi 1 cục JSON 10,000 item về, hàm `TransactionService.getTransactions()` lúc parse JSON có làm app bị đơ/giật lag không?

**Trả lời:**
**CÓ THỂ LÀM ĐƠ MÀN HÌNH** (Jank/UI Freeze).

**Lý do:**
Dart là ngôn ngữ đơn luồng (Single-Thread) cho UI. Việc lặp `for` 10,000 phần tử để parse chuỗi JSON dài dằng dặc thành List Object tiêu tốn khoảng 50-100 mili-giây trên máy yếu. Trong lúc đó, vòng lặp UI bị kẹt → animation con ong hay vòng loading xoay tròn sẽ bị **khựng**.

**Cách khắc phục (Isolates / `compute`):**
Thay vì decode JSON trên luồng chính (Main Isolate), đẩy sang một luồng song song (Worker Isolate):
```dart
// transaction_service.dart
Future<List<TransactionModel>> getTransactions() async {
  final response = await _apiClient.get('/api/transactions');
  // Dùng hàm compute của Flutter để parse JSON trên luồng khác
  return await compute(_parseTransactionsJson, response.data);
}

// Hàm global tách biệt
List<TransactionModel> _parseTransactionsJson(dynamic data) {
  return (data as List).map((e) => TransactionModel.fromJson(e)).toList();
}
```
Kỹ thuật này giữ UI luôn mượt ở 60fps dù data lớn.
