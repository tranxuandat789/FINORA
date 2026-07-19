import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';
import 'package:mobile/features/auth/providers/auth_provider.dart';
import 'package:mobile/core/utils/snackbar_utils.dart';
import 'package:mobile/core/providers/theme_provider.dart';
import 'package:mobile/features/auth/screens/otp_screen.dart';
import 'package:mobile/features/auth/screens/pin_reset_screen.dart';

class PinChangeScreen extends StatefulWidget {
  const PinChangeScreen({super.key});

  @override
  State<PinChangeScreen> createState() => _PinChangeScreenState();
}

class _PinChangeScreenState extends State<PinChangeScreen> {
  final TextEditingController _pinController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  
  int _step = 0; // 0: Old PIN, 1: New PIN, 2: Confirm New PIN
  String _oldPin = '';
  String _newPin = '';
  
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
    if (_step == 0) {
      // Verify old PIN before proceeding
      context.read<AuthProvider>().verifyPin(
        pin,
        onSuccess: () {
          setState(() {
            _oldPin = pin;
            _step = 1;
            _pinController.clear();
            _focusNode.requestFocus();
          });
        },
        onError: (msg) {
          setState(() {
            _hasError = true;
            _errorText = 'Mã PIN hiện tại không chính xác';
          });
          _focusNode.requestFocus();
        },
      );
    } else if (_step == 1) {
      // Finished entering new PIN
      if (pin == _oldPin) {
        setState(() {
          _hasError = true;
          _errorText = 'Mã PIN mới không được giống mã PIN cũ.';
        });
        _focusNode.requestFocus();
      } else {
        setState(() {
          _newPin = pin;
          _step = 2;
          _pinController.clear();
          _focusNode.requestFocus();
        });
      }
    } else if (_step == 2) {
      // Finished confirming new PIN
      if (pin == _newPin) {
        _changePin(_oldPin, _newPin);
      } else {
        setState(() {
          _step = 1;
          _newPin = '';
          _hasError = true;
          _errorText = 'Mã PIN xác nhận không khớp.';
        });
        _pinController.clear();
        _focusNode.requestFocus();
      }
    }
  }

  void _changePin(String oldPin, String newPin) {
    context.read<AuthProvider>().changePin(
      oldPin,
      newPin,
      onSuccess: () {
        SnackBarUtils.showTopSnackBar(context, 'Đổi mã PIN thành công', isSuccess: true);
        Navigator.pop(context);
      },
      onError: (msg) {
        setState(() {
          _step = 0;
          _oldPin = '';
          _newPin = '';
          _hasError = true;
          _errorText = msg;
        });
        _pinController.clear();
        _focusNode.requestFocus();
      },
    );
  }

  void _forgotPin() {
    final auth = context.read<AuthProvider>();
    final email = auth.user?['email'] as String? ?? '';
    if (email.isEmpty) {
      SnackBarUtils.showTopSnackBar(
        context,
        'Không tìm thấy email. Vui lòng đăng xuất và đăng nhập lại.',
        isSuccess: false,
      );
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
                ).then((_) {
                  // Sau reset PIN thành công → quay về màn đổi PIN từ đầu
                  if (mounted) Navigator.pop(context);
                });
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

    String title = '';
    String subtitle = '';

    if (_step == 0) {
      title = 'Nhập mã PIN hiện tại';
      subtitle = 'Vui lòng nhập mã PIN hiện tại của bạn để tiếp tục.';
    } else if (_step == 1) {
      title = 'Nhập mã PIN mới';
      subtitle = 'Mã PIN gồm 6 chữ số dùng để đăng nhập và bảo mật.';
    } else {
      title = 'Xác nhận mã PIN mới';
      subtitle = 'Nhập lại mã PIN mới để xác nhận.';
    }

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, size: 20, color: subtitleColor),
          onPressed: () {
            if (_step > 0) {
              setState(() {
                _step--;
                _pinController.clear();
              });
            } else {
              Navigator.pop(context);
            }
          },
        ),
        title: Text(
          'Đổi mã PIN',
          style: GoogleFonts.inter(
            color: textColor,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  color: subtitleColor,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              Consumer<AuthProvider>(
                builder: (context, auth, _) {
                  if (auth.isLoading) {
                    return const Center(
                      child: CircularProgressIndicator(color: Color(0xFF2563EB)),
                    );
                  }
                  return SizedBox(
                    width: double.infinity,
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
              const SizedBox(height: 20),

              // Nút Quên mã PIN — chỉ hiện ở bước 0
              if (_step == 0)
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
            ],
          ),
        ),
      ),
    );
  }
}
