import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/budget_provider.dart';
import '../models/category_budget_progress_model.dart';
import 'category_budget_detail_screen.dart';
import '../../transaction/screens/add_category_screen.dart';

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BudgetProvider>().loadMonthlyProgress();
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

  Color _getCategoryColor(int index) {
    const colors = [
      Color(0xFF246BFD), // primary
      Color(0xFF10B981), // success
      Color(0xFF8B5CF6), // purple
      Color(0xFF60A5FA), // blue-light
      Color(0xFFF59E0B), // warning
    ];
    return colors[index % colors.length];
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: Text('Ngân sách', style: GoogleFonts.poppins(color: const Color(0xFF111827), fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF111827)),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Color(0xFF111827)),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddCategoryScreen(type: 2)),
              );
              if (context.mounted) {
                context.read<BudgetProvider>().loadMonthlyProgress();
              }
            },
          ),
        ],
      ),
      body: Consumer<BudgetProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF246BFD)));
          }

          if (provider.error != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red, size: 48),
                    const SizedBox(height: 16),
                    Text(provider.error!, style: GoogleFonts.poppins(color: const Color(0xFFEF4444)), textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => context.read<BudgetProvider>().loadMonthlyProgress(),
                      child: const Text('Thử lại'),
                    )
                  ],
                ),
              ),
            );
          }

          final progress = provider.progress;
          if (progress == null) {
            return Center(child: Text('Không có dữ liệu', style: GoogleFonts.poppins(color: const Color(0xFF6B7280))));
          }

          final totalPercentage = progress.totalBudget > 0 ? (progress.totalSpent / progress.totalBudget) : 0.0;
          final safePercentage = totalPercentage > 1.0 ? 1.0 : totalPercentage;

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hero Card
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A2E), // Dark card as per user screenshot
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 8)),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Tháng này', style: GoogleFonts.poppins(color: Colors.white70, fontSize: 13)),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text('Tháng ${progress.month}/${progress.year}', style: GoogleFonts.poppins(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(_formatMoney(progress.totalSpent), style: GoogleFonts.poppins(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text('/ ${_formatMoney(progress.totalBudget)} ngân sách', style: GoogleFonts.poppins(color: Colors.white70, fontSize: 13)),
                      const SizedBox(height: 24),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: safePercentage,
                          backgroundColor: Colors.white.withOpacity(0.2),
                          valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF246BFD)),
                          minHeight: 8,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Đã chi: ${(totalPercentage * 100).toStringAsFixed(0)}%', style: GoogleFonts.poppins(color: const Color(0xFF10B981), fontSize: 12, fontWeight: FontWeight.w600)),
                          Text('Còn lại: ${_formatMoney(progress.totalBudget - progress.totalSpent > 0 ? progress.totalBudget - progress.totalSpent : 0)}', style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                Text('Ngân sách theo danh mục', style: GoogleFonts.poppins(color: const Color(0xFF111827), fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                
                ...progress.categories.asMap().entries.map((entry) {
                  final index = entry.key;
                  final cat = entry.value;
                  final color = _getCategoryColor(index);
                  final catPercentage = cat.budgetAmount > 0 ? (cat.spentAmount / cat.budgetAmount) : 0.0;
                  final safeCatPercentage = catPercentage > 1.0 ? 1.0 : catPercentage;

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CategoryBudgetDetailScreen(
                            category: cat,
                            month: progress.month,
                            year: progress.year,
                          ),
                        ),
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 2)),
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: color.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(_getIconData(cat.icon), color: color, size: 24),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(cat.categoryName, style: GoogleFonts.poppins(color: const Color(0xFF111827), fontSize: 14, fontWeight: FontWeight.w600)),
                                    const SizedBox(height: 2),
                                    Text('${_formatMoney(cat.spentAmount)} / ${_formatMoney(cat.budgetAmount)}', style: GoogleFonts.poppins(color: const Color(0xFF6B7280), fontSize: 12)),
                                  ],
                                ),
                              ),
                              Text('${(catPercentage * 100).toStringAsFixed(0)}%', style: GoogleFonts.poppins(color: const Color(0xFF246BFD), fontSize: 14, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: safeCatPercentage,
                              backgroundColor: const Color(0xFFF3F4F6),
                              valueColor: AlwaysStoppedAnimation<Color>(color),
                              minHeight: 6,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }
}
