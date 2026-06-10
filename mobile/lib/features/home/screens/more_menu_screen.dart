import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile/features/goal/screens/saving_goals_screen.dart';
import 'package:mobile/features/budget/screens/budget_screen.dart';

class MoreMenuScreen extends StatelessWidget {
  const MoreMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: 24),
              _buildMenuSection(
                context,
                title: 'Tài chính',
                items: [
                  _MenuItem(
                    icon: Icons.track_changes,
                    label: 'Mục tiêu tiết kiệm',
                    subtitle: 'Theo dõi và đạt mục tiêu tài chính',
                    color: const Color(0xFF8B5CF6),
                    bg: const Color(0xFFF3E8FF),
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SavingGoalsScreen())),
                  ),
                  _MenuItem(
                    icon: Icons.pie_chart_outline,
                    label: 'Ngân sách',
                    subtitle: 'Lập kế hoạch chi tiêu hàng tháng',
                    color: const Color(0xFF10B981),
                    bg: const Color(0xFFD1FAE5),
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BudgetScreen())),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildMenuSection(
                context,
                title: 'Công cụ',
                items: [
                  _MenuItem(
                    icon: Icons.calculate_outlined,
                    label: 'Máy tính tài chính',
                    subtitle: 'Tính lãi suất, khoản vay, tiết kiệm',
                    color: const Color(0xFFF59E0B),
                    bg: const Color(0xFFFEF3C7),
                    onTap: () {},
                  ),
                  _MenuItem(
                    icon: Icons.bar_chart,
                    label: 'Báo cáo nâng cao',
                    subtitle: 'Phân tích chi tiêu theo thời gian',
                    color: const Color(0xFFEF4444),
                    bg: const Color(0xFFFEE2E2),
                    onTap: () {},
                  ),
                  _MenuItem(
                    icon: Icons.sync_alt,
                    label: 'Đồng bộ dữ liệu',
                    subtitle: 'Đồng bộ với thiết bị khác',
                    color: const Color(0xFF06B6D4),
                    bg: const Color(0xFFE0F7FA),
                    onTap: () {},
                  ),
                ],
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: const Icon(Icons.arrow_back, size: 20, color: Color(0xFF374151)),
            ),
          ),
          const SizedBox(width: 16),
          Text(
            'Xem thêm',
            style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: const Color(0xFF111827)),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSection(BuildContext context, {required String title, required List<_MenuItem> items}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF6B7280))),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
            ),
            child: Column(
              children: items.asMap().entries.map((entry) {
                final i = entry.key;
                final item = entry.value;
                return Column(
                  children: [
                    InkWell(
                      onTap: item.onTap,
                      borderRadius: i == 0
                          ? const BorderRadius.vertical(top: Radius.circular(20))
                          : i == items.length - 1
                              ? const BorderRadius.vertical(bottom: Radius.circular(20))
                              : BorderRadius.zero,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        child: Row(
                          children: [
                            Container(
                              width: 48, height: 48,
                              decoration: BoxDecoration(color: item.bg, shape: BoxShape.circle),
                              child: Icon(item.icon, color: item.color, size: 22),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(item.label, style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600, color: const Color(0xFF111827))),
                                  Text(item.subtitle, style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF9CA3AF))),
                                ],
                              ),
                            ),
                            const Icon(Icons.chevron_right, color: Color(0xFF9CA3AF), size: 20),
                          ],
                        ),
                      ),
                    ),
                    if (i < items.length - 1)
                      const Divider(color: Color(0xFFF3F4F6), height: 1, indent: 84),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final Color bg;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.bg,
    required this.onTap,
  });
}
