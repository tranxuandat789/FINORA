# AI Coding & Architecture Guidelines (FINORA)

Tài liệu này đóng vai trò là "Kim chỉ nam" (Single Source of Truth) cho các AI Agents và Lập trình viên khi tham gia phát triển dự án Quản lý tài chính cá nhân **FINORA**.
Mục tiêu là đảm bảo mọi dòng code mới, mọi tính năng mới đều tuân thủ chặt chẽ kiến trúc hệ thống và nguyên tắc SOLID.

---

## 1. Tổng quan Kiến trúc (Architecture Overview)
Dự án sử dụng kiến trúc **Client-Server (Online-Only)**, KHÔNG sử dụng Local Database (SQLite, Hive) và KHÔNG dùng Firebase BaaS.
*   **Backend:** ASP.NET Core Web API (Kiến trúc Monolith N-Tier trong 1 Project).
*   **Frontend:** Flutter Mobile App (Kiến trúc Feature-Based + State Management bằng Provider).
*   **Authentication:** Tự code luồng JWT Authentication.
*   **Offline / Sync Mode:** Sử dụng giải pháp "File System Caching" (Đọc/Ghi file JSON trực tiếp xuống Storage điện thoại bằng `path_provider`) để lưu trạng thái và hàng đợi đồng bộ.

---

## 2. Nguyên tắc Code (Coding Principles - SOLID)
Khi được yêu cầu làm một tính năng mới (VD: "Làm chức năng thêm Giao dịch"), AI Agent BẮT BUỘC phải tuân thủ các nguyên tắc sau:
1.  **Single Responsibility Principle (SRP):** Một class/file chỉ đảm nhiệm 1 việc duy nhất.
    *   *Backend:* Controller chỉ nhận Request và gọi Service. Service chỉ xử lý logic kinh doanh. Repository chỉ gọi Database. Không trộn lẫn!
    *   *Frontend:* Widget chỉ lo vẽ UI. Service chỉ lo gọi API. Provider chỉ lo tính toán state.
2.  **Dependency Inversion Principle (DIP):**
    *   *Backend:* Controller phụ thuộc vào `IService` interface, không phụ thuộc class cụ thể. Service phụ thuộc vào `IRepository` interface. Luôn inject qua Constructor.
3.  **Tách biệt DTO và Entity:** Controller KHÔNG BAO GIỜ nhận/trả về trực tiếp Entity (Model). Phải dùng các class `RequestDto` và `ResponseDto`.

---

## 3. Quy trình thêm 1 Feature mới ở BACKEND (ASP.NET Core)
Khi tạo tính năng mới trên Backend, hãy duyệt qua các thư mục sau theo đúng thứ tự từ dưới lên trên (Data -> API):

1.  **`Models/` (Entity):**
    *   Tạo file class (VD: `Transaction.cs`). Ánh xạ trực tiếp với bảng SQL.
2.  **`DTOs/Requests/` & `DTOs/Responses/`:**
    *   Tạo các class chuyển giao dữ liệu (VD: `CreateTransactionRequest.cs`, `TransactionResponse.cs`).
3.  **`Repositories/Interfaces/` & `Repositories/Implementations/`:**
    *   Tạo Interface (VD: `ITransactionRepository.cs`) định nghĩa các hàm CRUD.
    *   Tạo class `TransactionRepository.cs` implement interface đó, inject `AppDbContext` để Query DB bằng Entity Framework Core.
4.  **`Services/Interfaces/` & `Services/Implementations/`:**
    *   Tạo Interface (VD: `ITransactionService.cs`).
    *   Tạo class `TransactionService.cs` chứa Logic (VD: Kiểm tra số dư ví, Cảnh báo vượt Budget...). Class này inject `ITransactionRepository`.
5.  **`Controllers/`:**
    *   Tạo `TransactionsController.cs` (có annotation `[ApiController]`). Inject `ITransactionService`. Define các endpoint GET, POST, PUT, DELETE.

---

## 4. Quy trình thêm 1 Feature mới ở FRONTEND (Flutter)
Mọi tính năng mới đều phải được bọc trong 1 thư mục con ở `lib/features/<feature_name>/`.
Ví dụ khi thêm tính năng Transaction, tạo thư mục `lib/features/transaction/` và làm theo các bước:

1.  **`models/` (Dữ liệu):**
    *   Tạo file (VD: `transaction_model.dart`). Class này phải có hàm `fromJson` và `toJson` để parse dữ liệu từ Backend.
2.  **`services/` (Giao tiếp Backend):**
    *   Tạo file (VD: `transaction_service.dart`). Gọi qua Dio/http Client trong thư mục `core/network`. 
    *   *Luật Offline:* Nếu API lỗi do mạng, Service sẽ ném lỗi.
3.  **`providers/` (State Management & Offline Logic):**
    *   Tạo file (VD: `transaction_provider.dart` kế thừa `ChangeNotifier`).
    *   Provider gọi `TransactionService`.
    *   *Luật Caching:* Provider gọi thêm `FileStorageService` (từ `core/local_storage/`) để lưu Cache kết quả JSON. Nếu Service quăng lỗi rớt mạng, Provider đọc Cache để hiển thị, đồng thời ghi "Lệnh thao tác" vào `sync_queue.json`.
4.  **`screens/` & `widgets/` (Giao diện):**
    *   Tạo các màn hình (VD: `transaction_list_screen.dart`).
    *   Sử dụng `Consumer<TransactionProvider>` hoặc `context.read/watch()` để bind UI với State. Tuyệt đối KHÔNG viết logic API hay tính toán phức tạp vào đây.

---

## 5. Mẫu Prompt tham khảo cho AI
Nếu bạn là User, khi cần tôi code chức năng mới, bạn chỉ cần copy mẫu lệnh sau:
> *"Hãy phát triển tính năng **[Tên tính năng - VD: Quản lý Ngân sách]** cho ứng dụng FINORA.* 
> *Nghiệp vụ: [Mô tả luồng hoạt động].*
> *Hãy tham khảo cấu trúc trong file **AI_CODING_GUIDELINES.md**, tạo ra đầy đủ các file Backend (từ Model, DTO, Repository, Service đến Controller) và Frontend (Model, Service, Provider, Screen) theo chuẩn SOLID."*

Khi nhận được Prompt này, tôi (AI) sẽ tự động rà soát file Guideline này và lên kế hoạch tạo file chính xác vào từng thư mục!
