import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:mobile/core/providers/theme_provider.dart';
import 'package:mobile/features/auth/providers/auth_provider.dart';
import 'package:mobile/features/profile/providers/profile_provider.dart';
import 'package:mobile/core/utils/snackbar_utils.dart';

class SecurityScreen extends StatefulWidget {
  const SecurityScreen({super.key});

  @override
  State<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends State<SecurityScreen> {
  final _currentPwCtrl = TextEditingController();
  final _newPwCtrl = TextEditingController();
  final _confirmPwCtrl = TextEditingController();
  bool _showCurrent = false;
  bool _showNew = false;
  bool _showConfirm = false;

  @override
  void dispose() {
    _currentPwCtrl.dispose();
    _newPwCtrl.dispose();
    _confirmPwCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit(bool isGoogleUser) async {
    final newPw = _newPwCtrl.text;
    final confirmPw = _confirmPwCtrl.text;

    if (!isGoogleUser && _currentPwCtrl.text.isEmpty) {
      SnackBarUtils.showTopSnackBar(context, 'Vui lòng nhập mật khẩu hiện tại', isSuccess: false);
      return;
    }
    if (newPw.isEmpty) {
      SnackBarUtils.showTopSnackBar(context, 'Vui lòng nhập mật khẩu mới', isSuccess: false);
      return;
    }
    if (newPw.length < 8) {
      SnackBarUtils.showTopSnackBar(context, 'Mật khẩu phải có ít nhất 8 ký tự', isSuccess: false);
      return;
    }
    if (!RegExp(r'[A-Z]').hasMatch(newPw)) {
      SnackBarUtils.showTopSnackBar(context, 'Mật khẩu phải chứa ít nhất 1 chữ viết hoa', isSuccess: false);
      return;
    }
    if (!RegExp(r'[^a-zA-Z0-9]').hasMatch(newPw)) {
      SnackBarUtils.showTopSnackBar(context, 'Mật khẩu phải chứa ít nhất 1 ký tự đặc biệt', isSuccess: false);
      return;
    }
    if (newPw != confirmPw) {
      SnackBarUtils.showTopSnackBar(context, 'Mật khẩu xác nhận không khớp', isSuccess: false);
      return;
    }

    final profileProvider = context.read<ProfileProvider>();
    await profileProvider.changePassword(
      currentPassword: isGoogleUser ? null : _currentPwCtrl.text,
      newPassword: newPw,
      confirmPassword: confirmPw,
      onSuccess: () {
        // Sau khi Google user set pass thành công → đánh dấu là local user
        if (isGoogleUser) {
          context.read<AuthProvider>().updateUserField('isGoogleUser', false);
        }
        SnackBarUtils.showTopSnackBar(context, 'Cập nhật mật khẩu thành công!', isSuccess: true);
        _currentPwCtrl.clear();
        _newPwCtrl.clear();
        _confirmPwCtrl.clear();
        Navigator.pop(context);
      },
      onError: (msg) {
        SnackBarUtils.showTopSnackBar(context, msg, isSuccess: false);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final isGoogleUser = user?['isGoogleUser'] == true;
    final isLoading = context.watch<ProfileProvider>().isLoading;

    final isDark = context.watch<ThemeProvider>().isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF1F2937) : const Color(0xFFF5F6FA),
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context, isDark),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isGoogleUser) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1E3A8A) : const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: isDark ? const Color(0xFF3B82F6) : const Color(0xFFBFDBFE)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.info_outline, color: Color(0xFF3B82F6), size: 18),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Bạn đang đặt mật khẩu cho tài khoản Google. Sau khi hoàn tất, bạn có thể đăng nhập bằng email và mật khẩu.',
                                style: GoogleFonts.inter(
                                    fontSize: 12.5, color: isDark ? const Color(0xFF93C5FD) : const Color(0xFF1E40AF), height: 1.4),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                    Text('Đổi mật khẩu',
                        style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : const Color(0xFF111827))),
                    const SizedBox(height: 12),
                    _buildPasswordCard(isGoogleUser, isDark),
                    const SizedBox(height: 28),
                    _buildSaveButton(isGoogleUser, isLoading),
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
    return Container(
      color: isDark ? const Color(0xFF111827) : Colors.white,
      padding: const EdgeInsets.fromLTRB(8, 12, 16, 12),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : const Color(0xFF111827)),
          ),
          Expanded(
            child: Text('Bảo mật & Mật khẩu',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                    fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF111827))),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildPasswordCard(bool isGoogleUser, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF111827) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: isDark ? [] : [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        children: [
          if (!isGoogleUser) ...[
            _buildPwField('Mật khẩu hiện tại', _currentPwCtrl, _showCurrent,
                () => setState(() => _showCurrent = !_showCurrent), isDark),
            const SizedBox(height: 16),
          ],
          _buildPwField('Mật khẩu mới', _newPwCtrl, _showNew,
              () => setState(() => _showNew = !_showNew), isDark),
          const SizedBox(height: 16),
          _buildPwField('Xác nhận mật khẩu mới', _confirmPwCtrl, _showConfirm,
              () => setState(() => _showConfirm = !_showConfirm), isDark),
        ],
      ),
    );
  }

  Widget _buildPwField(
      String label, TextEditingController ctrl, bool show, VoidCallback toggle, bool isDark) {
    return TextField(
      controller: ctrl,
      obscureText: !show,
      style: GoogleFonts.inter(fontSize: 14, color: isDark ? Colors.white : const Color(0xFF111827)),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.inter(fontSize: 13, color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280)),
        filled: true,
        fillColor: isDark ? const Color(0xFF374151) : const Color(0xFFF9FAFB),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: isDark ? const Color(0xFF4B5563) : const Color(0xFFE5E7EB))),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: isDark ? const Color(0xFF60A5FA) : const Color(0xFF2563EB), width: 1.5)),
        suffixIcon: IconButton(
          icon: Icon(
              show ? Icons.visibility_outlined : Icons.visibility_off_outlined,
              color: const Color(0xFF9CA3AF),
              size: 20),
          onPressed: toggle,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  Widget _buildSaveButton(bool isGoogleUser, bool isLoading) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: isLoading ? null : () => _submit(isGoogleUser),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2563EB),
          disabledBackgroundColor: const Color(0xFF93C5FD),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
        ),
        child: isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : Text(
                isGoogleUser ? 'Đặt mật khẩu' : 'Cập nhật mật khẩu',
                style: GoogleFonts.inter(
                    fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
              ),
      ),
    );
  }
}
