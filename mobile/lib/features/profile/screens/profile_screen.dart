import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:mobile/features/auth/providers/auth_provider.dart';
import 'package:mobile/features/auth/screens/login_screen.dart';
import 'package:mobile/features/profile/screens/account_info_screen.dart';
import 'package:mobile/features/profile/screens/security_screen.dart';
import 'package:mobile/features/profile/screens/notification_settings_screen.dart';
import 'package:mobile/features/profile/screens/help_support_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;
    final fullName = user?['fullName'] ?? 'Người dùng';
    final email = user?['email'] ?? 'Chưa cập nhật email';

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
                  color: const Color(0xFF111827),
                ),
              ),
            ),
            const SizedBox(height: 24),
            _buildProfileHeader(fullName, email),
            const SizedBox(height: 32),
            _buildSettingsList(context, authProvider),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(String fullName, String email) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
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
        children: [
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF2563EB), width: 2),
            ),
            child: const CircleAvatar(
              radius: 36,
              backgroundImage: AssetImage('assets/images/Logo.png'),
              backgroundColor: Colors.white,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fullName,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  email,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: const Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFE0E7FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.edit, color: Color(0xFF2563EB), size: 20),
          )
        ],
      ),
    );
  }

  Widget _buildSettingsList(BuildContext context, AuthProvider authProvider) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
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
      child: Column(
        children: [
          _buildSettingsItem(
            context: context,
            icon: Icons.person_outline,
            title: 'Thông tin tài khoản',
            iconColor: const Color(0xFF2563EB),
            bgColor: const Color(0xFFE0E7FF),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AccountInfoScreen())),
          ),
          _buildDivider(),
          _buildSettingsItem(
            context: context,
            icon: Icons.security,
            title: 'Bảo mật & Mật khẩu',
            iconColor: const Color(0xFF10B981),
            bgColor: const Color(0xFFD1FAE5),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SecurityScreen())),
          ),
          _buildDivider(),
          _buildSettingsItem(
            context: context,
            icon: Icons.notifications_none,
            title: 'Cài đặt thông báo',
            iconColor: const Color(0xFFF59E0B),
            bgColor: const Color(0xFFFFEDD5),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationSettingsScreen())),
          ),
          _buildDivider(),
          _buildSettingsItem(
            context: context,
            icon: Icons.help_outline,
            title: 'Trợ giúp & Hỗ trợ',
            iconColor: const Color(0xFF8B5CF6),
            bgColor: const Color(0xFFF3E8FF),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HelpSupportScreen())),
          ),
          _buildDivider(),
          InkWell(
            onTap: () async {
              // Show confirmation dialog
              final bool? confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(
                    'Đăng xuất',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                  ),
                  content: Text(
                    'Bạn có chắc chắn muốn đăng xuất?',
                    style: GoogleFonts.poppins(),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: Text(
                        'Hủy',
                        style: GoogleFonts.poppins(color: const Color(0xFF6B7280)),
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
                    decoration: const BoxDecoration(
                      color: Color(0xFFFEE2E2),
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

  Widget _buildDivider() {
    return const Divider(
      color: Color(0xFFF3F4F6),
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
    VoidCallback? onTap,
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
                  color: const Color(0xFF374151),
                ),
              ),
            ),
            const Icon(Icons.chevron_right, color: Color(0xFF9CA3AF), size: 20),
          ],
        ),
      ),
    );
  }
}
