import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/category_provider.dart';
import '../screens/add_category_screen.dart';

class CategoryBottomSheet extends StatefulWidget {
  final int selectedType; // 1: Thu nhập, 2: Chi tiêu

  const CategoryBottomSheet({super.key, required this.selectedType});

  @override
  State<CategoryBottomSheet> createState() => _CategoryBottomSheetState();
}

class _CategoryBottomSheetState extends State<CategoryBottomSheet> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 16),
          Container(width: 40, height: 4, decoration: BoxDecoration(color: const Color(0xFFE5E7EB), borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 16),
          Text(widget.selectedType == 1 ? 'Chọn danh mục Thu nhập' : 'Chọn danh mục Chi tiêu', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF111827))),
          const Divider(height: 32),
          Expanded(
            child: Consumer<CategoryProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading && provider.categories.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                final filteredCategories = provider.categories.where((c) => c.type == widget.selectedType).toList();

                return GridView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    mainAxisSpacing: 20,
                    crossAxisSpacing: 20,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: filteredCategories.length + 1,
                  itemBuilder: (context, index) {
                    if (index == filteredCategories.length) {
                      return _buildAddCategoryButton(context);
                    }

                    final cat = filteredCategories[index];
                    return InkWell(
                      onTap: () {
                        Navigator.pop(context, cat);
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF3F4F6),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(_getIcon(cat.icon), color: const Color(0xFF4B5563)),
                          ),
                          const SizedBox(height: 8),
                          Text(cat.name, style: GoogleFonts.poppins(fontSize: 11, color: const Color(0xFF374151)), textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          )
        ],
      ),
    );
  }

  Widget _buildAddCategoryButton(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.pop(context); // Đóng sheet
        Navigator.push(context, MaterialPageRoute(builder: (_) => AddCategoryScreen(type: widget.selectedType)));
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xFFE0E7FF),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF818CF8), style: BorderStyle.solid),
            ),
            child: const Icon(Icons.add, color: Color(0xFF4F46E5)),
          ),
          const SizedBox(height: 8),
          Text('Thêm mới', style: GoogleFonts.poppins(fontSize: 11, color: const Color(0xFF4F46E5), fontWeight: FontWeight.bold), textAlign: TextAlign.center),
        ],
      ),
    );
  }

  IconData _getIcon(String? iconName) {
    switch (iconName) {
      case 'restaurant': return Icons.restaurant;
      case 'shopping_cart': return Icons.shopping_cart;
      case 'home': return Icons.home;
      case 'directions_car': return Icons.directions_car;
      case 'local_hospital': return Icons.local_hospital;
      case 'school': return Icons.school;
      case 'card_giftcard': return Icons.card_giftcard;
      case 'monetization_on': return Icons.monetization_on;
      case 'work': return Icons.work;
      case 'account_balance': return Icons.account_balance;
      default: return Icons.category;
    }
  }
}
