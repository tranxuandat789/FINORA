# MEDIUM Q1 – Trace luồng dữ liệu (Data Flow)
> **Câu hỏi gốc:** Trình bày chi tiết luồng dữ liệu (data flow) khi user thực hiện hành động `{...}`. Từ UI, dữ liệu đi qua những layer (tầng) nào trước khi lên Server?

---

## Trường hợp 1: `{...}` = Bấm "Lưu giao dịch" trong AddTransactionScreen

**Thầy hỏi:** Khi người dùng điền đủ thông tin và bấm "Lưu giao dịch", dữ liệu chạy qua những class và layer nào trước khi lưu vào Database trên server?

**Trả lời:**
Luồng dữ liệu đi qua 4 tầng chính: **UI (Screen) → State (Provider) → Data (Service/ApiClient) → Backend (.NET)**.

**1. Tầng UI (`AddTransactionScreen.dart`):**
- Hàm `_saveTransaction()` đọc dữ liệu từ `TextEditingController` (số tiền, ghi chú) và các biến state (`_selectedType`, `_selectedCategoryId`, `_selectedDate`).
- Gọi `context.read<TransactionProvider>().createTransaction(walletId, categoryId, type, amount, note, date)`.

**2. Tầng State (`TransactionProvider.dart`):**
- Đổi trạng thái `_isLoading = true`, gọi `notifyListeners()` để UI hiện loading.
- Gọi tiếp xuống tầng Service: `await _service.createTransaction(...)`.
- Nếu thành công: load lại danh sách giao dịch từ server (`loadTransactions()`), `_isLoading = false`, trả về `true`.
- Nếu lỗi mạng: lưu offline vào `sync_queue.json` qua `_addToSyncQueue()`, trả về `false`.

**3. Tầng Data (`TransactionService.dart` & `ApiClient.dart`):**
- `TransactionService` đóng gói payload thành dạng Map (JSON object):
  ```json
  { "walletId": "...", "categoryId": "...", "type": 2, "amount": 50000, "note": "...", "transactionDate": "..." }
  ```
- Gọi `ApiClient().post('/api/transactions', data)`.
- `ApiClient` (dùng thư viện Dio) gắn thêm **Authorization Token** vào header và gửi HTTP POST request lên Server.

**4. Tầng Backend (.NET) - Server:**
- **Controller** (`TransactionsController.cs`): Nhận HTTP POST, map request body vào DTO (`CreateTransactionDto`).
- **Service** (`TransactionService.cs`): Xử lý business logic, tạo entity `Transaction`, lưu qua Entity Framework (`_context.Transactions.Add()`).
- **Database** (SQL Server/PostgreSQL): Lưu dòng mới. Backend trả về HTTP 201 Created.

---

## Trường hợp 2: `{...}` = Kéo xuống để Refresh trong DashboardScreen

**Thầy hỏi:** Khi người dùng pull-to-refresh trên màn hình Dashboard, dữ liệu tổng quan được cập nhật qua những luồng nào?

**Trả lời:**
Sự kiện Refresh kích hoạt fetch data qua 3 tầng (UI → Provider → Service).

**1. Tầng UI (`DashboardScreen.dart`):**
- Widget `RefreshIndicator` bắt sự kiện onRefresh.
- Gọi `context.read<DashboardProvider>().loadDashboardData()`.

**2. Tầng State (`DashboardProvider.dart`):**
- Khởi tạo `_isLoading = true`, `_error = null`.
- Thường kiểm tra cache trước (nếu có `FileStorageService` trong Dashboard).
- Gọi `await _service.getDashboardData()`.
- Cập nhật state `_data` bằng kết quả trả về, `_isLoading = false`.
- Gọi `notifyListeners()` để UI vẽ lại biểu đồ và thẻ số dư.

**3. Tầng Data (`DashboardService.dart`):**
- Gọi `ApiClient().get('/api/dashboard/summary')`.
- Nhận JSON response từ server.
- Parse JSON thành object `DashboardDataModel` thông qua constructor `fromJson`.
- Trả object này về cho Provider.

---

## Trường hợp 3: `{...}` = Đăng nhập với Google trong LoginScreen

**Thầy hỏi:** Trình bày luồng khi user bấm "Tiếp tục với Google". Frontend tương tác với ai và làm sao để nhận Token?

**Trả lời:**
Luồng này liên quan đến **Google Sign-In SDK**, Provider và Backend riêng biệt.

**1. Tầng UI (`LoginScreen.dart`):**
- Bấm nút Google, gọi `authProvider.loginWithGoogle()`.

**2. Tầng State (`AuthProvider.dart`):**
- Gọi `_googleSignIn.signIn()` từ thư viện `google_sign_in`.
- **Tương tác OS/Google:** Mở popup chọn tài khoản Google trên điện thoại. Google trả về `GoogleSignInAuthentication` chứa **idToken** và **accessToken**.
- Gọi xuống Service: `await _repository.loginWithGoogle(googleAuth.idToken)`.
- Nhận Token từ Backend → lưu vào `SharedPreferences`.

**3. Tầng Data (`AuthRepository.dart`):**
- Gọi `ApiClient().post('/api/auth/google', data: {'token': idToken})`.

**4. Tầng Backend (.NET):**
- Backend gọi Google API để verify `idToken` là hàng thật.
- Kiểm tra email trong DB: nếu có thì login, nếu chưa có thì tạo account tự động.
- Sinh ra **JWT Token** nội bộ của hệ thống và trả về cho Frontend.

---

## Trường hợp 4: `{...}` = Mở app và xem danh sách giao dịch (App Khởi Động)

**Thầy hỏi:** Khi vừa mở app, luồng dữ liệu nào giúp danh sách giao dịch hiển thị ngay lập tức (không thấy màn hình loading trắng)?

**Trả lời:**
Luồng này sử dụng **Cache-First (Offline-First)** pattern.

**1. Tầng UI (`TransactionScreen.dart`):**
- `initState` gọi `TransactionProvider.loadTransactions()`.

**2. Tầng State (`TransactionProvider.dart`) - Bước Cache:**
- Đọc file local: `FileStorageService.readData('transactions_cache.json')`.
- Nếu có file → parse JSON thành `List<TransactionModel>`.
- Gán vào `_transactions` và gọi `notifyListeners()`.
- **UI lập tức vẽ danh sách cũ lên màn hình**.

**3. Tầng Data - Bước API (Chạy ngầm):**
- Ngay sau đó, gọi `TransactionService.getTransactions()`.
- `ApiClient` tải dữ liệu mới nhất từ Server.
- Parse thành list mới → Gán lại `_transactions`.
- Gọi `FileStorageService.writeData('transactions_cache.json')` để đè cache mới.
- Gọi `notifyListeners()` lần 2 → UI cập nhật data mới một cách mượt mà (chớp nhẹ).

---

## Trường hợp 5: `{...}` = Nhấn giữ chú ong (Ghi âm) và tự động điền form

**Thầy hỏi:** Luồng dữ liệu chạy thế nào từ lúc user đọc "Mua trà sữa 50 ngàn" đến khi form được điền?

**Trả lời:**
Đây là luồng **Voice → AI → JSON → UI**.

**1. Tầng UI (`FloatingVoiceButton.dart`):**
- Bắt sự kiện `onLongPressStart`.
- Gọi `VoiceRecordingService.startListening()` (dùng Speech-To-Text API của thiết bị).
- Nhận chuỗi text: "Mua trà sữa 50 ngàn".
- Sự kiện `onLongPressEnd` → truyền chuỗi text cho `TransactionProvider.analyzeVoice(text)`.

**2. Tầng State & Data (`TransactionProvider` -> `TransactionService`):**
- Gửi HTTP POST lên `/api/transactions/analyze-voice` kèm payload `{"text": "Mua trà sữa 50 ngàn"}`.

**3. Tầng Backend / AI:**
- Backend nhận text, gọi API OpenAI / Gemini với prompt thiết kế sẵn.
- AI trả về JSON: `{"amount": 50000, "categoryId": "...", "note": "Mua trà sữa"}`.
- Backend mapping và trả về cho app.

**4. Phản hồi về UI (`FloatingVoiceButton.dart`):**
- Nhận object `VoiceAnalysisModel`.
- Gọi `Navigator.push()` sang `AddTransactionScreen` và truyền data via tham số `voiceData`.
- `AddTransactionScreen.initState()` đọc `voiceData` và gán vào `_amountController`, `_noteController`...

---

## Trường hợp 6: `{...}` = Xóa một danh mục chi tiêu

**Thầy hỏi:** Khi xóa một danh mục trong app, luồng dữ liệu xóa diễn ra như thế nào? Cần cập nhật những đâu để UI đồng bộ?

**Trả lời:**
**1. Tầng UI (`CategoryBottomSheet` hoặc `CategoryListScreen`):**
- Gọi `CategoryProvider.deleteCategory(id)`.

**2. Tầng Data & State:**
- Gọi API DELETE: `ApiClient().delete('/api/categories/$id')`.
- Khi API trả về 200 OK:
  - `_categories.removeWhere((c) => c.id == id)` (Xóa khỏi RAM).
  - `FileStorageService.writeData(...)` (Cập nhật cache file local).
  - `notifyListeners()` (Báo UI refresh lưới danh mục).

**3. Tác động phụ (Cập nhật Dashboard):**
- Vì danh mục bị xóa, các giao dịch thuộc danh mục này có thể bị mất liên kết (trở thành 'Uncategorized' tùy logic backend).
- Frontend thường cần gọi thêm `TransactionProvider.loadTransactions()` và `DashboardProvider.loadDashboardData()` để đảm bảo biểu đồ không bị sai lệch.

---

## Trường hợp 7: `{...}` = Đồng bộ dữ liệu offline (Sync offline)

**Thầy hỏi:** Khi có mạng trở lại, ứng dụng đồng bộ dữ liệu offline như thế nào? Luồng xử lý diễn ra sao?

**Trả lời:**
Sử dụng background task hoặc `SyncProvider`.

**1. Kích hoạt:**
- `SyncProvider` lắng nghe trạng thái mạng (qua gói `connectivity_plus`) hoặc gọi định kỳ khi khởi động app.
- Nếu có mạng, gọi hàm `syncData()`.

**2. Đọc Queue (`SyncProvider` & `FileStorageService`):**
- Đọc `sync_queue.json` lấy danh sách các thao tác chưa được gửi.
- VD: `[{"action": "create_transaction", "data": {...}}, {"action": "delete_transaction", "data": {...}}]`.

**3. Xử lý đồng bộ (Sync Loop):**
- Vòng lặp foreach từng item trong queue.
- Nếu là `create_transaction`: gọi lại `TransactionService.createTransaction(item.data)`.
- Gửi thành công → xóa item đó khỏi queue local.
- Lỗi (do network lại đứt) → dừng vòng lặp, chờ lần sau.

**4. Hoàn tất (`TransactionProvider` & UI):**
- Gửi xong tất cả, gọi `TransactionProvider.loadTransactions()` để tải danh sách chuẩn nhất từ server.
- Cập nhật lại cache transactions.

---

## Trường hợp 8: `{...}` = Đăng xuất khỏi ứng dụng (Logout)

**Thầy hỏi:** Trình bày luồng khi người dùng nhấn "Đăng xuất" trong ProfileScreen. Phải dọn dẹp dữ liệu ở những layer nào?

**Trả lời:**
Luồng Logout yêu cầu dọn dẹp từ RAM, Local Storage đến State.

**1. Tầng UI (`ProfileScreen.dart`):**
- Gọi `context.read<AuthProvider>().logout()`.

**2. Tầng State & Service (`AuthProvider.dart`):**
- Gọi API Backend `POST /api/auth/logout` (để invalidate token trên server nếu có blacklist).
- Gán `_user = null`, `token = null`.

**3. Dọn dẹp Local Storage (`SharedPreferences` & Files):**
- Xóa Token: `prefs.remove('token')`, `prefs.remove('user')`.
- **Quan trọng:** Phải gọi `FileStorageService.clearAll()` để xóa tất cả file cache của user cũ (transactions_cache, categories_cache), tránh rò rỉ dữ liệu tài chính cho người dùng login tiếp theo.
- Gọi `_googleSignIn.signOut()` để ngắt kết nối Google.

**4. Điều hướng (Navigation):**
- Gọi `notifyListeners()` và dùng `Navigator.pushAndRemoveUntil` đẩy người dùng về `LoginScreen`, xóa toàn bộ history navigation trước đó.
