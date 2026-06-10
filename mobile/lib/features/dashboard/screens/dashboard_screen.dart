import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:mobile/features/auth/providers/auth_provider.dart';
import 'package:mobile/features/profile/screens/profile_screen.dart';
import 'package:mobile/features/analytics/screens/analytics_screen.dart';
import 'package:mobile/features/goal/screens/saving_goals_screen.dart';
import 'package:mobile/features/transaction/providers/category_provider.dart';
import 'package:mobile/features/transaction/screens/transaction_screen.dart';
import 'package:mobile/features/transaction/screens/add_transaction_screen.dart';
import 'package:mobile/features/transaction/providers/transaction_provider.dart';
import 'package:mobile/features/sync/providers/sync_provider.dart';
import 'package:mobile/features/dashboard/providers/dashboard_provider.dart';
import 'package:mobile/features/dashboard/models/dashboard_model.dart';
import 'package:mobile/features/home/screens/wallet_screen.dart';
import 'package:mobile/features/home/screens/more_menu_screen.dart';
import 'package:mobile/features/home/screens/notification_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
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
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: _pages[_selectedIndex],
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
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 8.0,
      color: Colors.white,
      elevation: 8,
      child: SizedBox(
        height: 64,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildBottomNavItem(icon: Icons.home, label: 'Trang chủ', index: 0),
            _buildBottomNavItem(icon: Icons.receipt_long, label: 'Giao dịch', index: 1),
            const SizedBox(width: 48), // Space for FAB
            _buildBottomNavItem(icon: Icons.pie_chart, label: 'Phân tích', index: 2),
            _buildBottomNavItem(icon: Icons.person, label: 'Cá nhân', index: 3),
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
            style: GoogleFonts.poppins(
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
                  Text('Lỗi: ${dashboardProvider.error}', style: GoogleFonts.poppins()),
                  TextButton(
                    onPressed: () => context.read<DashboardProvider>().loadDashboardData(),
                    child: Text('Thử lại', style: GoogleFonts.poppins(color: const Color(0xFF2563EB))),
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
                  _buildAppBar(context),
                  _buildBalanceCard(data),
                  _buildActionMenu(),
                  const SizedBox(height: 24),
                  _buildSpendingAnalytics(data),
                  const SizedBox(height: 24),
                  _buildRecentTransactions(data),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final String fullName = authProvider.user?['fullName'] ?? 'Người dùng';

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF2563EB), width: 1.5),
            ),
            child: const CircleAvatar(
              radius: 22,
              backgroundImage: AssetImage('assets/images/Logo.png'),
              backgroundColor: Colors.white,
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Xin chào,', style: GoogleFonts.poppins(fontSize: 13, color: const Color(0xFF6B7280))),
              Text(fullName, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF111827))),
            ],
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
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(success ? 'Đồng bộ thành công!' : (syncProvider.error ?? 'Đồng bộ thất bại.'))),
                          );
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
                        style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFFEF4444)),
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
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: const Icon(Icons.notifications_none, color: Color(0xFF374151)),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildBalanceCard(DashboardData data) {
    final formatCurrency = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');
    final formattedBalance = formatCurrency.format(data.totalBalance);
    
    // Percentage trend logic
    final pctChange = data.balancePercentageChange;
    final isPositive = pctChange >= 0;
    final pctText = pctChange.abs().toStringAsFixed(1) + '%';
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
      decoration: BoxDecoration(
        color: const Color(0xFF0D6EFD), // Deep Blue
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
            Positioned(
              right: -80,
              bottom: -80,
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.08),
                ),
              ),
            ),
            Positioned(
              right: 40,
              bottom: -120,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.05),
                ),
              ),
            ),
            Positioned(
              right: -50,
              bottom: 80,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.03),
                ),
              ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Tổng số dư', style: GoogleFonts.poppins(color: Colors.white.withValues(alpha: 0.9), fontSize: 14)),
                  const SizedBox(height: 8),
                  Text(formattedBalance, style: GoogleFonts.poppins(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Icon(isPositive ? Icons.arrow_upward : Icons.arrow_downward, 
                           color: isPositive ? const Color(0xFF34D399) : const Color(0xFFFCA5A5), size: 16),
                      const SizedBox(width: 4),
                      Text(pctText, style: GoogleFonts.poppins(color: isPositive ? const Color(0xFF34D399) : const Color(0xFFFCA5A5), fontSize: 12, fontWeight: FontWeight.w600)),
                      Text(' so với tháng trước', style: GoogleFonts.poppins(color: Colors.white.withValues(alpha: 0.9), fontSize: 12)),
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

  Widget _buildActionMenu() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20.0),
        decoration: BoxDecoration(
          color: Colors.white,
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
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildActionItem(Icons.account_balance_wallet, 'Tài khoản', const Color(0xFF2563EB), Colors.white, onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const WalletScreen()));
              }),
              _buildActionItem(Icons.track_changes, 'Mục tiêu', const Color(0xFF8B5CF6), Colors.white, onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const SavingGoalsScreen()));
              }),
              _buildActionItem(Icons.receipt_long, 'Ghi chi tiêu', const Color(0xFF10B981), Colors.white, onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const AddTransactionScreen())).then((_) {
                  if (context.mounted) {
                    context.read<DashboardProvider>().loadDashboardData();
                  }
                });
              }),
              _buildActionItem(Icons.more_horiz, 'Xem thêm', const Color(0xFFF3F4F6), const Color(0xFF6B7280), onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const MoreMenuScreen()));
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionItem(IconData icon, String label, Color bgColor, Color iconColor, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: bgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF374151),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSpendingAnalytics(DashboardData data) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 13,
              child: _buildDonutChartCard(data),
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
                    final formatCurrency = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');
                    
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                        child: _buildProgressBar(
                          cat.categoryName, 
                          formatCurrency.format(cat.amount), 
                          formatCurrency.format(data.totalExpenseMonth), 
                          cat.percentage, 
                          color
                        ),
                      ),
                    );
                  }).toList(),
                  if (data.expenseByCategory.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                      child: Center(
                        child: Text('Chưa có chi tiêu', style: GoogleFonts.poppins(fontSize: 11, color: const Color(0xFF6B7280))),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDonutChartCard(DashboardData data) {
    final formatCurrency = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ', decimalDigits: 0);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
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
                  style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF111827)),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Tháng này', style: GoogleFonts.poppins(fontSize: 10, color: const Color(0xFF6B7280))),
                  const Icon(Icons.keyboard_arrow_down, size: 14, color: Color(0xFF6B7280)),
                ],
              )
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
               SizedBox(
                 width: 120,
                 height: 120,
                 child: CustomPaint(
                   painter: DonutChartPainter(
                     expenses: data.expenseByCategory,
                     colors: _chartColors,
                   ),
                   child: Center(
                     child: Column(
                       mainAxisSize: MainAxisSize.min,
                       children: [
                         Text(
                           formatCurrency.format(data.totalExpenseMonth), 
                           style: GoogleFonts.poppins(fontSize: 9, fontWeight: FontWeight.bold),
                           textAlign: TextAlign.center,
                         ),
                         Text('Tổng chi', style: GoogleFonts.poppins(fontSize: 8, color: const Color(0xFF6B7280))),
                       ],
                     ),
                   ),
                 ),
               ),
               const SizedBox(width: 8),
               Expanded(
                 child: Column(
                   crossAxisAlignment: CrossAxisAlignment.start,
                   children: [
                     if (data.expenseByCategory.isEmpty)
                       Text('Chưa có chi tiêu', style: GoogleFonts.poppins(fontSize: 10, color: const Color(0xFF6B7280)))
                     else
                       ...data.expenseByCategory.take(5).toList().asMap().entries.map((entry) {
                         final index = entry.key;
                         final cat = entry.value;
                         final color = _chartColors[index % _chartColors.length];
                         final pct = (cat.percentage * 100).toStringAsFixed(0) + '%';
                         return _buildLegendItem(cat.categoryName, pct, color);
                       }).toList(),
                   ],
                 ),
               )
            ],
          ),
          const SizedBox(height: 24),
          Builder(
            builder: (ctx) => GestureDetector(
              onTap: () {
                final dashState = ctx.findAncestorStateOfType<_DashboardScreenState>();
                dashState?.switchToTab(2);
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFE0E7FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Xem báo cáo chi tiết', style: GoogleFonts.poppins(fontSize: 11, color: const Color(0xFF2563EB), fontWeight: FontWeight.w600)),
                    const SizedBox(width: 4),
                    const Icon(Icons.chevron_right, size: 16, color: Color(0xFF2563EB)),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildLegendItem(String title, String percent, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        children: [
          Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 4),
          Expanded(child: Text(title, style: GoogleFonts.poppins(fontSize: 9, color: const Color(0xFF4B5563)), overflow: TextOverflow.ellipsis)),
          Text(percent, style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  Widget _buildProgressBar(String title, String spent, String total, double percent, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold, color: color), overflow: TextOverflow.ellipsis,),
        const SizedBox(height: 4),
        RichText(
          text: TextSpan(
            style: GoogleFonts.poppins(fontSize: 9, color: const Color(0xFF6B7280)),
            children: [
              TextSpan(text: spent, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF374151))),
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
                  backgroundColor: const Color(0xFFE5E7EB),
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                  minHeight: 6,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text('${(percent * 100).toInt()}%', style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFF374151))),
          ],
        )
      ],
    );
  }

  Widget _buildRecentTransactions(DashboardData data) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20.0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Chi tiêu gần đây', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF111827))),
          const SizedBox(height: 20),
          if (data.recentTransactions.isEmpty)
            Text('Chưa có giao dịch nào', style: GoogleFonts.poppins(color: const Color(0xFF6B7280))),
          
          ...data.recentTransactions.asMap().entries.map((entry) {
             final index = entry.key;
             final t = entry.value;
             final isLast = index == data.recentTransactions.length - 1;
             
             final isIncome = t.type == 1; // 1 = Income
             final formatCurrency = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');
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
                   bgColor, 
                   color, 
                   t.categoryName.isNotEmpty ? t.categoryName : 'Giao dịch', 
                   t.note != null && t.note!.isNotEmpty ? t.note! : t.walletName, 
                   formattedAmount,
                   dateFormat.format(t.transactionDate.toLocal())
                 ),
                 if (!isLast) _buildTransactionDivider(),
               ],
             );
          }).toList()
        ],
      ),
    );
  }

  Widget _buildTransactionDivider() {
    return const Divider(color: Color(0xFFF3F4F6), height: 32, thickness: 1);
  }

  Widget _buildTransactionItem(IconData icon, Color bgColor, Color iconColor, String title, String subtitle, String amount, String date) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: bgColor,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF111827)), maxLines: 1, overflow: TextOverflow.ellipsis,),
              Text(subtitle, style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF6B7280)), maxLines: 1, overflow: TextOverflow.ellipsis,),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(amount, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF111827))),
            Text(date, style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF6B7280))),
          ],
        )
      ],
    );
  }

}

class DonutChartPainter extends CustomPainter {
  final List<CategoryExpense> expenses;
  final List<Color> colors;

  DonutChartPainter({required this.expenses, required this.colors});

  @override
  void paint(Canvas canvas, Size size) {
    double strokeWidth = 16.0;
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
