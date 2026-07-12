# COMPLEX Q8 – Pagination (Phân trang API)
> **Câu hỏi gốc:** Nếu hệ thống có 1 triệu giao dịch, lệnh `getTransactions()` hiện tại sẽ tải toàn bộ 1 triệu bản ghi về RAM, làm sập app. Cần viết thêm cơ chế Phân trang (Pagination / Infinite Scroll). Hãy trình bày cách sửa đổi từ Backend đến Frontend để thực hiện Load More.

---

## Giải pháp & Phân tích Live-code

Đây là tính năng bắt buộc phải có cho các danh sách dài. Việc không có phân trang là một lỗi thiết kế nghiêm trọng đối với ứng dụng tài chính.

### 1. Sửa đổi tầng Backend (.NET)

Thay vì trả thẳng List 1000 item, Backend phải hỗ trợ tham số `page` và `limit`, đồng thời trả về cấu trúc Metadata (chứa thông tin tổng số trang để app biết đường dừng).

**Controller & Service:**
```csharp
[HttpGet]
public async Task<IActionResult> GetTransactions([FromQuery] int page = 1, [FromQuery] int limit = 20)
{
    var query = _context.Transactions.OrderByDescending(t => t.TransactionDate);
    
    // Đếm tổng số
    var totalRecords = await query.CountAsync();
    var totalPages = (int)Math.Ceiling(totalRecords / (double)limit);
    
    // Cắt khúc (Skip & Take)
    var items = await query.Skip((page - 1) * limit).Take(limit).ToListAsync();
    
    // Trả về DTO
    return Ok(new {
        Data = items,
        Meta = new {
            CurrentPage = page,
            TotalPages = totalPages,
            TotalRecords = totalRecords
        }
    });
}
```

### 2. Sửa đổi tầng Service & Provider (Flutter)

App cần duy trì biến `currentPage` và cờ hiệu `hasMore` (xác định xem đã đến cuối chưa).

**Trong `TransactionProvider.dart`:**

```dart
class TransactionProvider extends ChangeNotifier {
  List<TransactionModel> _transactions = [];
  bool _isLoading = false;
  bool _isLoadingMore = false; // Cờ cho việc cuộn dưới đáy
  
  int _currentPage = 1;
  bool _hasMore = true; // Cờ kiểm tra còn data không
  
  // Getter...

  // Lần đầu mở app hoặc kéo Refresh
  Future<void> loadTransactions({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _hasMore = true;
      _isLoading = true;
      notifyListeners();
    }
    
    try {
      final response = await _apiClient.get('/api/transactions?page=$_currentPage&limit=20');
      final List rawList = response.data['data'];
      final totalPages = response.data['meta']['totalPages'];
      
      final newItems = rawList.map((e) => TransactionModel.fromJson(e)).toList();
      
      if (refresh) {
        _transactions = newItems;
      } else {
        _transactions.addAll(newItems); // Nối tiếp mảng cũ
      }
      
      _currentPage++;
      _hasMore = _currentPage <= totalPages;
      
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  // Hàm dành riêng cho việc vuốt tới đáy màn hình
  Future<void> loadMore() async {
    if (_isLoadingMore || !_hasMore) return; // Đang load rồi hoặc hết sạch rổi thì nghỉ
    
    _isLoadingMore = true;
    notifyListeners();
    
    await loadTransactions(); // Gọi lại lõi logic (nó sẽ xài _currentPage mới)
  }
}
```

### 3. Sửa đổi tầng UI (`TransactionScreen.dart`)

Làm sao để app biết người dùng đã vuốt đến đáy? Dùng `ScrollController`.

**Bổ sung ScrollController:**

```dart
class _TransactionScreenState extends State<TransactionScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    
    // Lắng nghe sự kiện vuốt
    _scrollController.addListener(() {
      // Nếu vị trí vuốt hiện tại chạm mốc (90% chiều dài danh sách)
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
        // Kích hoạt load thêm
        context.read<TransactionProvider>().loadMore();
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TransactionProvider>().loadTransactions(refresh: true);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
  
  // Build Method ...
}
```

**Sửa ListBuilder để hiển thị icon xoay xoay dưới đáy:**

```dart
// Thay vì itemCount: provider.transactions.length
// Ta cộng thêm 1 slot cho vòng loading dưới đáy nếu còn data
itemCount: provider.transactions.length + (provider.hasMore ? 1 : 0),
itemBuilder: (context, index) {
  // Nếu vuốt đến cái index cuối cùng (slot + 1 đó)
  if (index == provider.transactions.length) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 16),
      child: Center(child: CircularProgressIndicator()),
    );
  }
  
  // Mặc định vẽ cục Transaction bình thường
  final transaction = provider.transactions[index];
  return TransactionItemWidget(transaction: transaction);
}
```

### 4. Bẫy Thẩm định (Gotchas)

**Hỏi: Tại sao lại cần biến `_isLoadingMore` trong khi đã có biến `_isLoading`? Gộp làm một được không?**
- **Trả lời:** KHÔNG THỂ GỘP. `_isLoading` dùng cho lần load đầu tiên (biến màn hình thành một cục xoay tròn bự chảng cản hết giao diện). `_isLoadingMore` là load âm thầm dưới đáy, lúc này màn hình vẫn đang vẽ danh sách 20 item cũ bình thường. Nếu gộp lại, mỗi lần load thêm trang 2, trang 3, danh sách cũ sẽ chớp tắt nháy liên tục rất xấu.

**Hỏi: Tại sao thiết lập trừ hao `maxScrollExtent - 200`? Tại sao không dùng toán tử `== maxScrollExtent`?**
- **Trả lời:** Nếu đợi user chạm đúng 100% đáy (`== maxScrollExtent`) mới bắn API, user sẽ bị khựng lại đợi (cảm giác cục mịch). Cấu hình trừ hao 200 pixel (cách đáy khoảng 2 item) giúp lệnh gọi API bay đi sớm hơn. Khi user vuốt tới đáy thì vừa vặn API trả kết quả về, cảm giác vuốt "vô cực" (Infinite Scroll) rất mượt mà.
