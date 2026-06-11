import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/transaction_provider.dart';
import '../models/transaction_model.dart';
import 'package:intl/intl.dart';

class TransactionScreen extends StatefulWidget {
  const TransactionScreen({super.key});

  @override
  State<TransactionScreen> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TransactionProvider>().loadTransactions();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF1F2937) : const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: Text('Giao dịch', style: GoogleFonts.poppins(color: isDark ? Colors.white : const Color(0xFF111827), fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: isDark ? const Color(0xFF111827) : Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Consumer<TransactionProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.transactions.isEmpty) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF2563EB)));
          }

          if (provider.error != null && provider.transactions.isEmpty) {
            return Center(child: Text(provider.error!, style: GoogleFonts.poppins(color: Colors.red)));
          }

          if (provider.transactions.isEmpty) {
            return Center(child: Text('Chưa có giao dịch nào', style: GoogleFonts.poppins(color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280))));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.transactions.length,
            itemBuilder: (context, index) {
              final transaction = provider.transactions[index];
              final isIncome = transaction.type == 1;
              final amountStr = NumberFormat.currency(locale: 'vi', symbol: 'đ').format(transaction.amount);

              return Container(
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
                          Text(transaction.categoryName.isNotEmpty ? transaction.categoryName : 'Chưa phân loại', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: isDark ? Colors.white : const Color(0xFF111827))),
                          Text(transaction.note ?? '', style: GoogleFonts.poppins(fontSize: 12, color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280)), maxLines: 1, overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('${isIncome ? '+' : '-'}$amountStr', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: isIncome ? const Color(0xFF10B981) : const Color(0xFFEF4444))),
                        Text(DateFormat('dd/MM').format(transaction.transactionDate), style: GoogleFonts.poppins(fontSize: 12, color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280))),
                      ],
                    )
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
