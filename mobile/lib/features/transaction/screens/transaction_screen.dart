import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/theme_provider.dart';
import '../providers/transaction_provider.dart';
import '../models/transaction_model.dart';
import 'package:intl/intl.dart';

class TransactionScreen extends StatefulWidget {
  const TransactionScreen({super.key});

  @override
  State<TransactionScreen> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TransactionProvider>().loadTransactions();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final providerQuery = context.watch<TransactionProvider>().searchQuery;
    if (_searchController.text != providerQuery) {
      _searchController.text = providerQuery;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDarkMode;
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF1F2937) : const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: Text('Giao dịch', style: GoogleFonts.inter(color: isDark ? Colors.white : const Color(0xFF111827), fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: isDark ? const Color(0xFF111827) : Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) => context.read<TransactionProvider>().setSearchQuery(value),
                    decoration: InputDecoration(
                      hintText: 'Tìm kiếm giao dịch...',
                      hintStyle: GoogleFonts.inter(color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF9CA3AF)),
                      prefixIcon: Icon(Icons.search, color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280)),
                      filled: true,
                      fillColor: isDark ? const Color(0xFF374151) : Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    ),
                    style: GoogleFonts.inter(color: isDark ? Colors.white : Colors.black),
                  ),
                ),
                const SizedBox(width: 12),
                InkWell(
                  onTap: () async {
                    final provider = context.read<TransactionProvider>();
                    final picked = await showDateRangePicker(
                      context: context,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2101),
                      initialDateRange: provider.startDate != null && provider.endDate != null 
                          ? DateTimeRange(start: provider.startDate!, end: provider.endDate!)
                          : null,
                      builder: (context, child) {
                        return Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: isDark 
                              ? const ColorScheme.dark(primary: Color(0xFF2563EB))
                              : const ColorScheme.light(primary: Color(0xFF2563EB)),
                          ),
                          child: child!,
                        );
                      },
                    );
                    if (picked != null) {
                      provider.setDateRange(picked.start, picked.end);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF374151) : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.filter_list, color: isDark ? Colors.white : const Color(0xFF4B5563)),
                  ),
                ),
                Consumer<TransactionProvider>(
                  builder: (context, prov, child) {
                    if (prov.startDate != null) {
                      return Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: InkWell(
                          onTap: () => prov.setDateRange(null, null),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.clear, color: Colors.red),
                          ),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  }
                ),
              ],
            ),
          ),
          Expanded(
            child: Consumer<TransactionProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading && provider.transactions.isEmpty) {
                  return const Center(child: CircularProgressIndicator(color: Color(0xFF2563EB)));
                }

                if (provider.error != null && provider.transactions.isEmpty) {
                  return Center(child: Text(provider.error!, style: GoogleFonts.inter(color: Colors.red)));
                }

                if (provider.filteredTransactions.isEmpty) {
                  return Center(child: Text('Không tìm thấy giao dịch nào', style: GoogleFonts.inter(color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280))));
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: provider.filteredTransactions.length,
                  itemBuilder: (context, index) {
                    final transaction = provider.filteredTransactions[index];
                    final isIncome = transaction.type == 1;
                    final amountStr = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ', decimalDigits: 0).format(transaction.amount);

                    return GestureDetector(
                      onTap: () => _showTransactionDetail(context, transaction, isDark),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF111827) : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))
                          ],
                        ),
                        child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: isIncome ? const Color(0xFFD1FAE5) : const Color(0xFFFEE2E2),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              isIncome ? Icons.arrow_downward : Icons.arrow_upward,
                              color: isIncome ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(transaction.categoryName.isNotEmpty ? transaction.categoryName : 'Chưa phân loại', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: isDark ? Colors.white : const Color(0xFF111827))),
                                Text(transaction.note ?? '', style: GoogleFonts.inter(fontSize: 12, color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280)), maxLines: 1, overflow: TextOverflow.ellipsis),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text('${isIncome ? '+' : '-'}$amountStr', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: isIncome ? const Color(0xFF10B981) : const Color(0xFFEF4444))),
                              Text(DateFormat('HH:mm - dd/MM/yyyy').format(transaction.transactionDate), style: GoogleFonts.inter(fontSize: 12, color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280))),
                            ],
                          )
                        ],
                      ),
                    ));
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showTransactionDetail(BuildContext context, TransactionModel transaction, bool isDark) {
    final isIncome = transaction.type == 1;
    final amountStr = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ', decimalDigits: 0).format(transaction.amount);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1F2937) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 48,
                height: 4,
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: isIncome ? const Color(0xFFD1FAE5) : const Color(0xFFFEE2E2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isIncome ? Icons.arrow_downward : Icons.arrow_upward,
                  color: isIncome ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                  size: 32,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '${isIncome ? '+' : '-'}$amountStr',
                style: GoogleFonts.inter(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: isIncome ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                transaction.categoryName.isNotEmpty ? transaction.categoryName : 'Chưa phân loại',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : const Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 24),
              _buildDetailRow('Ngày', DateFormat('HH:mm - dd/MM/yyyy').format(transaction.transactionDate), isDark),
              _buildDetailRow('Ghi chú', transaction.note?.isNotEmpty == true ? transaction.note! : 'Không có ghi chú', isDark),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text('Đóng', style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: GoogleFonts.inter(fontSize: 14, color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280))),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: isDark ? Colors.white : const Color(0xFF111827)),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
