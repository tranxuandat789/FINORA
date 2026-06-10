import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BudgetScreen extends StatelessWidget {
  const BudgetScreen({super.key});

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
              _buildMonthlyOverview(),
              const SizedBox(height: 24),
              _buildBudgetCategories(),
              const SizedBox(height: 24),
              _buildAddBudgetButton(),
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
            'Ngân sách',
            style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: const Color(0xFF111827)),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(color: Color(0xFF2563EB), shape: BoxShape.circle),
            child: const Icon(Icons.add, color: Colors.white, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyOverview() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F172A), Color(0xFF1E3A5F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Tháng này', style: GoogleFonts.poppins(color: Colors.white.withOpacity(0.7), fontSize: 13)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Text('Tháng 6/2025', style: GoogleFonts.poppins(color: Colors.white, fontSize: 12)),
                    const Icon(Icons.keyboard_arrow_down, color: Colors.white, size: 16),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text('0 đ', style: GoogleFonts.poppins(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
          Text('/ 0 đ ngân sách', style: GoogleFonts.poppins(color: Colors.white.withOpacity(0.6), fontSize: 13)),
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: 0,
              backgroundColor: Colors.white.withOpacity(0.2),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF34D399)),
              minHeight: 10,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Đã chi: 0%', style: GoogleFonts.poppins(color: const Color(0xFF34D399), fontSize: 12, fontWeight: FontWeight.w600)),
              Text('Còn lại: 0 đ', style: GoogleFonts.poppins(color: Colors.white.withOpacity(0.7), fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetCategories() {
    final categories = [
      {'name': 'Ăn uống', 'icon': Icons.restaurant, 'color': const Color(0xFF2563EB), 'bg': const Color(0xFFE0E7FF), 'budget': '2,000,000 đ', 'spent': '0 đ', 'pct': 0.0},
      {'name': 'Di chuyển', 'icon': Icons.directions_car, 'color': const Color(0xFF10B981), 'bg': const Color(0xFFD1FAE5), 'budget': '500,000 đ', 'spent': '0 đ', 'pct': 0.0},
      {'name': 'Giải trí', 'icon': Icons.movie, 'color': const Color(0xFF8B5CF6), 'bg': const Color(0xFFF3E8FF), 'budget': '1,000,000 đ', 'spent': '0 đ', 'pct': 0.0},
      {'name': 'Mua sắm', 'icon': Icons.shopping_bag, 'color': const Color(0xFFF59E0B), 'bg': const Color(0xFFFEF3C7), 'budget': '3,000,000 đ', 'spent': '0 đ', 'pct': 0.0},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Ngân sách theo danh mục', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF111827))),
          const SizedBox(height: 16),
          ...categories.map((cat) => _buildBudgetCard(cat)).toList(),
        ],
      ),
    );
  }

  Widget _buildBudgetCard(Map<String, dynamic> cat) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(color: cat['bg'] as Color, shape: BoxShape.circle),
                child: Icon(cat['icon'] as IconData, color: cat['color'] as Color, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(cat['name'] as String, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF111827))),
                    Text('${cat['spent']} / ${cat['budget']}', style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF6B7280))),
                  ],
                ),
              ),
              Text('0%', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: cat['color'] as Color)),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: cat['pct'] as double,
              backgroundColor: const Color(0xFFF3F4F6),
              valueColor: AlwaysStoppedAnimation<Color>(cat['color'] as Color),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddBudgetButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GestureDetector(
        onTap: () {},
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF2563EB), width: 1.5),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.add_circle_outline, color: Color(0xFF2563EB), size: 20),
              const SizedBox(width: 8),
              Text('Thêm ngân sách', style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600, color: const Color(0xFF2563EB))),
            ],
          ),
        ),
      ),
    );
  }
}
