import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:mobile/features/auth/providers/auth_provider.dart';
import 'package:mobile/features/profile/screens/profile_screen.dart';
import 'package:mobile/features/analytics/screens/analytics_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const _DashboardTab(),
    const Center(child: Text('Giao dịch')),
    const AnalyticsScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: _pages[_selectedIndex],
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: const Color(0xFF2563EB),
        elevation: 4,
        child: const Icon(Icons.add, color: Colors.white, size: 28),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
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
  const _DashboardTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAppBar(context),
            _buildBalanceCard(),
            _buildActionMenu(),
            const SizedBox(height: 24),
            _buildSpendingAnalytics(),
            const SizedBox(height: 24),
            _buildRecentTransactions(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }


  Widget _buildAppBar(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
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
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: const Icon(Icons.notifications_none, color: Color(0xFF374151)),
          )
        ],
      ),
    );
  }

  Widget _buildBalanceCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
      decoration: BoxDecoration(
        color: const Color(0xFF0D6EFD), // Deep Blue
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0D6EFD).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            // Hiệu ứng gợn sóng 1 (Ngoài cùng)
            Positioned(
              right: -80,
              bottom: -80,
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.08),
                ),
              ),
            ),
            // Hiệu ứng gợn sóng 2 (Giữa)
            Positioned(
              right: 40,
              bottom: -120,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.05),
                ),
              ),
            ),
            // Hiệu ứng gợn sóng 3 (Trong)
            Positioned(
              right: -50,
              bottom: 80,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.03),
                ),
              ),
            ),
            
            // Nội dung chính
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Tổng số dư', style: GoogleFonts.poppins(color: Colors.white.withOpacity(0.9), fontSize: 14)),
                  const SizedBox(height: 8),
                  Text('25.000.000đ', style: GoogleFonts.poppins(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Icon(Icons.arrow_upward, color: Color(0xFF34D399), size: 16),
                      const SizedBox(width: 4),
                      Text('50.32 %', style: GoogleFonts.poppins(color: const Color(0xFF34D399), fontSize: 12, fontWeight: FontWeight.w600)),
                      Text(' so với tháng trước', style: GoogleFonts.poppins(color: Colors.white.withOpacity(0.9), fontSize: 12)),
                    ],
                  )
                ],
              ),
            ),
            
            // Icon
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
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildActionItem(Icons.account_balance_wallet, 'Tài khoản', const Color(0xFF2563EB), Colors.white),
            _buildActionItem(Icons.track_changes, 'Mục tiêu', const Color(0xFF8B5CF6), Colors.white),
            _buildActionItem(Icons.receipt_long, 'Ghi chi tiêu', const Color(0xFF10B981), Colors.white),
            _buildActionItem(Icons.more_horiz, 'Xem thêm', const Color(0xFFF3F4F6), const Color(0xFF6B7280)),
          ],
        ),
      ),
    );
  }

  Widget _buildActionItem(IconData icon, String label, Color bgColor, Color iconColor) {
    return Column(
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
    );
  }

  Widget _buildSpendingAnalytics() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 13,
              child: _buildDonutChartCard(),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 10,
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                    child: _buildProgressBar('Ăn uống', '2.800.000đ', '4.000.000đ', 0.72, const Color(0xFF2563EB)),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                    child: _buildProgressBar('Mua sắm', '2.800.000đ', '4.000.000đ', 0.72, const Color(0xFFF59E0B)),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                    child: _buildProgressBar('Du lịch nhật bản', '7.000.000đ', '10.000.000đ', 0.72, const Color(0xFF2563EB)),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDonutChartCard() {
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
          Row(
            children: [
               SizedBox(
                 width: 120,
                 height: 120,
                 child: CustomPaint(
                   painter: DonutChartPainter(),
                   child: Center(
                     child: Column(
                       mainAxisSize: MainAxisSize.min,
                       children: [
                         Text('12.000.000đ', style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.bold)),
                         Text('Tổng chi tiêu', style: GoogleFonts.poppins(fontSize: 8, color: const Color(0xFF6B7280))),
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
                     _buildLegendItem('Ăn uống', '34%', const Color(0xFF2563EB)),
                     _buildLegendItem('Mua sắm', '25%', const Color(0xFF10B981)),
                     _buildLegendItem('Giải trí', '20%', const Color(0xFF8B5CF6)),
                     _buildLegendItem('Đi lại', '14%', const Color(0xFF60A5FA)),
                     _buildLegendItem('Khác', '7%', const Color(0xFFF59E0B)),
                   ],
                 ),
               )
            ],
          ),
          const SizedBox(height: 24),
          Container(
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
        Text(title, style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold, color: color)),
        const SizedBox(height: 4),
        RichText(
          text: TextSpan(
            style: GoogleFonts.poppins(fontSize: 9, color: const Color(0xFF6B7280)),
            children: [
              TextSpan(text: spent, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF374151))),
              TextSpan(text: ' / $total'),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: percent,
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

  Widget _buildRecentTransactions() {
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
          _buildTransactionItem(Icons.restaurant_menu, const Color(0xFFD1FAE5), const Color(0xFF10B981), 'Ăn phở', 'Ăn uống', '-120.000đ'),
          _buildTransactionDivider(),
          _buildTransactionItem(Icons.shopping_bag, const Color(0xFFE0E7FF), const Color(0xFF2563EB), 'Mua quần áo', 'Mua sắm', '-120.000đ'),
          _buildTransactionDivider(),
          _buildTransactionItem(Icons.directions_car, const Color(0xFFFFEDD5), const Color(0xFFF59E0B), 'Mua xăng', 'Đi lại', '-120.000đ'),
          _buildTransactionDivider(),
          _buildTransactionItem(Icons.sports_esports, const Color(0xFFF3E8FF), const Color(0xFF8B5CF6), 'Xem phim', 'Giải trí', '-120.000đ'),
        ],
      ),
    );
  }

  Widget _buildTransactionDivider() {
    return const Divider(color: Color(0xFFF3F4F6), height: 32, thickness: 1);
  }

  Widget _buildTransactionItem(IconData icon, Color bgColor, Color iconColor, String title, String subtitle, String amount) {
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
              Text(title, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF111827))),
              Text(subtitle, style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF6B7280))),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(amount, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF111827))),
            Text('Hôm nay', style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF6B7280))),
          ],
        )
      ],
    );
  }

}

class DonutChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    double strokeWidth = 16.0;
    Rect rect = Rect.fromCircle(
        center: Offset(size.width / 2, size.height / 2),
        radius: (size.width - strokeWidth) / 2);

    List<Color> colors = [
      const Color(0xFF2563EB), // Ăn uống 34%
      const Color(0xFF10B981), // Mua sắm 25%
      const Color(0xFF8B5CF6), // Giải trí 20%
      const Color(0xFF60A5FA), // Đi lại 14%
      const Color(0xFFF59E0B), // Khác 7%
    ];
    List<double> values = [0.34, 0.25, 0.20, 0.14, 0.07];

    double startAngle = -3.14159 / 2; // Start from top
    for (int i = 0; i < values.length; i++) {
      double sweepAngle = values[i] * 2 * 3.14159;
      Paint paint = Paint()
        ..color = colors[i]
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.butt;

      canvas.drawArc(rect, startAngle, sweepAngle, false, paint);
      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
