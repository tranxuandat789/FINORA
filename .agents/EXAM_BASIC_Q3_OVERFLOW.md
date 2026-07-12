# BASIC Q3 – Xử lý tràn viền (Overflow)
> **Câu hỏi gốc:** Nếu nội dung văn bản ở `{...}` dài gấp 3 lần bình thường, giao diện có bị vỡ không? Chỉ ra Widget trong code đang xử lý việc này (`Expanded`, `Flexible`, `Wrap`...).

---

## Trường hợp 1: `{...}` = Tên giao dịch trong **TransactionScreen** (categoryName)

**Thầy hỏi:** Nếu tên danh mục của một giao dịch dài bất thường (VD: "Ăn uống gia đình ngày nghỉ cuối tuần"), giao diện `TransactionScreen` có bị vỡ không? Widget nào đang xử lý?

**Trả lời:**
**KHÔNG bị vỡ** vì tên danh mục được bọc trong `Expanded` + có `overflow` xử lý:

```dart
// transaction_screen.dart dòng ~83-89
Expanded(                          // Co giãn chiếm phần còn lại
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        transaction.categoryName.isNotEmpty ? transaction.categoryName : 'Chưa phân loại',
        style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, ...),
        // KHÔNG có maxLines → có thể xuống dòng
      ),
      Text(
        transaction.note ?? '',
        style: GoogleFonts.inter(fontSize: 12, ...),
        maxLines: 1,                  // ← giới hạn 1 dòng
        overflow: TextOverflow.ellipsis, // ← cắt và thêm "..."
      ),
    ],
  ),
),
```

- `categoryName`: không có `maxLines` → nếu dài sẽ **xuống dòng** trong `Expanded`
- `note`: có `maxLines: 1` + `overflow: TextOverflow.ellipsis` → bị cắt thành "..."

`Expanded` quan trọng: nó giúp Column giữa không lấn sang cột số tiền bên phải.

---

## Trường hợp 2: `{...}` = Số tiền trong **AddTransactionScreen** (TextField số tiền)

**Thầy hỏi:** Nếu user nhập số tiền cực lớn ví dụ 999.999.999.999đ, TextField số tiền trong `AddTransactionScreen` có bị tràn ra ngoài màn hình không?

**Trả lời:**
**KHÔNG bị tràn** vì `TextField` nằm trong `Column` có `CrossAxisAlignment.start` và không có ràng buộc cứng về chiều rộng. Text sẽ **tự co chữ** hoặc xuống dòng.

Tuy nhiên, style của TextField có `fontSize: 32`:
```dart
// add_transaction_screen.dart dòng ~227
TextField(
  controller: _amountController,
  style: GoogleFonts.inter(
    fontSize: 32,          // chữ to
    fontWeight: FontWeight.bold,
    color: ...,
  ),
  decoration: InputDecoration(
    hintText: '0',
    suffixText: 'đ',       // ký hiệu đơn vị
    border: InputBorder.none,
  ),
),
```

Nếu số dài, chữ sẽ **wrap xuống dòng** (không tràn ngang). Để ngăn xuống dòng phải thêm `maxLines: 1` + dùng `AutoSizeText` hoặc giới hạn ký tự.

Hàm `_formatAmount()` cũng giới hạn input chỉ nhận số:
```dart
String text = _amountController.text.replaceAll(RegExp(r'[^0-9]'), '');
```

---

## Trường hợp 3: `{...}` = Tên danh mục trong **CategoryBottomSheet** (GridView)

**Thầy hỏi:** Nếu tên danh mục dài như "Học phí đại học năm 2", ô icon trong `CategoryBottomSheet` có bị vỡ layout không?

**Trả lời:**
**KHÔNG bị vỡ** vì có `maxLines: 1` và `overflow: TextOverflow.ellipsis`:

```dart
// category_bottom_sheet.dart dòng ~90-99
Text(
  cat.name,
  style: GoogleFonts.inter(fontSize: 11, ...),
  textAlign: TextAlign.center,
  maxLines: 1,                          // ← giới hạn 1 dòng
  overflow: TextOverflow.ellipsis,     // ← hiện "..."
),
```

Layout mỗi ô trong GridView:
- `Container` hình tròn 50x50 (cố định) → icon không bị ảnh hưởng
- `SizedBox(height: 8)` khoảng cách
- `Text` → bị cắt nếu dài

`childAspectRatio: 0.8` trong `SliverGridDelegateWithFixedCrossAxisCount` đảm bảo mỗi ô có chiều cao nhất định để chứa cả icon lẫn text.

---

## Trường hợp 4: `{...}` = Tên người dùng trong **DashboardScreen** (AppBar)

**Thầy hỏi:** Nếu tên người dùng quá dài như "Nguyễn Văn Đức Trung Kiên", phần AppBar trong Dashboard có bị tràn sang icon thông báo không?

**Trả lời:**
**KHÔNG bị tràn** vì tên được bọc trong `Column` nằm trong `Row`, và có `Spacer()` giữa tên và icon:

```dart
// dashboard_screen.dart dòng ~202-286
Row(
  children: [
    CircleAvatar(...),           // avatar
    SizedBox(width: 12),
    Column(                      // Tên người dùng - KHÔNG có Expanded
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Xin chào,', ...),
        Text(fullName, ...),     // tên dài sẽ overflow vào Spacer
      ],
    ),
    Spacer(),                    // ← đẩy icon sang phải
    Consumer<SyncProvider>(...), // icon sync
    GestureDetector(...)         // icon chuông
  ],
)
```

**Vấn đề tiềm ẩn:** Tên dài có thể đẩy vào vùng `Spacer` và chồng lên icon. Giải pháp đúng nên dùng `Flexible` cho Column chứa tên:

```dart
// Nên sửa thành:
Flexible(
  child: Column(
    children: [
      Text('Xin chào,', ...),
      Text(fullName, maxLines: 1, overflow: TextOverflow.ellipsis, ...),
    ],
  ),
),
```

---

## Trường hợp 5: `{...}` = Ghi chú (note) trong **DashboardScreen** – Recent Transactions

**Thầy hỏi:** Nếu ghi chú của giao dịch rất dài, phần "Chi tiêu gần đây" trong Dashboard có bị vỡ layout không?

**Trả lời:**
**KHÔNG bị vỡ** vì ghi chú được bọc `Expanded` + `maxLines` + `overflow`:

```dart
// dashboard_screen.dart dòng ~718-719
Text(
  subtitle,      // note hoặc walletName
  style: GoogleFonts.inter(fontSize: 12, ...),
  maxLines: 1,
  overflow: TextOverflow.ellipsis,  // ← cắt thành "..."
),
```

Và widget `_buildTransactionItem()` dùng `Expanded` bọc cột giữa:
```dart
Expanded(
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, ...),
      Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis, ...),
    ],
  ),
),
```

---

## Trường hợp 6: `{...}` = Tên danh mục trong **AddCategoryScreen** (TextField)

**Thầy hỏi:** User nhập tên danh mục rất dài "Học phí đại học năm thứ 3 học kỳ 2 năm 2025", TextField trong `AddCategoryScreen` có xử lý tốt không?

**Trả lời:**
`TextField` có thể nhận text dài vô hạn mà không bị overflow vì mặc định `maxLines: null` (single line nhưng cuộn ngang):

```dart
// add_category_screen.dart dòng ~103-113
TextField(
  controller: _nameController,
  decoration: InputDecoration(
    hintText: 'VD: Lương, Ăn uống, Tiền nhà...',
    filled: true,
    fillColor: ...,
    border: OutlineInputBorder(...),
  ),
  style: GoogleFonts.inter(...),
  // Không có maxLines → single line, scroll ngang trong ô
),
```

Người dùng có thể cuộn ngang trong ô để xem text dài. Tuy nhiên, nếu muốn giới hạn có thể thêm `maxLength: 50`.

---

## Trường hợp 7: `{...}` = Số tiền định dạng trong **TransactionScreen** (amountStr)

**Thầy hỏi:** Số tiền được format như `+1.234.567.890đ` trong `TransactionScreen`, nếu số rất lớn thì cột số tiền có đẩy cột tên danh mục không?

**Trả lời:**
**CÓ thể bị đẩy** nếu không có xử lý. Cột số tiền KHÔNG có `Expanded`, nên nó sẽ chiếm đúng bằng nội dung:

```dart
// transaction_screen.dart dòng ~92-98
Column(                           // CỘT SỐ TIỀN – không có Expanded
  crossAxisAlignment: CrossAxisAlignment.end,
  children: [
    Text('${isIncome ? '+' : '-'}$amountStr', ...),
    Text(DateFormat('dd/MM').format(transaction.transactionDate), ...),
  ],
),
```

Cột giữa (tên + note) dùng `Expanded`:
```dart
Expanded(                         // CO LẠI khi cột tiền chiếm chỗ
  child: Column(
    children: [...],
  ),
),
```

`Expanded` co lại để nhường chỗ cho cột tiền. Nhờ đó layout không vỡ nhưng tên danh mục sẽ bị ngắn đi.

---

## Trường hợp 8: `{...}` = Tên danh mục trong **Donut Chart Legend** (Dashboard)

**Thầy hỏi:** Tên danh mục trong chú thích biểu đồ tròn (legend) nếu dài có bị vỡ không?

**Trả lời:**
**KHÔNG vỡ** vì dùng `Expanded` + `overflow`:

```dart
// dashboard_screen.dart dòng ~593-596
Row(
  children: [
    Container(width: 8, height: 8, ...),   // chấm màu
    SizedBox(width: 4),
    Expanded(                              // co lại để không tràn
      child: Text(
        title,
        style: GoogleFonts.inter(fontSize: 9, ...),
        overflow: TextOverflow.ellipsis,   // ← thêm "..."
      ),
    ),
    Text(percent, ...),                    // phần trăm (cố định)
  ],
)
```

Font size 9 rất nhỏ nên thường đủ chỗ, nhưng `Expanded` + `ellipsis` là safety net.

---

## Trường hợp 9: `{...}` = Tiêu đề "Phân tích chi tiêu" trong **Donut Chart Card**

**Thầy hỏi:** Nếu title card "Phân tích chi tiêu" bị dịch sang ngôn ngữ khác với text dài hơn, có bị tràn không?

**Trả lời:**
**KHÔNG tràn** vì title dùng `Expanded` với `overflow: ellipsis`:

```dart
// dashboard_screen.dart dòng ~495-501
Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [
    Expanded(                        // ← chiếm phần còn lại
      child: Text(
        'Phân tích chi tiêu',
        style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold, ...),
        overflow: TextOverflow.ellipsis,  // ← bị cắt nếu quá dài
      ),
    ),
    SizedBox(width: 8),
    Row(
      mainAxisSize: MainAxisSize.min,   // ← chiếm tối thiểu
      children: [
        Text('Tháng này', ...),
        Icon(Icons.keyboard_arrow_down, ...),
      ],
    )
  ],
)
```

`Expanded` giúp title co lại nhường chỗ cho phần "Tháng này" bên phải.

---

## Trường hợp 10: `{...}` = Tên progress bar trong **_buildProgressBar()** (Dashboard)

**Thầy hỏi:** Trong `_buildProgressBar()`, nếu tên danh mục dài thì label tên có bị vỡ layout không?

**Trả lời:**
**KHÔNG** vì có `overflow: TextOverflow.ellipsis`:

```dart
// dashboard_screen.dart dòng ~606
Text(
  title,       // tên danh mục
  style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: color),
  overflow: TextOverflow.ellipsis,  // ← cắt bằng "..."
),
```

Và phần progress bar row:
```dart
Row(
  children: [
    Expanded(                 // ← bar chiếm hết chỗ còn lại
      child: ClipRRect(
        child: LinearProgressIndicator(...),
      ),
    ),
    SizedBox(width: 8),
    Text('${(percent * 100).toInt()}%', ...),  // % cố định
  ],
)
```

`Expanded` trên `LinearProgressIndicator` đảm bảo bar không tràn sang số %.
