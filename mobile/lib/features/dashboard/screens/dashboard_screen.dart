import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:mobile/features/auth/providers/auth_provider.dart';
import 'package:mobile/features/profile/screens/profile_screen.dart';
import 'package:mobile/features/analytics/screens/analytics_screen.dart';
import 'package:mobile/features/goal/screens/saving_goals_screen.dart';
import 'package:mobile/features/budget/screens/budget_screen.dart';
import 'package:mobile/features/transaction/providers/category_provider.dart';
import 'package:mobile/features/transaction/screens/transaction_screen.dart';
import 'package:mobile/features/transaction/screens/add_transaction_screen.dart';
import 'package:mobile/features/transaction/providers/transaction_provider.dart';
import 'package:mobile/features/sync/providers/sync_provider.dart';
import 'package:mobile/features/goal/providers/goal_provider.dart';
import 'package:mobile/features/goal/models/goal_model.dart';
import 'package:mobile/features/goal/screens/goal_detail_screen.dart';
import 'package:mobile/features/goal/widgets/goal_icon_mapper.dart';
import 'dart:math';
import 'package:mobile/features/dashboard/providers/dashboard_provider.dart';
import 'package:mobile/features/dashboard/models/dashboard_model.dart';
import 'package:mobile/features/home/screens/more_menu_screen.dart';
import 'package:mobile/features/notification/screens/notification_screen.dart';
import 'package:mobile/core/utils/snackbar_utils.dart';
import 'package:mobile/features/transaction/widgets/floating_voice_button.dart';
import 'package:mobile/core/providers/theme_provider.dart';
import 'package:mobile/features/profile/screens/account_info_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => DashboardScreenState();
}

class DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  // Called by child widgets to switch bottom nav tabs
  void switchToTab(int index) {
    setState(() => _selectedIndex = index);
  }

  final List<Widget> _pages = [
    const _DashboardTab(),
    const TransactionScreen(),
    const AnalyticsScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardProvider>().loadDashboardData();
      context.read<CategoryProvider>().loadCategories();
      context.read<GoalProvider>().loadGoals();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDarkMode;
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF111827) : const Color(0xFFF9FAFB),
      body: Stack(
        children: [
          _pages[_selectedIndex],
          if (_selectedIndex == 0) const FloatingVoiceButton(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(context, MaterialPageRoute(builder: (_) => const AddTransactionScreen()));
          if (mounted) {
            context.read<DashboardProvider>().loadDashboardData();
          }
        },
        backgroundColor: const Color(0xFF2563EB),
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildBottomNavBar() {
    final isDark = context.watch<ThemeProvider>().isDarkMode;
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 8.0,
      color: isDark ? const Color(0xFF1F2937) : Colors.white,
      elevation: 8,
      child: SizedBox(
        height: 64,
        child: Row(
          children: [
            Expanded(child: _buildBottomNavItem(icon: Icons.home, label: 'Trang chủ', index: 0)),
            Expanded(child: _buildBottomNavItem(icon: Icons.receipt_long, label: 'Giao dịch', index: 1)),
            const SizedBox(width: 72), // Space for FAB  Ecăn giữa chính xác
            Expanded(child: _buildBottomNavItem(icon: Icons.pie_chart, label: 'Phân tích', index: 2)),
            Expanded(child: _buildBottomNavItem(icon: Icons.person, label: 'Cá nhân', index: 3)),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavItem({required IconData icon, required String label, required int index}) {
    final bool isActive = _selectedIndex == index;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: isActive ? const Color(0xFF2563EB) : const Color(0xFF9CA3AF), size: 24),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
              color: isActive ? const Color(0xFF2563EB) : const Color(0xFF9CA3AF),
            ),
          )
        ],
      ),
    );
  }
}

class _DashboardTab extends StatelessWidget {
  const _DashboardTab({super.key});

  final List<Color> _chartColors = const [
    Color(0xFF2563EB), // Xanh dương
    Color(0xFF10B981), // Xanh lá ngọc
    Color(0xFFF59E0B), // Cam/Vàng
    Color(0xFF8B5CF6), // Tím
    Color(0xFFEF4444), // Đỏ
    Color(0xFF06B6D4), // Cyan
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SafeArea(
      child: Consumer<DashboardProvider>(
        builder: (context, dashboardProvider, child) {
          if (dashboardProvider.isLoading && dashboardProvider.data == null) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF2563EB)));
          }

          if (dashboardProvider.error != null && dashboardProvider.data == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 16),
                  Text('Lỗi: ${dashboardProvider.error}', style: GoogleFonts.inter()),
                  TextButton(
                    onPressed: () => context.read<DashboardProvider>().loadDashboardData(),
                    child: Text('Thử lại', style: GoogleFonts.inter(color: const Color(0xFF2563EB))),
                  )
                ],
              ),
            );
          }

          final data = dashboardProvider.data;
          if (data == null) return const SizedBox.shrink();

          return RefreshIndicator(
            onRefresh: () => context.read<DashboardProvider>().loadDashboardData(),
            color: const Color(0xFF2563EB),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildAppBar(context, isDark),
                  _buildBalanceCard(data),
                  _buildActionMenu(isDark),
                  const SizedBox(height: 24),
                  _buildSpendingAnalytics(context, data, isDark),
                  const SizedBox(height: 24),
                  _buildRecentTransactions(data, isDark),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, bool isDark) {
    final authProvider = context.watch<AuthProvider>();
    final String fullName = authProvider.user?['fullName'] ?? 'Người dùng';
    final String? avatarUrl = authProvider.user?['avatarUrl'];

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const AccountInfoScreen()));
            },
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFF2563EB), width: 1.5),
                  ),
                  child: CircleAvatar(
                    radius: 22,
                    backgroundImage: avatarUrl != null && avatarUrl.isNotEmpty
                        ? NetworkImage(avatarUrl) as ImageProvider
                        : const AssetImage('assets/images/logo.png'),
                    backgroundColor: Colors.white,
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Xin chào,', style: GoogleFonts.inter(fontSize: 13, color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280))),
                    Text(fullName, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF111827))),
                  ],
                ),
              ],
            ),
          ),
          const Spacer(),
          Consumer<SyncProvider>(
            builder: (context, syncProvider, child) {
              if (syncProvider.pendingCount == 0 && !syncProvider.isSyncing) {
                return const SizedBox.shrink();
              }
              return GestureDetector(
                onTap: syncProvider.isSyncing 
                    ? null 
                    : () async {
                        final success = await syncProvider.syncNow();
                        if (context.mounted) {
                          SnackBarUtils.showTopSnackBar(context, success ? 'Đồng bộ thành công!' : (syncProvider.error ?? 'Đồng bộ thất bại.'), isSuccess: success);
                          if (success) {
                            context.read<TransactionProvider>().loadTransactions();
                            context.read<DashboardProvider>().loadDashboardData();
                          }
                        }
                      },
                child: Container(
                  margin: const EdgeInsets.only(right: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFFCA5A5)),
                  ),
                  child: Row(
                    children: [
                      syncProvider.isSyncing 
                        ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFEF4444)))
                        : const Icon(Icons.sync_problem, color: Color(0xFFEF4444), size: 16),
                      const SizedBox(width: 6),
                      Text(
                        '${syncProvider.pendingCount}', 
                        style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFFEF4444)),
                      )
                    ],
                  ),
                ),
              );
            },
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationScreen()));
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF374151) : Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: isDark ? const Color(0xFF4B5563) : const Color(0xFFE5E7EB)),
              ),
              child: Icon(Icons.notifications_none, color: isDark ? const Color(0xFFD1D5DB) : const Color(0xFF374151)),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildBalanceCard(DashboardData data) {
    final formatCurrency = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ', decimalDigits: 0);
    final formattedBalance = formatCurrency.format(data.totalBalance);
    
    // Percentage trend logic
    final pctChange = data.balancePercentageChange;
    final isPositive = pctChange >= 0;
    final pctText = pctChange.abs().toStringAsFixed(1) + '%';
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: const Color(0xFF2563EB),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0D6EFD).withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            Positioned.fill(
              child: Transform.scale(
                scale: 1.05,
                child: Image.asset(
                  'assets/images/Dashboard1.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Tổng số dư', style: GoogleFonts.inter(color: Colors.white.withValues(alpha: 0.9), fontSize: 14)),
                  const SizedBox(height: 8),
                  Text(formattedBalance, style: GoogleFonts.inter(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Icon(isPositive ? Icons.arrow_upward : Icons.arrow_downward, 
                           color: isPositive ? const Color(0xFF34D399) : const Color(0xFFFCA5A5), size: 16),
                      const SizedBox(width: 4),
                      Text(pctText, style: GoogleFonts.inter(color: isPositive ? const Color(0xFF34D399) : const Color(0xFFFCA5A5), fontSize: 12, fontWeight: FontWeight.w600)),
                      Text(' so với tháng trước', style: GoogleFonts.inter(color: Colors.white.withValues(alpha: 0.9), fontSize: 12)),
                    ],
                  )
                ],
              ),
            ),
            Positioned(
              right: 20,
              top: 0,
              bottom: 0,
              child: Center(
                child: Image.asset(
                  'assets/images/DashboardIcon.png', 
                  width: 110, 
                  height: 110,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionMenu(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 22.0, horizontal: 8.0),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1F2937) : Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Builder(
          builder: (context) => Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildActionItem(Icons.track_changes, 'Mục tiêu', const Color(0xFF8B5CF6), Colors.white, isDark, onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const SavingGoalsScreen()));
              }),
              _buildActionItem(Icons.account_balance_wallet, 'Ngân sách', const Color(0xFF3B82F6), Colors.white, isDark, onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const BudgetScreen()));
              }),
              _buildActionItem(Icons.receipt_long, 'Ghi chi tiêu', const Color(0xFF10B981), Colors.white, isDark, onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const AddTransactionScreen())).then((_) {
                  if (context.mounted) {
                    context.read<DashboardProvider>().loadDashboardData();
                  }
                });
              }),
              _buildActionItem(Icons.more_horiz, 'Xem thêm', isDark ? const Color(0xFF374151) : const Color(0xFFF3F4F6), isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280), isDark, onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const MoreMenuScreen()));
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionItem(IconData icon, String label, Color bgColor, Color iconColor, bool isDark, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: bgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 26),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isDark ? const Color(0xFFD1D5DB) : const Color(0xFF374151),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSpendingAnalytics(BuildContext context, DashboardData data, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 13,
              child: _buildDonutChartCard(context, data, isDark),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 10,
              child: Column(
                children: [
                  ...data.expenseByCategory.take(3).toList().asMap().entries.map((entry) {
                    final index = entry.key;
                    final cat = entry.value;
                    final color = _chartColors[index % _chartColors.length];
                    final formatCurrency = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ', decimalDigits: 0);
                    
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const BudgetScreen()));
                        },
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(color: isDark ? const Color(0xFF1F2937) : Colors.white, borderRadius: BorderRadius.circular(20)),
                          child: _buildProgressBar(
                            cat.categoryName, 
                            formatCurrency.format(cat.amount), 
                            formatCurrency.format(data.totalExpenseMonth), 
                            cat.percentage, 
                            color,
                            isDark
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                  if (data.expenseByCategory.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(color: isDark ? const Color(0xFF1F2937) : Colors.white, borderRadius: BorderRadius.circular(20)),
                        child: Center(
                          child: Text('Chưa có chi tiêu', style: GoogleFonts.inter(fontSize: 11, color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280))),
                        ),
                      ),
                    ),
                  const _RandomGoalCard(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDonutChartCard(BuildContext context, DashboardData data, bool isDark) {
    final formatCurrency = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ', decimalDigits: 0);
    
    return Container(
      padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: isDark ? const Color(0xFF1F2937) : Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Phân tích chi tiêu', 
                  style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF111827)),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              GestureDetector(
                onTap: () {
                  final provider = context.read<DashboardProvider>();
                  _showMonthPicker(context, provider, isDark);
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Consumer<DashboardProvider>(
                      builder: (context, provider, child) {
                        final now = DateTime.now();
                        String text = 'Tháng này';
                        if (provider.selectedDate.month != now.month || provider.selectedDate.year != now.year) {
                          text = 'Tháng ${provider.selectedDate.month}, ${provider.selectedDate.year}';
                        }
                        return Text(text, style: GoogleFonts.inter(fontSize: 10, color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280)));
                      },
                    ),
                    Icon(Icons.keyboard_arrow_down, size: 14, color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280)),
                  ],
                ),
              )
            ],
          ),
          const SizedBox(height: 24),
          Column(
            children: [
               SizedBox(
                 width: 160,
                 height: 160,
                 child: CustomPaint(
                   painter: DonutChartPainter(
                     expenses: data.expenseByCategory,
                     colors: _chartColors,
                   ),
                   child: Center(
                     child: Padding(
                       padding: const EdgeInsets.symmetric(horizontal: 16.0),
                       child: Column(
                         mainAxisSize: MainAxisSize.min,
                         children: [
                           FittedBox(
                             fit: BoxFit.scaleDown,
                             child: Text(
                               formatCurrency.format(data.totalExpenseMonth), 
                               style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black),
                               textAlign: TextAlign.center,
                             ),
                           ),
                           Text('Tổng chi', style: GoogleFonts.inter(fontSize: 10, color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280))),
                         ],
                       ),
                     ),
                   ),
                 ),
               ),
               const SizedBox(height: 16),
               Column(
                 crossAxisAlignment: CrossAxisAlignment.start,
                 children: [
                   if (data.expenseByCategory.isEmpty)
                     Text('Chưa có chi tiêu', style: GoogleFonts.inter(fontSize: 10, color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280)))
                   else
                     ...data.expenseByCategory.take(5).toList().asMap().entries.map((entry) {
                       final index = entry.key;
                       final cat = entry.value;
                       final color = _chartColors[index % _chartColors.length];
                       final pct = (cat.percentage * 100).toStringAsFixed(0) + '%';
                       return _buildLegendItem(cat.categoryName, pct, color, isDark);
                     }).toList(),
                 ],
               )
            ],
          ),
          const SizedBox(height: 24),
          Builder(
            builder: (ctx) => GestureDetector(
              onTap: () {
                final dashState = ctx.findAncestorStateOfType<DashboardScreenState>();
                dashState?.switchToTab(2);
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF374151) : const Color(0xFFE0E7FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Xem báo cáo chi tiết', style: GoogleFonts.inter(fontSize: 11, color: isDark ? const Color(0xFF60A5FA) : const Color(0xFF2563EB), fontWeight: FontWeight.w600)),
                    const SizedBox(width: 4),
                    Icon(Icons.chevron_right, size: 16, color: isDark ? const Color(0xFF60A5FA) : const Color(0xFF2563EB)),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
  void _showMonthPicker(BuildContext context, DashboardProvider provider, bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF1F2937) : Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        int selectedYear = provider.selectedDate.year;
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: Icon(Icons.arrow_back_ios, size: 16, color: isDark ? Colors.white : Colors.black),
                        onPressed: () => setState(() => selectedYear--),
                      ),
                      Text('Năm $selectedYear', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)),
                      IconButton(
                        icon: Icon(Icons.arrow_forward_ios, size: 16, color: isDark ? Colors.white : Colors.black),
                        onPressed: () => setState(() => selectedYear++),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: List.generate(12, (index) {
                      final month = index + 1;
                      final isSelected = provider.selectedDate.month == month && provider.selectedDate.year == selectedYear;
                      return InkWell(
                        onTap: () {
                          provider.setSelectedDate(DateTime(selectedYear, month, 1));
                          Navigator.pop(ctx);
                        },
                        child: Container(
                          width: (MediaQuery.of(context).size.width - 40 - 36) / 4,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFF2563EB) : Colors.transparent,
                            border: Border.all(color: isSelected ? const Color(0xFF2563EB) : (isDark ? Colors.grey.shade700 : Colors.grey.shade300)),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text('Tháng $month', style: GoogleFonts.inter(
                              color: isSelected ? Colors.white : (isDark ? Colors.white : Colors.black),
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              fontSize: 13
                            )),
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          }
        );
      },
    );
  }

  Widget _buildLegendItem(String title, String percent, Color color, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        children: [
          Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 4),
          Expanded(child: Text(title, style: GoogleFonts.inter(fontSize: 9, color: isDark ? const Color(0xFFD1D5DB) : const Color(0xFF4B5563)), overflow: TextOverflow.ellipsis)),
          Text(percent, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  Widget _buildProgressBar(String title, String spent, String total, double percent, Color color, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: color), overflow: TextOverflow.ellipsis,),
        const SizedBox(height: 4),
        RichText(
          text: TextSpan(
            style: GoogleFonts.inter(fontSize: 9, color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280)),
            children: [
              TextSpan(text: spent, style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF374151))),
              TextSpan(text: ' / $total'),
            ],
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: percent.isNaN ? 0 : percent,
                  backgroundColor: isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB),
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                  minHeight: 6,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text('${(percent * 100).toInt()}%', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF374151))),
          ],
        )
      ],
    );
  }

  Widget _buildRecentTransactions(DashboardData data, bool isDark) {
    return Builder(
      builder: (ctx) => GestureDetector(
        onTap: () {
          ctx.read<TransactionProvider>().setSearchQuery('');
          final dashState = ctx.findAncestorStateOfType<DashboardScreenState>();
          dashState?.switchToTab(1);
        },
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20.0),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1F2937) : Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Chi tiêu gần đây', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF111827))),
          const SizedBox(height: 20),
          if (data.recentTransactions.isEmpty)
            Text('Chưa có giao dịch nào', style: GoogleFonts.inter(color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280))),
          
          ...data.recentTransactions.asMap().entries.map((entry) {
             final index = entry.key;
             final t = entry.value;
             final isLast = index == data.recentTransactions.length - 1;
             
             final isIncome = t.type == 1; // 1 = Income
             final formatCurrency = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ', decimalDigits: 0);
             final formattedAmount = '${isIncome ? '+' : '-'}${formatCurrency.format(t.amount)}';
             
             IconData iconData = Icons.receipt;
             if (t.categoryIcon != null && t.categoryIcon!.isNotEmpty) {
               iconData = isIncome ? Icons.account_balance_wallet : Icons.shopping_bag;
             }

             final color = isIncome ? const Color(0xFF10B981) : const Color(0xFFEF4444);
             final bgColor = isIncome ? const Color(0xFFD1FAE5) : const Color(0xFFFEE2E2);

             final dateFormat = DateFormat('dd/MM');

             return Column(
               children: [
                 _buildTransactionItem(
                   iconData, 
                   isDark && !isIncome ? const Color(0xFF374151) : bgColor, // Adjust bg color for dark mode slightly to be readable if needed, or keep. Let's adjust opacity or use dark colors.
                   color, 
                   t.categoryName.isNotEmpty ? t.categoryName : 'Giao dịch', 
                   t.note != null && t.note!.isNotEmpty ? t.note! : t.walletName, 
                   formattedAmount,
                   dateFormat.format(t.transactionDate.toLocal()),
                   isDark
                 ),
                 if (!isLast) _buildTransactionDivider(isDark),
               ],
             );
          }).toList()
        ],
      ),
        ),
      ),
    );
  }

  Widget _buildTransactionItem(IconData icon, Color iconBgColor, Color iconColor, String title, String subtitle, String amount, String date, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: iconBgColor, shape: BoxShape.circle),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14, color: isDark ? Colors.white : const Color(0xFF111827))),
                const SizedBox(height: 4),
                Text(subtitle, style: GoogleFonts.inter(fontSize: 12, color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280))),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(amount, style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 14, color: isDark ? Colors.white : const Color(0xFF111827))),
              const SizedBox(height: 4),
              Text(date, style: GoogleFonts.inter(fontSize: 12, color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280))),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildTransactionDivider(bool isDark) {
    return Divider(color: isDark ? const Color(0xFF374151) : const Color(0xFFF3F4F6), height: 1);
  }
}

class _RandomGoalCard extends StatefulWidget {
  const _RandomGoalCard({Key? key}) : super(key: key);
  @override
  State<_RandomGoalCard> createState() => _RandomGoalCardState();
}

class _RandomGoalCardState extends State<_RandomGoalCard> {
  int? _randomIndex;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final goalProvider = context.watch<GoalProvider>();
    final goals = goalProvider.activeGoals;
    
    if (goalProvider.isLoading && goals.isEmpty) {
      return const SizedBox(height: 100, child: Center(child: CircularProgressIndicator()));
    }

    if (goals.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12.0),
        child: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SavingGoalsScreen()),
            ).then((_) {
              if (context.mounted) {
                context.read<GoalProvider>().loadGoals();
              }
            });
          },
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1F2937) : Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Icon(Icons.track_changes, color: isDark ? const Color(0xFF60A5FA) : const Color(0xFF2563EB), size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text('Tạo mục tiêu mới', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF111827))),
                ),
                Icon(Icons.add_circle, color: isDark ? const Color(0xFF60A5FA) : const Color(0xFF2563EB), size: 20),
              ],
            ),
          ),
        ),
      );
    }

    if (_randomIndex == null || _randomIndex! >= goals.length) {
      _randomIndex = Random().nextInt(goals.length);
    }

    final goal = goals[_randomIndex!];
    final formatCurrency = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ', decimalDigits: 0);
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => GoalDetailScreen(goalId: goal.id)),
          ).then((_) {
            if (context.mounted) {
              context.read<GoalProvider>().loadGoals();
            }
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1F2937) : Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF8B5CF6).withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: GoalIconMapper.buildGoalIcon(goal.icon, size: 16, color: const Color(0xFF8B5CF6)),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text('Mục tiêu: ${goal.name}', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF8B5CF6)), overflow: TextOverflow.ellipsis,),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              RichText(
                text: TextSpan(
                  style: GoogleFonts.inter(fontSize: 10, color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280)),
                  children: [
                    TextSpan(text: formatCurrency.format(goal.currentAmount), style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF374151))),
                    TextSpan(text: ' / ${formatCurrency.format(goal.targetAmount)}'),
                  ],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: goal.progress.isNaN ? 0 : goal.progress,
                        backgroundColor: isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB),
                        valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF8B5CF6)),
                        minHeight: 8,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text('${(goal.progress * 100).toInt()}%', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF374151))),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DonutChartPainter extends CustomPainter {
  final List<CategoryExpense> expenses;
  final List<Color> colors;

  DonutChartPainter({required this.expenses, required this.colors});

  @override
  void paint(Canvas canvas, Size size) {
    double strokeWidth = 24.0;
    Rect rect = Rect.fromCircle(
        center: Offset(size.width / 2, size.height / 2),
        radius: (size.width - strokeWidth) / 2);

    if (expenses.isEmpty) {
      Paint paint = Paint()
        ..color = const Color(0xFFE5E7EB)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.butt;
      canvas.drawArc(rect, 0, 2 * 3.14159, false, paint);
      return;
    }

    double startAngle = -3.14159 / 2; // Start from top
    for (int i = 0; i < expenses.length; i++) {
      double sweepAngle = expenses[i].percentage * 2 * 3.14159;
      Paint paint = Paint()
        ..color = colors[i % colors.length]
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.butt;

      canvas.drawArc(rect, startAngle, sweepAngle, false, paint);
      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
