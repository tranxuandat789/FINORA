# Nghiệp vụ Chi tiết Toàn bộ Hệ thống (FINORA Domain Logic)

Tài liệu này định nghĩa rõ ràng và dứt khoát toàn bộ logic xử lý cho các tính năng của FINORA, tuân thủ đúng định hướng: **Thủ công 100%, Không liên kết ngân hàng, Không lưu Local DB, và Áp dụng Ngân sách cộng dồn (Rollover).**

---

## 1. Domain: Authentication & User Profile
*   **Đăng nhập/Đăng ký:** Sử dụng cơ chế Email/Password. Mật khẩu được Hash (mã hóa) bằng BCrypt trước khi lưu vào SQL Server. Cấp phát **JWT Token** để Mobile gọi API.
*   **Mã PIN:** Mã PIN 6 số do user thiết lập sẽ được Hash và lưu ở bảng `Users` trên Server. Mobile app gọi API gửi mã PIN lên để đối chiếu. Nhập sai 5 lần sẽ khóa token hiện tại, bắt đăng nhập lại bằng mật khẩu.
*   **Settings:** Thiết lập như Dark Mode, Notifications chỉ được lưu ở thiết bị cục bộ (SharedPreferences), không lưu trên DB.

## 2. Domain: Wallet (Quản lý Ví)
*   **Bản chất:** Ví là nơi lưu trữ số dư tĩnh. Có 3 loại mặc định: Cash (Tiền mặt), Bank (Tài khoản ngân hàng), E-Wallet (Ví điện tử). 
*   **Khởi tạo:** Khi User tạo 1 ví mới với "Số dư ban đầu" (Ví dụ: 500.000đ). Hệ thống tự động sinh ra 1 Giao dịch loại `Income` (Thu) với danh mục "Khởi tạo ví" trị giá 500.000đ để số dư ví được tính toán chính xác.
*   **Xóa ví:** Sử dụng cơ chế **Soft Delete** (`IsDeleted = true`). Ví bị ẩn đi trên giao diện, nhưng số dư của ví đó vẫn được tính vào Tổng tài sản (Net Worth) để không làm gãy biểu đồ tài chính trong quá khứ.
*   **Tiền tệ:** Hệ thống chỉ sử dụng 1 loại tiền tệ duy nhất (VND) cho mọi ví.

## 3. Domain: Category (Danh mục thu chi)
*   **Cấp bậc:** Danh sách phẳng (Flat). Không có danh mục con.
*   **Phân loại (Type):** Mỗi Category bắt buộc phải mang cờ `Type = Income` hoặc `Type = Expense`.
*   **Default vs Custom:** Hệ thống sẽ có script Seed Data để tạo ra các Category mặc định chung cho toàn app (`UserId = null`). Ngoài ra, người dùng có thể tự tạo Category riêng của họ (`UserId = ID của user`).
*   **Ràng buộc:** Khi thêm Giao dịch, nếu chọn loại là Chi Tiêu, app chỉ hiển thị các danh mục có `Type = Expense`.

## 4. Domain: Transaction (Giao dịch)
*   **Chỉ có Thu và Chi:** Chốt theo định hướng của bạn, hệ thống **KHÔNG CÓ loại giao dịch Transfer (Chuyển khoản)**. Nếu user muốn ghi nhận việc rút tiền từ thẻ ATM ra Tiền mặt, họ phải tự nhập tay 2 giao dịch: 1 Chi từ ví ATM, 1 Thu vào ví Tiền mặt.
*   **Nguồn nhập liệu đa dạng:** Giao dịch có thể được nhập bằng form thủ công, hoặc bằng Giọng nói (Voice Input). Backend nhận file ghi âm hoặc text từ Voice, phân tích (dùng AI API), và trả về cấu trúc `{ Amount, CategoryId, Note }` để lưu vào DB giống như nhập thủ công.
*   **Hình ảnh & Split:** Không đính kèm hình ảnh hóa đơn. Mỗi giao dịch chỉ gán với đúng 1 Category.

## 5. Domain: Budget (Quản lý Ngân sách - CÓ ROLLOVER)
*   **Thiết lập:** 1 Ngân sách gắn chặt với 1 User và 1 Category cụ thể. Tính theo chu kỳ cố định (Mùng 1 đến ngày cuối tháng).
*   **Nghiệp vụ Rollover (Cộng dồn):** 
    *   Ví dụ: Tháng 5 set ngân sách Ăn uống = 3.000.000đ. Tháng 5 xài hết 2.000.000đ (Dư 1.000.000đ).
    *   Tháng 6: Ngân sách tự động trở thành: **3.000.000đ (Gốc) + 1.000.000đ (Rollover từ T5) = 4.000.000đ**.
    *   *Cách tính toán ở Backend:* Backend không cần chạy ngầm (cron job) để chốt sổ mỗi tháng. Thay vào đó, Backend lưu `StartDate` (Tháng bắt đầu lập ngân sách). Khi user mở app xem tháng hiện tại, Backend sẽ dùng lệnh SQL tính tổng TẤT CẢ giao dịch từ `StartDate` đến nay, trừ đi `Tổng (Ngân sách gốc * Số tháng đã qua)`, để tự động suy ra số tiền Rollover hiện có. Cách này chính xác tuyệt đối và không lo rớt mạng.

## 6. Domain: Saving Goal (Mục tiêu tiết kiệm)
*   **Bản chất độc lập:** Tiết kiệm là 1 sổ tay ghi chép ảo, KHÔNG LIÊN QUAN gì đến các Ví tiền.
*   **Nghiệp vụ:** Khi user đạt được 1 khoản tiền và muốn cất đi, họ ấn "Add Contribution" (Thêm đóng góp) vào Mục tiêu. Hành động này **KHÔNG LÀM TRỪ ĐI** số dư ở bất kỳ Ví nào. Nó chỉ tăng thanh tiến độ (%) của Mục tiêu đó lên.
*   Đảm bảo người dùng không bị "thiếu hụt" số dư giả trong ví khi họ đang để tiền thật ở ngân hàng.

---
*(Tài liệu này sẽ được lưu ở gốc dự án để làm căn cứ phát triển)*
