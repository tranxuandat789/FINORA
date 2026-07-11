import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/category_provider.dart';
import 'package:mobile/core/utils/snackbar_utils.dart';
import '../../../core/providers/theme_provider.dart';

class AddCategoryScreen extends StatefulWidget {
  final int type; // 1: Thu nhập, 2: Chi tiêu

  const AddCategoryScreen({super.key, required this.type});

  @override
  State<AddCategoryScreen> createState() => _AddCategoryScreenState();
}

class _AddCategoryScreenState extends State<AddCategoryScreen> {
  final _nameController = TextEditingController();
  String _selectedIcon = 'category';
  bool _isLoading = false;

  final List<Map<String, dynamic>> _availableIcons = [
    {'name': 'category', 'icon': Icons.category},
    {'name': 'restaurant', 'icon': Icons.restaurant},
    {'name': 'shopping_cart', 'icon': Icons.shopping_cart},
    {'name': 'home', 'icon': Icons.home},
    {'name': 'directions_car', 'icon': Icons.directions_car},
    {'name': 'local_hospital', 'icon': Icons.local_hospital},
    {'name': 'school', 'icon': Icons.school},
    {'name': 'card_giftcard', 'icon': Icons.card_giftcard},
    {'name': 'monetization_on', 'icon': Icons.monetization_on},
    {'name': 'work', 'icon': Icons.work},
    {'name': 'account_balance', 'icon': Icons.account_balance},
    {'name': 'sports_esports', 'icon': Icons.sports_esports},
    {'name': 'flight', 'icon': Icons.flight},
    {'name': 'pets', 'icon': Icons.pets},
  ];

  final _budgetController = TextEditingController();

  void _saveCategory() async {
    if (_nameController.text.trim().isEmpty) {
      SnackBarUtils.showTopSnackBar(context, 'Vui lòng nhập tên danh mục', isSuccess: false);
      return;
    }

    double? budget;
    if (widget.type == 2 && _budgetController.text.trim().isNotEmpty) {
      final val = double.tryParse(_budgetController.text.replaceAll(RegExp(r'[^0-9]'), ''));
      if (val != null && val > 0) {
        budget = val;
      }
    }

    setState(() => _isLoading = true);

    final success = await context.read<CategoryProvider>().createCategory(
      _nameController.text.trim(),
      widget.type,
      _selectedIcon,
      budgetAmount: budget,
    );

    setState(() => _isLoading = false);

    if (success && mounted) {
      SnackBarUtils.showTopSnackBar(context, 'Thêm danh mục thành công', isSuccess: true);
      Navigator.pop(context);
    } else if (mounted) {
      final err = context.read<CategoryProvider>().error;
      SnackBarUtils.showTopSnackBar(context, err ?? 'Có lỗi xảy ra', isSuccess: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF1F2937) : Colors.white,
      appBar: AppBar(
        title: Text('Thêm danh mục', style: GoogleFonts.inter(color: isDark ? Colors.white : const Color(0xFF111827), fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: isDark ? const Color(0xFF111827) : Colors.white,
        elevation: 0,
        leading: IconButton(icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : const Color(0xFF111827)), onPressed: () => Navigator.pop(context)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Loại danh mục', style: GoogleFonts.inter(color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280), fontSize: 14)),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: isDark ? const Color(0xFF374151) : const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(12)),
              child: Text(widget.type == 1 ? 'Thu nhập' : 'Chi tiêu', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: widget.type == 1 ? const Color(0xFF10B981) : const Color(0xFFEF4444))),
            ),
            const SizedBox(height: 24),
            Text('Tên danh mục', style: GoogleFonts.inter(color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280), fontSize: 14)),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                hintText: 'VD: Lương, Ăn uống, Tiền nhà...',
                hintStyle: GoogleFonts.inter(color: isDark ? const Color(0xFF6B7280) : const Color(0xFF9CA3AF)),
                filled: true,
                fillColor: isDark ? const Color(0xFF374151) : const Color(0xFFF3F4F6),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
              style: GoogleFonts.inter(color: isDark ? Colors.white : const Color(0xFF111827), fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 24),
            if (widget.type == 2) ...[
              Text('Ngân sách chi tiêu (Tùy chọn)', style: GoogleFonts.inter(color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280), fontSize: 14)),
              const SizedBox(height: 8),
              TextField(
                controller: _budgetController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'VD: 2000000',
                  hintStyle: GoogleFonts.inter(color: isDark ? const Color(0xFF6B7280) : const Color(0xFF9CA3AF)),
                  filled: true,
                  fillColor: isDark ? const Color(0xFF374151) : const Color(0xFFF3F4F6),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
                style: GoogleFonts.inter(color: isDark ? Colors.white : const Color(0xFF111827), fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 24),
            ],
            Text('Chọn Icon', style: GoogleFonts.inter(color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280), fontSize: 14)),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
              ),
              itemCount: _availableIcons.length,
              itemBuilder: (context, index) {
                final iconData = _availableIcons[index];
                final isSelected = _selectedIcon == iconData['name'];

                return InkWell(
                  onTap: () => setState(() => _selectedIcon = iconData['name']),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF2563EB) : (isDark ? const Color(0xFF374151) : const Color(0xFFF3F4F6)),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(iconData['icon'], color: isSelected ? Colors.white : (isDark ? const Color(0xFFD1D5DB) : const Color(0xFF4B5563))),
                  ),
                );
              },
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveCategory,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: _isLoading 
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text('Lưu danh mục', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
              ),
            )
          ],
        ),
      ),
    );
  }
}
