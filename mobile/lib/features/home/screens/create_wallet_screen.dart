import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile/core/utils/snackbar_utils.dart';

class CreateWalletScreen extends StatefulWidget {
  const CreateWalletScreen({super.key});

  @override
  State<CreateWalletScreen> createState() => _CreateWalletScreenState();
}

class _CreateWalletScreenState extends State<CreateWalletScreen> {
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  int _selectedIconIndex = 0;
  int _selectedColorIndex = 0;

  // 6 colors extracted from Figma ellipses
  final List<Color> _colors = [
    const Color(0xFF2563EB), // Blue   — Ellipse 18
    const Color(0xFFF2922F), // Orange — Ellipse 19
    const Color(0xFF34BD64), // Green  — Ellipse 20
    const Color(0xFFEA2B2B), // Red    — Ellipse 21
    const Color(0xFF9E50F8), // Purple — Ellipse 22
    const Color(0xFFFC75A2), // Pink   — Ellipse 23
  ];

  // 8 icons in 2 rows (wallet icon + piggy banks)
  final List<_IconOption> _icons = [
    _IconOption(icon: Icons.credit_card_outlined, label: 'wallet'),
    _IconOption(icon: Icons.savings_outlined, label: 'piggy1'),
    _IconOption(icon: Icons.account_balance_wallet_outlined, label: 'piggy2'),
    _IconOption(icon: Icons.wallet_outlined, label: 'piggy3'),
    _IconOption(icon: Icons.payment_outlined, label: 'wallet2'),
    _IconOption(icon: Icons.monetization_on_outlined, label: 'piggy4'),
    _IconOption(icon: Icons.volunteer_activism_outlined, label: 'piggy5'),
    _IconOption(icon: Icons.attach_money, label: 'piggy6'),
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionLabel('Tên ví'),
                    const SizedBox(height: 8),
                    _buildNameField(),
                    const SizedBox(height: 28),
                    _buildSectionLabel('Chọn biểu tượng'),
                    const SizedBox(height: 14),
                    _buildIconGrid(),
                    const SizedBox(height: 28),
                    _buildSectionLabel('Chọn màu'),
                    const SizedBox(height: 14),
                    _buildColorPicker(),
                    const SizedBox(height: 28),
                    _buildSectionLabel('Số dư ban đầu'),
                    const SizedBox(height: 8),
                    _buildAmountField(),
                    const SizedBox(height: 48),
                    _buildCreateButton(context),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.arrow_back, size: 24, color: Color(0xFF111827)),
          ),
          const Expanded(
            child: Text(
              'Tạo ví mới',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF111827),
                fontFamily: 'Poppins',
              ),
            ),
          ),
          const SizedBox(width: 24), // balance spacer
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: const Color(0xFF111827),
      ),
    );
  }

  Widget _buildNameField() {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: _nameController,
      builder: (context, value, _) {
        return Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF5F6FA),
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _nameController,
                  maxLength: 30,
                  style: GoogleFonts.poppins(fontSize: 15, color: const Color(0xFF111827)),
                  decoration: InputDecoration(
                    hintText: 'Nhập tên ví',
                    hintStyle: GoogleFonts.poppins(fontSize: 15, color: const Color(0xFFBEC3CE)),
                    border: InputBorder.none,
                    counterText: '',
                    contentPadding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              Text(
                '${value.text.length}/30',
                style: GoogleFonts.poppins(fontSize: 13, color: const Color(0xFFBEC3CE)),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildIconGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _icons.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio: 1,
      ),
      itemBuilder: (context, i) {
        final isSelected = _selectedIconIndex == i;
        return GestureDetector(
          onTap: () => setState(() => _selectedIconIndex = i),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F0FF),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isSelected ? const Color(0xFF2563EB) : Colors.transparent,
                width: 2,
              ),
            ),
            child: Icon(
              _icons[i].icon,
              size: 28,
              color: const Color(0xFF2563EB),
            ),
          ),
        );
      },
    );
  }

  Widget _buildColorPicker() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: _colors.asMap().entries.map((entry) {
        final i = entry.key;
        final color = entry.value;
        final isSelected = _selectedColorIndex == i;
        return GestureDetector(
          onTap: () => setState(() => _selectedColorIndex = i),
          child: Padding(
            padding: EdgeInsets.only(right: i < _colors.length - 1 ? 14 : 0),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: isSelected
                    ? Border.all(color: Colors.white, width: 3)
                    : null,
                boxShadow: isSelected
                    ? [BoxShadow(color: color.withOpacity(0.5), blurRadius: 8, spreadRadius: 1)]
                    : null,
              ),
              child: isSelected
                  ? const Icon(Icons.check, color: Colors.white, size: 18)
                  : null,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAmountField() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF5F6FA),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: GoogleFonts.poppins(fontSize: 15, color: const Color(0xFF111827)),
              decoration: InputDecoration(
                hintText: 'Nhập số tiền',
                hintStyle: GoogleFonts.poppins(fontSize: 15, color: const Color(0xFFBEC3CE)),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: _amountController,
            builder: (_, val, __) {
              final amount = val.text.isEmpty ? '0đ' : '${val.text}đ';
              return Text(
                amount,
                style: GoogleFonts.poppins(fontSize: 13, color: const Color(0xFFBEC3CE)),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCreateButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: () {
          // TODO: call provider to create wallet
          if (_nameController.text.trim().isNotEmpty) {
            Navigator.pop(context);
          } else {
            SnackBarUtils.showTopSnackBar(context, 'Vui lòng nhập tên ví', isSuccess: false);
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2563EB),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
        ),
        child: Text(
          'Tạo ví',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class _IconOption {
  final IconData icon;
  final String label;
  const _IconOption({required this.icon, required this.label});
}
