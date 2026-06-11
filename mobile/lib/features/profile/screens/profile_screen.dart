import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:mobile/features/auth/providers/auth_provider.dart';
import 'package:mobile/features/auth/screens/login_screen.dart';
import 'package:mobile/features/profile/screens/account_info_screen.dart';
import 'package:mobile/features/profile/screens/security_screen.dart';
import 'package:mobile/features/profile/screens/notification_settings_screen.dart';
import 'package:mobile/features/profile/screens/help_support_screen.dart';
import 'package:mobile/core/providers/theme_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;
    final fullName = user?['fullName'] ?? 'Người dùng';
    final email = user?['email'] ?? 'Chưa cập nhật email';
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Text(
                'Cá nhân',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF111827),
                ),
              ),
            ),
            const SizedBox(height: 24),
            _buildProfileHeader(context, fullName, email, user?['avatarUrl'], isDark),
            const SizedBox(height: 32),
            _buildSettingsList(context, authProvider, isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, String fullName, String email, String? avatarUrl, bool isDark) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF111827) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: isDark ? [] : [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF2563EB), width: 2),
            ),
            child: CircleAvatar(
              radius: 36,
              backgroundColor: isDark ? const Color(0xFF1F2937) : Colors.white,
              backgroundImage: (avatarUrl != null && avatarUrl.isNotEmpty)
                  ? NetworkImage(avatarUrl) as ImageProvider
                  : const AssetImage('assets/images/logo.png'),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fullName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AccountInfoScreen()),
            ),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1F2937) : const Color(0xFFE0E7FF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.edit, color: Color(0xFF2563EB), size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsList(BuildContext context, AuthProvider authProvider, bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF111827) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: isDark ? [] : [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        children: [
          _buildSettingsItem(
            context: context,
            icon: Icons.person_outline,
            title: 'Thông tin tài khoản',
            iconColor: const Color(0xFF2563EB),
            bgColor: isDark ? const Color(0xFF1E3A8A) : const Color(0xFFE0E7FF),
            isDark: isDark,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AccountInfoScreen())),
          ),
          _buildDivider(isDark),
          _buildSettingsItem(
            context: context,
            icon: Icons.security,
            title: 'Bảo mật & Mật khẩu',
            iconColor: const Color(0xFF10B981),
            bgColor: isDark ? const Color(0xFF064E3B) : const Color(0xFFD1FAE5),
            isDark: isDark,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SecurityScreen())),
          ),
          _buildDivider(isDark),
          _buildSettingsItem(
            context: context,
            icon: Icons.notifications_none,
            title: 'Cài đặt thông báo',
            iconColor: const Color(0xFFF59E0B),
            bgColor: isDark ? const Color(0xFF78350F) : const Color(0xFFFFEDD5),
            isDark: isDark,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationSettingsScreen())),
          ),
          _buildDivider(isDark),
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return _buildSettingsItem(
                context: context,
                icon: Icons.dark_mode_outlined,
                title: 'Chế độ tối',
                iconColor: const Color(0xFF6366F1),
                bgColor: isDark ? const Color(0xFF312E81) : const Color(0xFFE0E7FF),
                isDark: isDark,
                trailing: Switch(
                  value: themeProvider.isDarkMode,
                  onChanged: (val) {
                    themeProvider.toggleTheme(val);
                  },
                  activeColor: const Color(0xFF2563EB),
                ),
                onTap: () {
                  themeProvider.toggleTheme(!themeProvider.isDarkMode);
                },
              );
            },
          ),
          _buildDivider(isDark),
          _buildSettingsItem(
            context: context,
            icon: Icons.help_outline,
            title: 'Trợ giúp & Hỗ trợ',
            iconColor: const Color(0xFF8B5CF6),
            bgColor: isDark ? const Color(0xFF4C1D95) : const Color(0xFFF3E8FF),
            isDark: isDark,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HelpSupportScreen())),
          ),
          _buildDivider(isDark),
          InkWell(
            onTap: () async {
              // Show confirmation dialog
              final bool? confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  backgroundColor: isDark ? const Color(0xFF1F2937) : Colors.white,
                  title: Text(
                    'Đăng xuất',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black),
                  ),
                  content: Text(
                    'Bạn có chắc chắn muốn đăng xuất?',
                    style: GoogleFonts.poppins(color: isDark ? Colors.white70 : Colors.black87),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: Text(
                        'Hủy',
                        style: GoogleFonts.poppins(color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280)),
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: Text(
                        'Đăng xuất',
                        style: GoogleFonts.poppins(
                          color: const Color(0xFFEF4444),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              );

              if (confirm == true) {
                await authProvider.logout();
                if (context.mounted) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (route) => false,
                  );
                }
              }
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF7F1D1D) : const Color(0xFFFEE2E2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.logout, color: Color(0xFFEF4444), size: 20),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      'Đăng xuất',
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFFEF4444),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider(bool isDark) {
    return Divider(
      color: isDark ? const Color(0xFF374151) : const Color(0xFFF3F4F6),
      height: 1,
      thickness: 1,
      indent: 76,
    );
  }

  Widget _buildSettingsItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required Color iconColor,
    required Color bgColor,
    required bool isDark,
    VoidCallback? onTap,
    Widget? trailing,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: bgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white : const Color(0xFF374151),
                ),
              ),
            ),
            trailing ?? Icon(Icons.chevron_right, color: isDark ? const Color(0xFF6B7280) : const Color(0xFF9CA3AF), size: 20),
          ],
        ),
      ),
    );
  }
}
