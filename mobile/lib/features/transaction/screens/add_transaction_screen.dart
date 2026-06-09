import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/transaction_provider.dart';
import '../widgets/voice_input_bottom_sheet.dart';
import '../widgets/category_bottom_sheet.dart';
import '../models/category_model.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  int _selectedType = 2; // Default to Expense
  String? _selectedCategoryId; 
  String? _selectedCategoryName;
  String? _selectedWalletId; // Mock wallet id
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    // Default mock data (In real app, fetch wallets and categories)
    _selectedWalletId = '00000000-0000-0000-0000-000000000000'; // Default Empty Guid -> backend will assign to user's first wallet
    _selectedCategoryId = null; 
    _selectedCategoryName = null;
  }

  void _selectCategory() async {
    final selectedCategory = await showModalBottomSheet<CategoryModel>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CategoryBottomSheet(selectedType: _selectedType),
    );

    if (selectedCategory != null) {
      setState(() {
        _selectedCategoryId = selectedCategory.id;
        _selectedCategoryName = selectedCategory.name;
      });
    }
  }

  void _showVoiceInput() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => const VoiceInputBottomSheet(),
    ).then((result) {
      if (result != null && result is Map) {
        setState(() {
          if (result['amount'] != null) {
            _amountController.text = result['amount'].toString();
          }
          if (result['note'] != null) {
            _noteController.text = result['note'];
          }
          if (result['categoryId'] != null) {
            _selectedCategoryId = result['categoryId'];
          }
          if (result['categoryName'] != null) {
            _selectedCategoryName = result['categoryName'];
          }
          if (result['transactionDate'] != null) {
            _selectedDate = result['transactionDate'] as DateTime;
          }
        });
      }
    });
  }

  void _saveTransaction() async {
    final amountText = _amountController.text.replaceAll(RegExp(r'[^0-9.]'), '');
    final amount = double.tryParse(amountText);

    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng nhập số tiền hợp lệ.')));
      return;
    }

    if (_selectedCategoryId == null || _selectedWalletId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng chọn danh mục.')));
      return;
    }

    try {
      final success = await context.read<TransactionProvider>().createTransaction(
        walletId: _selectedWalletId ?? '00000000-0000-0000-0000-000000000000',
        categoryId: _selectedCategoryId ?? '00000000-0000-0000-0000-000000000000',
        type: _selectedType,
        amount: amount,
        note: _noteController.text,
        transactionDate: _selectedDate,
      );

      if (success) {
        if (mounted) Navigator.pop(context);
      } else {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Không thể kết nối. Giao dịch đã được lưu tạm offline.')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Thêm giao dịch', style: GoogleFonts.poppins(color: const Color(0xFF111827), fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.close, color: Color(0xFF111827)), onPressed: () => Navigator.pop(context)),
        actions: [
          IconButton(
            icon: const Icon(Icons.mic, color: Color(0xFF2563EB)),
            onPressed: _showVoiceInput,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => setState(() => _selectedType = 2),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: _selectedType == 2 ? const Color(0xFFEF4444) : const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignment: Alignment.center,
                      child: Text('Tiền chi', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: _selectedType == 2 ? Colors.white : const Color(0xFF6B7280))),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: InkWell(
                    onTap: () => setState(() => _selectedType = 1),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: _selectedType == 1 ? const Color(0xFF10B981) : const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignment: Alignment.center,
                      child: Text('Tiền thu', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: _selectedType == 1 ? Colors.white : const Color(0xFF6B7280))),
                    ),
                  ),
                )
              ],
            ),
            const SizedBox(height: 24),
            Text('Số tiền', style: GoogleFonts.poppins(color: const Color(0xFF6B7280), fontSize: 14)),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              style: GoogleFonts.poppins(fontSize: 32, fontWeight: FontWeight.bold, color: _amountController.text.isEmpty ? const Color(0xFFEF4444) : const Color(0xFF111827)),
              decoration: const InputDecoration(
                hintText: '0 đ',
                border: InputBorder.none,
              ),
            ),
            const Divider(),
            const SizedBox(height: 16),
            _buildField(Icons.category, 'Danh mục', _selectedCategoryName ?? 'Chọn danh mục', _selectCategory),
            const SizedBox(height: 16),
            _buildField(Icons.note, 'Ghi chú', 'Nhập ghi chú', null, child: TextField(
              controller: _noteController,
              decoration: const InputDecoration(border: InputBorder.none, hintText: 'Nhập ghi chú'),
              style: GoogleFonts.poppins(),
            )),
            const SizedBox(height: 16),
            _buildField(Icons.calendar_today, 'Ngày', '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}', () async {
              final picked = await showDatePicker(context: context, initialDate: _selectedDate, firstDate: DateTime(2000), lastDate: DateTime(2101));
              if (picked != null) setState(() => _selectedDate = picked);
            }),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _saveTransaction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Text('Lưu giao dịch', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildField(IconData icon, String label, String value, VoidCallback? onTap, {Widget? child}) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: const Color(0xFF6B7280), size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF6B7280))),
                if (child == null) Text(value, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500, color: const Color(0xFF111827))),
                if (child != null) child,
              ],
            ),
          )
        ],
      ),
    );
  }
}
