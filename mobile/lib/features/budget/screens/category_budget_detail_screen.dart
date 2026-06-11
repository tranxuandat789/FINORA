import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/category_budget_progress_model.dart';
import '../providers/budget_provider.dart';
import '../../transaction/providers/transaction_provider.dart';
import '../../transaction/providers/category_provider.dart';
import 'package:intl/intl.dart';
import 'package:mobile/core/utils/snackbar_utils.dart';

class CategoryBudgetDetailScreen extends StatefulWidget {
  final CategoryBudgetProgressModel category;
  final int month;
  final int year;

  const CategoryBudgetDetailScreen({
    super.key,
    required this.category,
    required this.month,
    required this.year,
  });

  @override
  State<CategoryBudgetDetailScreen> createState() => _CategoryBudgetDetailScreenState();
}

class _CategoryBudgetDetailScreenState extends State<CategoryBudgetDetailScreen> {
  final _budgetController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _budgetController.text = widget.category.budgetAmount > 0 
        ? widget.category.budgetAmount.toInt().toString() 
        : '';
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TransactionProvider>().loadTransactions();
    });
  }

  String _formatMoney(double amount) {
    final str = amount.toInt().toString();
    final result = StringBuffer();
    int count = 0;
    for (int i = str.length - 1; i >= 0; i--) {
      if (count > 0 && count % 3 == 0) result.write('.');
      result.write(str[i]);
      count++;
    }
    return '${result.toString().split('').reversed.join('')}đ';
  }

  IconData _getIconData(String? iconName) {
    const iconMap = {
      'category': Icons.category,
      'restaurant': Icons.restaurant,
      'shopping_cart': Icons.shopping_cart,
      'home': Icons.home,
      'directions_car': Icons.directions_car,
      'local_hospital': Icons.local_hospital,
      'school': Icons.school,
      'card_giftcard': Icons.card_giftcard,
      'monetization_on': Icons.monetization_on,
      'work': Icons.work,
      'account_balance': Icons.account_balance,
      'sports_esports': Icons.sports_esports,
      'flight': Icons.flight,
      'pets': Icons.pets,
    };
    return iconMap[iconName] ?? Icons.category;
  }

  void _showEditBudgetSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) {
          return Container(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Sửa ngân sách', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF111827))),
                      IconButton(
                        icon: const Icon(Icons.close, color: Color(0xFF6B7280)),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text('Nhập số tiền ngân sách tối đa', style: GoogleFonts.poppins(color: const Color(0xFF6B7280), fontSize: 14)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _budgetController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: 'VD: 5000000',
                      hintStyle: GoogleFonts.poppins(color: const Color(0xFF9CA3AF)),
                      filled: true,
                      fillColor: const Color(0xFFF3F4F6),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      suffixText: 'đ',
                      suffixStyle: GoogleFonts.poppins(color: const Color(0xFF111827), fontWeight: FontWeight.bold),
                    ),
                    style: GoogleFonts.poppins(color: const Color(0xFF111827), fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : () async {
                        final val = double.tryParse(_budgetController.text.replaceAll(RegExp(r'[^0-9]'), ''));
                        if (val == null || val <= 0) {
                          SnackBarUtils.showTopSnackBar(
                            context,
                            'Số tiền không hợp lệ',
                            isSuccess: false,
                          );
                          return;
                        }

                        setSheetState(() => _isLoading = true);
                        try {
                          await context.read<BudgetProvider>().upsertCategoryBudget(widget.category.categoryId, val);
                          if (mounted) {
                            Navigator.pop(context);
                            SnackBarUtils.showTopSnackBar(
                              context,
                              'Đã cập nhật ngân sách',
                              isSuccess: true,
                            );
                            Navigator.pop(context); // Go back to budget list to refresh
                          }
                        } catch (e) {
                          if (mounted) {
                            SnackBarUtils.showTopSnackBar(
                              context,
                              e.toString(),
                              isSuccess: false,
                            );
                          }
                        } finally {
                          if (mounted) setSheetState(() => _isLoading = false);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF246BFD),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: _isLoading 
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text('Lưu thay đổi', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
      ),
    );
  }

  void _deleteCategory() async {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Xóa danh mục', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: Text('Bạn có chắc chắn muốn xóa danh mục này? Mọi ngân sách liên quan sẽ bị xóa.', style: GoogleFonts.poppins()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Hủy', style: GoogleFonts.poppins(color: const Color(0xFF6B7280))),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              setState(() => _isLoading = true);
              try {
                await context.read<CategoryProvider>().deleteCategory(widget.category.categoryId);
                if (mounted) {
                  SnackBarUtils.showTopSnackBar(
                    context,
                    'Đã xóa danh mục',
                    isSuccess: true,
                  );
                  await context.read<BudgetProvider>().loadMonthlyProgress(month: widget.month, year: widget.year);
                  Navigator.pop(context); // return to previous screen
                }
              } catch (e) {
                if (mounted) {
                  SnackBarUtils.showTopSnackBar(
                    context,
                    'Không thể xóa: $e',
                    isSuccess: false,
                  );
                }
              } finally {
                if (mounted) setState(() => _isLoading = false);
              }
            },
            child: Text('Xóa', style: GoogleFonts.poppins(color: const Color(0xFFEF4444), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: Text('Chi tiết danh mục', style: GoogleFonts.poppins(color: const Color(0xFF111827), fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF111827)),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Color(0xFFEF4444)),
            onPressed: _deleteCategory,
          ),
        ],
      ),
      body: Consumer<TransactionProvider>(
        builder: (context, txProvider, _) {
          // Filter transactions for this category and this month
          final transactions = txProvider.transactions.where((t) {
            final date = t.transactionDate;
            return t.categoryId == widget.category.categoryId && 
                   date.month == widget.month && 
                   date.year == widget.year &&
                   t.type == 2; // Chi tiêu
          }).toList();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category info card
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 4)),
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: const Color(0xFF246BFD).withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(_getIconData(widget.category.icon), color: const Color(0xFF246BFD), size: 32),
                      ),
                      const SizedBox(height: 16),
                      Text(widget.category.categoryName, style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: const Color(0xFF111827))),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Đã chi', style: GoogleFonts.poppins(color: const Color(0xFF6B7280), fontSize: 12)),
                              const SizedBox(height: 4),
                              Text(_formatMoney(widget.category.spentAmount), style: GoogleFonts.poppins(color: const Color(0xFFEF4444), fontSize: 16, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text('Ngân sách', style: GoogleFonts.poppins(color: const Color(0xFF6B7280), fontSize: 12)),
                              const SizedBox(height: 4),
                              Text(_formatMoney(widget.category.budgetAmount), style: GoogleFonts.poppins(color: const Color(0xFF111827), fontSize: 16, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: OutlinedButton.icon(
                          onPressed: _showEditBudgetSheet,
                          icon: const Icon(Icons.edit, size: 18),
                          label: Text('Sửa ngân sách', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF246BFD),
                            side: const BorderSide(color: Color(0xFF246BFD)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                Text('Giao dịch tháng ${widget.month}', style: GoogleFonts.poppins(color: const Color(0xFF111827), fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),

                if (transactions.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 24),
                      child: Text('Chưa có giao dịch nào', style: GoogleFonts.poppins(color: const Color(0xFF6B7280))),
                    ),
                  )
                else
                  ...transactions.map((tx) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF3F4F6),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.receipt_long, color: Color(0xFF6B7280), size: 20),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text((tx.note?.isNotEmpty ?? false) ? tx.note! : tx.categoryName, style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14)),
                                const SizedBox(height: 4),
                                Text(DateFormat('dd/MM/yyyy HH:mm').format(tx.transactionDate), style: GoogleFonts.poppins(color: const Color(0xFF6B7280), fontSize: 12)),
                              ],
                            ),
                          ),
                          Text('-${_formatMoney(tx.amount)}', style: GoogleFonts.poppins(color: const Color(0xFFEF4444), fontWeight: FontWeight.bold)),
                        ],
                      ),
                    );
                  }).toList(),
              ],
            ),
          );
        },
      ),
    );
  }
}
