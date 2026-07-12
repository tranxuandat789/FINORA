# BASIC Q2 – Tối ưu Layout (ListView.builder)
> **Câu hỏi gốc:** Tại sao lại sử dụng `ListView.builder` (hoặc `Column`) thông thường? Thuộc tính `itemBuilder` hoạt động ra sao? *(Áp dụng cho màn hình `{...}`)*

---

## Trường hợp 1: `{...}` = **TransactionScreen** (Danh sách giao dịch)

**Thầy hỏi:** Tại sao `TransactionScreen` dùng `ListView.builder` thay vì `ListView` thông thường hay `Column`? `itemBuilder` hoạt động ra sao?

**Trả lời:**
`ListView.builder` được dùng vì danh sách giao dịch **không biết trước số lượng** – có thể là 0, 10, hay hàng trăm giao dịch. 

Với `ListView` thông thường hoặc `Column`, **tất cả item đều được build ngay lập tức** khi màn hình render, gây tốn RAM/CPU dù user chưa scroll đến.

`ListView.builder` chỉ build item **khi chúng chuẩn bị xuất hiện trên màn hình** (lazy loading), nên rất hiệu quả:

```dart
// transaction_screen.dart dòng ~50
return ListView.builder(
  padding: const EdgeInsets.all(16),
  itemCount: provider.transactions.length,   // tổng số item
  itemBuilder: (context, index) {            // chỉ gọi khi item sắp hiện
    final transaction = provider.transactions[index];
    // Build card cho từng giao dịch
    return Container( ... );
  },
);
```

`itemBuilder` là một **callback function** nhận vào `(BuildContext context, int index)` và trả về Widget. Flutter chỉ gọi hàm này cho các index đang nằm trong **viewport + buffer nhỏ**, không gọi hết tất cả.

---

## Trường hợp 2: `{...}` = **CategoryBottomSheet** (Chọn danh mục – dùng GridView)

**Thầy hỏi:** Tại sao `CategoryBottomSheet` dùng `GridView.builder` thay vì tạo thủ công từng ô danh mục bằng `Wrap` hay `Column`? `itemBuilder` ở đây hoạt động thế nào?

**Trả lời:**
`GridView.builder` giải quyết 2 vấn đề:
1. **Số lượng danh mục biến động** – user có thể thêm nhiều danh mục
2. **Tự động tính layout lưới** – không cần tính toán thủ công hàng/cột

```dart
// category_bottom_sheet.dart dòng ~58
GridView.builder(
  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 4,      // 4 cột cố định
    mainAxisSpacing: 20,
    crossAxisSpacing: 20,
    childAspectRatio: 0.8,
  ),
  itemCount: filteredCategories.length + 1, // +1 cho nút "Thêm mới"
  itemBuilder: (context, index) {
    if (index == filteredCategories.length) {
      return _buildAddCategoryButton(context, isDark); // ô cuối = "Thêm mới"
    }
    final cat = filteredCategories[index];
    return InkWell( ... ); // các ô danh mục
  },
)
```

`itemBuilder` đặc biệt ở chỗ: **index cuối cùng** (`filteredCategories.length`) được dùng để render nút "Thêm mới" – một trick phổ biến để ghép item đặc biệt vào cuối lưới.

---

## Trường hợp 3: `{...}` = **AddCategoryScreen** (Icon picker – dùng GridView)

**Thầy hỏi:** Tại sao phần chọn icon trong `AddCategoryScreen` dùng `GridView.builder` với `shrinkWrap: true` và `NeverScrollableScrollPhysics`? Tác dụng của 2 thuộc tính đó là gì?

**Trả lời:**
Vì `AddCategoryScreen` dùng `SingleChildScrollView` bên ngoài, **không thể lồng 2 widget có scroll** cùng chiều. Nếu dùng `GridView` bình thường sẽ conflict scroll và throw error.

Giải pháp:
```dart
// add_category_screen.dart dòng ~134
GridView.builder(
  shrinkWrap: true,          // co lại đúng bằng chiều cao content thực tế
  physics: const NeverScrollableScrollPhysics(), // tắt scroll của GridView
  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 5,       // 5 cột
    mainAxisSpacing: 16,
    crossAxisSpacing: 16,
  ),
  itemCount: _availableIcons.length, // 14 icon
  itemBuilder: (context, index) {
    final iconData = _availableIcons[index];
    final isSelected = _selectedIcon == iconData['name'];
    return InkWell(
      onTap: () => setState(() => _selectedIcon = iconData['name']),
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF2563EB) : ...,
          shape: BoxShape.circle,
        ),
        child: Icon(iconData['icon'], ...),
      ),
    );
  },
)
```

- `shrinkWrap: true` → Grid không cố định chiều cao, tự co theo số item
- `NeverScrollableScrollPhysics` → scroll do `SingleChildScrollView` ngoài xử lý

---

## Trường hợp 4: `{...}` = **DashboardScreen – _buildRecentTransactions()** (Giao dịch gần đây)

**Thầy hỏi:** Tại sao phần "Chi tiêu gần đây" trong Dashboard KHÔNG dùng `ListView.builder` mà lại dùng cách khác? Sự khác biệt là gì?

**Trả lời:**
Trong `_buildRecentTransactions()`, dữ liệu được render bằng **`.map().toList()`** thay vì `ListView.builder`:

```dart
// dashboard_screen.dart dòng ~657
...data.recentTransactions.asMap().entries.map((entry) {
  final index = entry.key;
  final t = entry.value;
  return Column(children: [
    _buildTransactionItem(...),
    if (!isLast) _buildTransactionDivider(isDark),
  ]);
}).toList()
```

**Tại sao không dùng ListView.builder?**
Vì `_buildRecentTransactions()` nằm bên trong `SingleChildScrollView` + `Column`. Không thể dùng `ListView` thêm một lần nữa (conflict scroll). 

Giải pháp này là build **tất cả item ngay lập tức** (eager), không lazy. Điều này chấp nhận được vì "giao dịch gần đây" thường chỉ hiển thị 5–10 item, không phải danh sách dài.

**Khi nào nên dùng `ListView.builder`?**
- Danh sách không biết trước số lượng (vô hạn / nhiều)
- Không nằm trong `ScrollView` khác

---

## Trường hợp 5: `{...}` = **TransactionScreen** – Khi danh sách rỗng

**Thầy hỏi:** Khi `provider.transactions` rỗng, `ListView.builder` có được render không? Code xử lý thế nào?

**Trả lời:**
`ListView.builder` KHÔNG được render vì code có điều kiện kiểm tra trước:

```dart
// transaction_screen.dart dòng ~46
if (provider.transactions.isEmpty) {
  return Center(
    child: Text(
      'Chưa có giao dịch nào',
      style: GoogleFonts.inter(color: isDark ? ... : ...),
    ),
  );
}

// Chỉ đến đây nếu có data
return ListView.builder(
  itemCount: provider.transactions.length,
  itemBuilder: (context, index) { ... },
);
```

Thứ tự kiểm tra trong `Consumer<TransactionProvider>`:
1. `isLoading && transactions.isEmpty` → `CircularProgressIndicator`
2. `error != null && transactions.isEmpty` → Text lỗi màu đỏ
3. `transactions.isEmpty` → Text "Chưa có giao dịch nào"
4. Còn lại → `ListView.builder`

---

## Trường hợp 6: `{...}` = **CategoryBottomSheet** – Lọc theo type

**Thầy hỏi:** Tại sao `itemCount` trong CategoryBottomSheet không dùng `provider.categories.length` trực tiếp mà phải filter trước? Giải thích cách filter hoạt động.

**Trả lời:**
Vì `CategoryProvider` lưu **tất cả danh mục** (cả thu nhập lẫn chi tiêu) trong 1 list. Khi mở BottomSheet, chỉ hiện danh mục đúng loại với loại giao dịch đang chọn.

```dart
// category_bottom_sheet.dart dòng ~56
final filteredCategories = provider.categories
    .where((c) => c.type == widget.selectedType) // lọc đúng loại
    .toList();

return GridView.builder(
  itemCount: filteredCategories.length + 1, // +1 nút "Thêm mới"
  itemBuilder: (context, index) { ... },
)
```

`widget.selectedType` nhận từ `AddTransactionScreen`:
```dart
// add_transaction_screen.dart dòng ~85-90
final selectedCategory = await showModalBottomSheet<CategoryModel>(
  builder: (context) => CategoryBottomSheet(selectedType: _selectedType),
  // _selectedType = 1 (Thu nhập) hoặc 2 (Chi tiêu)
);
```

---

## Trường hợp 7: `{...}` = **DashboardScreen** – Khi `isLoading = true` và đã có cache

**Thầy hỏi:** Khi `DashboardProvider` đang load data (isLoading = true) nhưng đã có data cũ từ lần trước, màn hình Dashboard hiển thị gì? Loading indicator hay data cũ?

**Trả lời:**
Hiển thị **data cũ** vì điều kiện check là `isLoading && data == null`:

```dart
// dashboard_screen.dart dòng ~149
if (dashboardProvider.isLoading && dashboardProvider.data == null) {
  return const Center(child: CircularProgressIndicator(...));
}
```

Chỉ hiện loading khi `data == null` (lần đầu mở app). Nếu đã có `data` từ cache, màn hình vẫn render bình thường, người dùng không thấy màn hình trắng.

Đây là **UX tốt** – không làm người dùng chờ mỗi khi refresh. `RefreshIndicator` ở trên hiện loading bar nhỏ thay thế.

---

## Trường hợp 8: `{...}` = **TransactionScreen** – Hiệu suất với 1000 giao dịch

**Thầy hỏi:** Nếu user có 1000 giao dịch, `ListView.builder` trong `TransactionScreen` có bị lag không? Tại sao?

**Trả lời:**
**KHÔNG bị lag** vì `ListView.builder` lazy:
- Chỉ build ~10-15 widget hiện trong viewport + vài item buffer
- 985 widget còn lại **chưa được tạo ra**
- Khi scroll, item mới được build, item cũ bị hủy và thu hồi bộ nhớ

Ngược lại, nếu dùng `Column` + `children: transactions.map(...).toList()`:
- **1000 widget được build ngay lập tức**
- Tiêu tốn nhiều RAM và thời gian render ban đầu

```dart
// Cách ĐÚNG (đang dùng) - hiệu quả
ListView.builder(
  itemCount: 1000,
  itemBuilder: (context, index) => buildItem(index), // chỉ ~15 lần gọi
)

// Cách SAI - không hiệu quả cho list dài
Column(
  children: List.generate(1000, (i) => buildItem(i)), // gọi 1000 lần ngay lập tức
)
```
