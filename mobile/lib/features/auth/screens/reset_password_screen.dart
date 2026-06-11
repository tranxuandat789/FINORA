import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:mobile/features/auth/providers/auth_provider.dart';
import 'package:mobile/features/auth/screens/login_screen.dart';
import 'package:mobile/core/utils/snackbar_utils.dart';

/// Màn hình đặt lại mật khẩu hiển thị sau khi verify OTP thành công.
/// Hoạt động cho cả local user và Google user (Option B  Edual login).
class ResetPasswordScreen extends StatefulWidget {
  final String email;
  final String resetToken;

  const ResetPasswordScreen({
    super.key,
    required this.email,
    required this.resetToken,
  });

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _newPwCtrl = TextEditingController();
  final _confirmPwCtrl = TextEditingController();
  bool _showNew = false;
  bool _showConfirm = false;

  @override
  void dispose() {
    _newPwCtrl.dispose();
    _confirmPwCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    final pw = _newPwCtrl.text;

    if (pw.isEmpty) {
      SnackBarUtils.showTopSnackBar(context, 'Vui lòng nhập mật khẩu mới', isSuccess: false);
      return;
    }
    if (pw.length < 8) {
      SnackBarUtils.showTopSnackBar(context, 'Mật khẩu phải có ít nhất 8 ký tự', isSuccess: false);
      return;
    }
    if (!RegExp(r'[A-Z]').hasMatch(pw)) {
      SnackBarUtils.showTopSnackBar(context, 'Mật khẩu phải chứa ít nhất 1 chữ viết hoa', isSuccess: false);
      return;
    }
    if (!RegExp(r'[^a-zA-Z0-9]').hasMatch(pw)) {
      SnackBarUtils.showTopSnackBar(context, 'Mật khẩu phải chứa ít nhất 1 ký tự đặc biệt', isSuccess: false);
      return;
    }
    if (pw != _confirmPwCtrl.text) {
      SnackBarUtils.showTopSnackBar(context, 'Mật khẩu xác nhận không khớp', isSuccess: false);
      return;
    }

    context.read<AuthProvider>().resetPassword(
      widget.email,
      widget.resetToken,
      _newPwCtrl.text,
      _confirmPwCtrl.text,
      onSuccess: () {
        SnackBarUtils.showTopSnackBar(
            context, 'Đặt lại mật khẩu thành công!',
            isSuccess: true);
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      },
      onError: (msg) {
        SnackBarUtils.showTopSnackBar(context, msg, isSuccess: false);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Logo
              Row(children: [
                Image.asset('assets/images/logo.png', width: 24, height: 24),
                const SizedBox(width: 8),
                Text('Finora',
                    style: GoogleFonts.poppins(
                        fontSize: 20, fontWeight: FontWeight.w600)),
              ]),
              const SizedBox(height: 40),

              // Title
              Text('Mật khẩu mới',
                  style: GoogleFonts.poppins(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: Colors.black)),
              const SizedBox(height: 8),
              Text(
                'Mật khẩu phải có ít nhất 8 ký tự, 1 chữ hoa và 1 ký tự đặc biệt.',
                style: GoogleFonts.poppins(
                    fontSize: 15,
                    color: const Color(0xFF4B5563),
                    height: 1.5),
              ),
              const SizedBox(height: 32),

              // New password
              _buildPwField('Mật khẩu mới', _newPwCtrl, _showNew,
                  () => setState(() => _showNew = !_showNew)),
              const SizedBox(height: 16),
              _buildPwField('Xác nhận mật khẩu mới', _confirmPwCtrl,
                  _showConfirm, () => setState(() => _showConfirm = !_showConfirm)),
              const SizedBox(height: 36),

              // Submit
              Consumer<AuthProvider>(
                builder: (context, auth, _) => SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: auth.isLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      elevation: 0,
                    ),
                    child: auth.isLoading
                        ? const CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2)
                        : Text('Xác nhận đặt lại',
                            style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPwField(String label, TextEditingController ctrl, bool show,
      VoidCallback toggle) {
    return TextField(
      controller: ctrl,
      obscureText: !show,
      style: GoogleFonts.poppins(
          fontSize: 15, color: const Color(0xFF111827)),
      decoration: InputDecoration(
        labelText: label,
        labelStyle:
            GoogleFonts.poppins(fontSize: 14, color: const Color(0xFF6B7280)),
        filled: true,
        fillColor: const Color(0xFFF9FAFB),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide:
                const BorderSide(color: Color(0xFF2563EB), width: 1.5)),
        suffixIcon: IconButton(
          icon: Icon(
              show
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
              color: const Color(0xFF9CA3AF)),
          onPressed: toggle,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }
}
