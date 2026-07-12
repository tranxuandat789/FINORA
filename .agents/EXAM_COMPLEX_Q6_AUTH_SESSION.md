# COMPLEX Q6 – Bảo mật Auth/Session
> **Câu hỏi gốc:** Mã Token (JWT) hiện tại được ứng dụng lưu trữ và gắn vào request API như thế nào? Nếu Token này bị hết hạn (Expired), làm sao để ứng dụng tự động "Renew" mà không văng ra bắt user đăng nhập lại?

---

## 1. Cách lưu trữ và gắn Token hiện tại

**Thầy hỏi:** Trong app FINORA, token đăng nhập đang được lưu ở đâu và làm cách nào để gửi nó lên Server trong mỗi yêu cầu (Get Transactions, Post Dashboard...)?

**Trả lời:**
- **Lưu trữ:** Token được lưu thẳng dưới dạng Text trong bộ nhớ đệm `SharedPreferences` thông qua lớp `AuthProvider`.
- **Gắn vào Request:** Trong app đang sử dụng cơ chế **Interceptors của thư viện Dio** tại file `ApiClient.dart`.

```dart
// ApiClient.dart (Cấu hình Interceptor cơ bản)
_dio.interceptors.add(InterceptorsWrapper(
  onRequest: (options, handler) async {
    // Trước khi bất kỳ request nào bay đi, chặn lại
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token'); // Lấy token từ ổ cứng
    
    if (token != null) {
      // Nhồi thẻ ra vào (Authorization header)
      options.headers['Authorization'] = 'Bearer $token'; 
    }
    
    // Thả cho đi tiếp
    return handler.next(options);
  },
));
```
**Ưu điểm của Interceptor:** Bạn chỉ cần viết code nhồi Token MỘT LẦN DUY NHẤT. Tất cả các hàm như `getTransactions()`, `createCategory()` cứ gọi bình thường, thư viện Dio sẽ tự động nhồi Token vào đằng sau hậu trường.

---

## 2. Xử lý Token hết hạn (Token Expiration / Refresh Token)

**Thầy hỏi:** Token JWT chỉ sống được 30 phút. Nếu user đang xài mà hết hạn, API backend sẽ trả về mã lỗi 401 Unauthorized. App hiện tại có xử lý không? Nếu muốn làm cơ chế Refresh Token tự động (Silent Refresh) thì viết logic ở đâu?

**Trả lời:**
Hiện tại, app FINORA **CHƯA CÓ** cơ chế tự động refresh token. Nếu gặp 401, API sẽ ném lỗi và các chức năng ngừng hoạt động (người dùng phải thủ công đăng xuất và đăng nhập lại).

**Cách triển khai Refresh Token (Live-code bằng Dio Interceptor):**
Để user không bị văng ra ngoài, ta phải can thiệp vào block `onError` của Interceptor.

```dart
_dio.interceptors.add(InterceptorsWrapper(
  onRequest: (options, handler) async { ... },
  
  onError: (DioException e, handler) async {
    // 1. Nếu bắt được lỗi 401 (Hết hạn Token)
    if (e.response?.statusCode == 401) {
      
      // 2. Chặn tất cả request khác lại, tiến hành gọi API xin Token mới
      final prefs = await SharedPreferences.getInstance();
      final refreshToken = prefs.getString('refresh_token');
      
      if (refreshToken != null) {
        try {
          // Gọi API (không dùng cái _dio hiện tại để tránh vòng lặp, dùng Dio mới)
          final tokenDio = Dio(BaseOptions(baseUrl: Constants.baseUrl));
          final response = await tokenDio.post('/api/auth/refresh-token', data: {
            'refreshToken': refreshToken
          });
          
          // 3. Lấy được Token mới, lưu lại vào máy
          final newAccessToken = response.data['accessToken'];
          await prefs.setString('token', newAccessToken);
          
          // 4. Sửa lại Request ban đầu (Request vừa bị chết 401) với Token MỚI
          e.requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';
          
          // 5. Retry (Gửi lại Request ban đầu)
          final retryResponse = await _dio.fetch(e.requestOptions);
          
          // Giải quyết lỗi mượt mà, trả kết quả về như chưa hề có lỗi 401
          return handler.resolve(retryResponse);
          
        } catch (refreshError) {
          // Nếu cả Refresh Token cũng chết (hết hạn nốt 30 ngày)
          // Xóa trắng dữ liệu và bắt đẩy ra màn hình Login
          await prefs.clear();
          // Broadcast một sự kiện để UI tự văng ra ngoài (Stream/EventBus)
          return handler.reject(e);
        }
      }
    }
    
    // Nếu không phải lỗi 401, cứ ném lỗi ra bình thường
    return handler.next(e);
  }
));
```

**Phân tích kỹ thuật sâu:**
Kỹ thuật này gọi là **Silent Retry**. Người dùng bấm "Xóa giao dịch" → Gửi lên báo 401 → App âm thầm gọi API thứ 2 xin vé mới → Lấy được vé, bắn lại API Xóa lần nữa → Trả kết quả báo "Xóa thành công".
Toàn bộ quá trình diễn ra trong chớp mắt (~200ms), người dùng không hề biết Token của mình vừa chết và vừa được phục sinh.

Đây là một trong những tính năng phân loại Senior Flutter Developer.
