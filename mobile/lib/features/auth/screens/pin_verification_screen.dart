import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';
import 'package:mobile/features/auth/providers/auth_provider.dart';
import 'package:mobile/core/utils/snackbar_utils.dart';
import 'package:mobile/core/providers/theme_provider.dart';
import 'package:mobile/features/auth/screens/otp_screen.dart';
import 'package:mobile/features/auth/screens/pin_reset_screen.dart';

class PinVerificationScreen extends StatefulWidget {
  final VoidCallback onSuccess;
  final bool isRemoving;
  final bool isEnabling;
  
  const PinVerificationScreen({
    super.key,
    required this.onSuccess,
    this.isRemoving = false,
    this.isEnabling = false,
  });

  @override
  State<PinVerificationScreen> createState() => _PinVerificationScreenState();
}

class _PinVerificationScreenState extends State<PinVerificationScreen> {
  final TextEditingController _pinController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _hasError = false;
  String _errorText = '';

  @override
  void initState() {
    super.initState();
    _pinController.addListener(() {
      if (_hasError && _pinController.text.isNotEmpty) {
        setState(() {
          _hasError = false;
          _errorText = '';
        });
      }
    });
  }

  @override
  void dispose() {
    _pinController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onCompleted(String pin) {
    if (widget.isRemoving) {
      context.read<AuthProvider>().removePin(
        pin,
        onSuccess: () {
          if (!mounted) return;
          widget.onSuccess();
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
    } else if (widget.isEnabling) {
      context.read<AuthProvider>().enablePin(
        pin,
        onSuccess: () {
          if (!mounted) return;
          widget.onSuccess();
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
    } else {
      context.read<AuthProvider>().verifyPin(
        pin,
        onSuccess: () {
          if (!mounted) return;
          widget.onSuccess();
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
  }

  void _forgotPin() {
    final auth = context.read<AuthProvider>();
    final email = auth.user?['email'];
    
    if (email == null) {
      SnackBarUtils.showTopSnackBar(context, 'Không tìm thấy thông tin email. Vui lòng đăng nhập lại.', isSuccess: false);
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
                // Pop OtpScreen
                Navigator.pop(ctx);
                // Push PinResetScreen
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

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDarkMode;
    
    final bgColor = isDark ? const Color(0xFF111827) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF111827);
    final subtitleColor = isDark ? const Color(0xFF9CA3AF) : const Color(0xFF4B5563);
    final pinBgColor = isDark ? const Color(0xFF1F2937) : const Color(0xFFF9FAFB);
    final pinBorderColor = isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB);

    final defaultPinTheme = PinTheme(
      width: 44,
      height: 56,
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

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        automaticallyImplyLeading: widget.isRemoving || widget.isEnabling,
        iconTheme: IconThemeData(
          color: isDark ? Colors.white : const Color(0xFF111827),
        ),
        title: Text(
          widget.isRemoving
              ? 'Tắt mã PIN'
              : widget.isEnabling
                  ? 'Bật mã PIN'
                  : 'Xác minh mã PIN',
          style: GoogleFonts.inter(
            color: textColor,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: (widget.isRemoving || widget.isEnabling) ? [
          const SizedBox(width: 48), // Balance the back button for center alignment
        ] : [
          Consumer<AuthProvider>(
            builder: (context, auth, _) {
              return TextButton(
                onPressed: () {
                  auth.logout();
                },
                child: Text(
                  'Đăng xuất',
                  style: GoogleFonts.inter(
                    color: const Color(0xFFEF4444),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            }
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
                  const SizedBox(height: 60),
                  Text(
                    widget.isRemoving
                        ? 'Nhập mã PIN hiện tại'
                        : widget.isEnabling
                            ? 'Xác nhận mã PIN'
                            : 'Nhập mã PIN',
                    style: GoogleFonts.inter(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: textColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.isRemoving
                        ? 'Vui lòng nhập mã PIN hiện tại để tắt bảo vệ.'
                        : widget.isEnabling
                            ? 'Nhập mã PIN của bạn để bật lại bảo vệ.'
                            : 'Vui lòng nhập mã PIN để mở khóa ứng dụng.',
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      color: subtitleColor,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 56),
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
                    }
                  ),
                  const SizedBox(height: 40),
                  Consumer<AuthProvider>(
                    builder: (context, auth, _) {
                      if (auth.isLoading) return const SizedBox.shrink();
                      // Chỉ hiện nút "Quên mã PIN?" khi đang xác minh đăng nhập bình thường
                      if (widget.isRemoving || widget.isEnabling) {
                        return const SizedBox.shrink();
                      }
                      return TextButton(
                        onPressed: _forgotPin,
                        child: Text(
                          'Quên mã PIN?',
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF2563EB),
                          ),
                        ),
                      );
                    }
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
