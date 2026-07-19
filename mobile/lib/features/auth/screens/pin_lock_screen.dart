import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';
import 'package:mobile/features/auth/providers/auth_provider.dart';
import 'package:mobile/core/providers/theme_provider.dart';
import 'package:mobile/features/auth/screens/login_screen.dart';
import 'package:mobile/features/dashboard/screens/dashboard_screen.dart';
import 'package:mobile/core/utils/snackbar_utils.dart';
import 'pin_reset_screen.dart';
import 'package:mobile/features/auth/screens/otp_screen.dart';

/// Màn hình khóa PIN khi mở app (cold start).
/// Không có nút back — user phải nhập PIN hoặc đăng xuất.
class PinLockScreen extends StatefulWidget {
  const PinLockScreen({super.key});

  @override
  State<PinLockScreen> createState() => _PinLockScreenState();
}

class _PinLockScreenState extends State<PinLockScreen> {
  final _pinController = TextEditingController();
  final _focusNode = FocusNode();
  bool _hasError = false;
  String _errorText = '';

  @override
  void dispose() {
    _pinController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onCompleted(String pin) {
    context.read<AuthProvider>().verifyPin(
      pin,
      onSuccess: () {
        if (!mounted) return;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const DashboardScreen()),
        );
      },
      onError: (msg) {
        if (!mounted) return;
        _pinController.clear();
        setState(() {
          _hasError = true;
          _errorText = msg;
        });
        _focusNode.requestFocus();
      },
    );
  }

  void _forgotPin() {
    final auth = context.read<AuthProvider>();
    final email = auth.user?['email'] as String? ?? '';
    if (email.isEmpty) {
      SnackBarUtils.showTopSnackBar(context, 'Không tìm thấy email. Vui lòng đăng xuất và đăng nhập lại.', isSuccess: false);
      return;
    }

    auth.sendOtp(
      email,
      'forgot_pin',
      onSuccess: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => OtpScreen(
              email: email,
              purpose: 'forgot_pin',
              onVerified: (ctx, resetToken) {
                Navigator.pop(ctx);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PinResetScreen(
                      email: email,
                      resetToken: resetToken,
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
      onError: (msg) {
        SnackBarUtils.showTopSnackBar(context, msg, isSuccess: false);
      },
    );
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          'Đăng xuất',
          style: GoogleFonts.inter(fontWeight: FontWeight.w700),
        ),
        content: Text(
          'Bạn có chắc muốn đăng xuất không?',
          style: GoogleFonts.inter(),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Hủy', style: GoogleFonts.inter()),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await context.read<AuthProvider>().logout();
              if (mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
            child: Text(
              'Đăng xuất',
              style: GoogleFonts.inter(
                color: Colors.red,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDarkMode;

    final bgColor = isDark ? const Color(0xFF111827) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF111827);
    final subtitleColor = isDark ? const Color(0xFF9CA3AF) : const Color(0xFF4B5563);
    final pinBgColor = isDark ? const Color(0xFF1F2937) : const Color(0xFFF9FAFB);
    final pinBorderColor = isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB);

    final defaultPinTheme = PinTheme(
      width: 48,
      height: 58,
      textStyle: GoogleFonts.inter(
        fontSize: 22,
        color: textColor,
        fontWeight: FontWeight.w600,
      ),
      decoration: BoxDecoration(
        color: pinBgColor,
        border: Border.all(color: pinBorderColor, width: 1.5),
        borderRadius: BorderRadius.circular(12),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyDecorationWith(
      border: Border.all(color: const Color(0xFF2563EB), width: 2),
      borderRadius: BorderRadius.circular(12),
    );

    return PopScope(
      canPop: false, // Chặn back button
      child: Scaffold(
        backgroundColor: bgColor,
        appBar: AppBar(
          backgroundColor: bgColor,
          elevation: 0,
          automaticallyImplyLeading: false,
          actions: [
            TextButton(
              onPressed: _logout,
              child: Text(
                'Đăng xuất',
                style: GoogleFonts.inter(
                  color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: SizedBox(
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),

                    // Logo app
                    Image.asset(
                      'assets/images/logo.png',
                      width: 72,
                      height: 72,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 24),

                    // Title
                    Text(
                      'Nhập mã PIN',
                      style: GoogleFonts.inter(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        color: textColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),

                    // Subtitle
                    Text(
                      'Nhập mã PIN để truy cập ứng dụng.',
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        color: subtitleColor,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 52),

                    // PIN Input
                    Consumer<AuthProvider>(
                      builder: (context, auth, _) {
                        if (auth.isLoading) {
                          return const SizedBox(
                            height: 80,
                            child: Center(
                              child: CircularProgressIndicator(color: Color(0xFF2563EB)),
                            ),
                          );
                        }
                        return Center(
                          child: Pinput(
                            length: 6,
                            mainAxisAlignment: MainAxisAlignment.center,
                            controller: _pinController,
                            focusNode: _focusNode,
                            defaultPinTheme: defaultPinTheme,
                            focusedPinTheme: focusedPinTheme,
                            errorPinTheme: defaultPinTheme.copyDecorationWith(
                              border: Border.all(color: const Color(0xFFEF4444), width: 1.5),
                            ),
                            forceErrorState: _hasError,
                            errorText: _hasError ? _errorText : null,
                            errorTextStyle: GoogleFonts.inter(
                              fontSize: 13,
                              color: const Color(0xFFEF4444),
                            ),
                            obscureText: true,
                            showCursor: false,
                            keyboardType: TextInputType.number,
                            onCompleted: _onCompleted,
                            autofocus: true,
                            onTap: () {
                              if (_hasError) {
                                _pinController.clear();
                                setState(() {
                                  _hasError = false;
                                  _errorText = '';
                                });
                              }
                            },
                            onChanged: (value) {
                              if (_hasError) {
                                setState(() {
                                  _hasError = false;
                                  _errorText = '';
                                });
                              }
                            },
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 36),

                    // Quên PIN
                    TextButton(
                      onPressed: _forgotPin,
                      child: Text(
                        'Quên mã PIN?',
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF2563EB),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
