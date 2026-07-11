import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile/features/home/screens/create_wallet_screen.dart';
import 'package:provider/provider.dart';
import 'package:mobile/core/providers/theme_provider.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  // Sample wallets — replace with real data from provider
  final List<_WalletItem> _wallets = [
    _WalletItem(name: 'Ví chính', amount: 25000000, icon: Icons.credit_card_outlined, iconColor: const Color(0xFF2563EB), bgColor: const Color(0xFFE8EEFF), isDefault: true),
    _WalletItem(name: 'Ví chi tiêu', amount: 25000000, icon: Icons.credit_card_outlined, iconColor: const Color(0xFF2563EB), bgColor: const Color(0xFFE8EEFF), isDefault: false),
    _WalletItem(name: 'Ví tiết kiệm', amount: 25000000, icon: Icons.savings_outlined, iconColor: const Color(0xFF34BD64), bgColor: const Color(0xFFE6FAF0), isDefault: false),
    _WalletItem(name: 'Ví đầu tư', amount: 25000000, icon: Icons.savings_outlined, iconColor: const Color(0xFF9E50F8), bgColor: const Color(0xFFF3E8FF), isDefault: false),
    _WalletItem(name: 'Ví du lịch', amount: 25000000, icon: Icons.flight_outlined, iconColor: const Color(0xFFFC75A2), bgColor: const Color(0xFFFFE8F0), isDefault: false),
  ];

  String _formatAmount(double amount) {
    final formatter = amount.toInt().toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
    );
    return '${formatter}đ';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDarkMode;
    final totalBalance = _wallets.fold(0.0, (sum, w) => sum + w.amount);
    final activeCount = _wallets.length;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF111827) : const Color(0xFFF5F6FA),
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context, isDark),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    _buildBalanceCard(totalBalance, activeCount),
                    const SizedBox(height: 28),
                    _buildWalletList(isDark),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Icon(Icons.arrow_back, size: 24, color: isDark ? Colors.white : const Color(0xFF111827)),
          ),
          Expanded(
            child: Text(
              'Ví của tôi',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF111827),
                fontFamily: 'Poppins',
              ),
            ),
          ),
          GestureDetector(
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CreateWalletScreen()),
              );
            },
            child: const Icon(Icons.add, size: 26, color: Color(0xFF2563EB)),
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceCard(double total, int count) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 22, 16, 22),
      decoration: BoxDecoration(
        color: const Color(0xFF2563EB),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tổng số dư',
                  style: GoogleFonts.inter(
                    color: Colors.white.withOpacity(0.85),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _formatAmount(total),
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  '$count ví đang hoạt động',
                  style: GoogleFonts.inter(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Image.asset(
            'assets/images/DashboardIcon.png',
            width: 100,
            height: 100,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => const Icon(
              Icons.account_balance_wallet,
              size: 80,
              color: Colors.white38,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWalletList(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Danh sách ví',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : const Color(0xFF111827),
          ),
        ),
        const SizedBox(height: 14),
        Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1F2937) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: isDark ? [] : [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: _wallets.asMap().entries.map((entry) {
              final i = entry.key;
              final wallet = entry.value;
              return Column(
                children: [
                  _buildWalletRow(wallet, isDark),
                  if (i < _wallets.length - 1)
                    Divider(
                      color: isDark ? const Color(0xFF374151) : const Color(0xFFF3F4F6),
                      height: 1,
                      indent: 72,
                    ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildWalletRow(_WalletItem wallet, bool isDark) {
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            // Icon
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isDark ? wallet.iconColor.withOpacity(0.2) : wallet.bgColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(wallet.icon, color: wallet.iconColor, size: 22),
            ),
            const SizedBox(width: 14),
            // Name & badge
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    wallet.name,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : const Color(0xFF111827),
                    ),
                  ),
                  if (wallet.isDefault) ...[
                    const SizedBox(height: 3),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E3A8A) : const Color(0xFFE8EEFF),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Mặc định',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: isDark ? const Color(0xFF60A5FA) : const Color(0xFF2563EB),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            // Amount & arrow
            Row(
              children: [
                Text(
                  _formatAmount(wallet.amount),
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF111827),
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.chevron_right, size: 20, color: Color(0xFF9CA3AF)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _WalletItem {
  final String name;
  final double amount;
  final IconData icon;
  final Color iconColor;
  final Color bgColor;
  final bool isDefault;

  const _WalletItem({
    required this.name,
    required this.amount,
    required this.icon,
    required this.iconColor,
    required this.bgColor,
    required this.isDefault,
  });
}
