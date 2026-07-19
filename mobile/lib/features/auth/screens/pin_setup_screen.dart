import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';
import 'package:mobile/features/auth/providers/auth_provider.dart';
import 'package:mobile/core/utils/snackbar_utils.dart';
import 'package:mobile/core/providers/theme_provider.dart';
import 'package:mobile/features/dashboard/screens/dashboard_screen.dart';

class PinSetupScreen extends StatefulWidget {
  final bool isFromPrompt;
  
  const PinSetupScreen({super.key, this.isFromPrompt = false});

  @override
  State<PinSetupScreen> createState() => _PinSetupScreenState();
}

class _PinSetupScreenState extends State<PinSetupScreen> {
  final TextEditingController _pinController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  
  bool _isConfirming = false;
  String _firstPin = '';

  @override
  void dispose() {
    _pinController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onCompleted(String pin) {
    if (!_isConfirming) {
      setState(() {
        _firstPin = pin;
        _isConfirming = true;
        _pinController.clear();
        _focusNode.requestFocus();
      });
    } else {
      if (pin == _firstPin) {
        _setupPin(pin);
      } else {
        SnackBarUtils.showTopSnackBar(context, 'Mã PIN không khớp. Vui lòng thử lại.', isSuccess: false);
        setState(() {
          _isConfirming = false;
          _firstPin = '';
          _pinController.clear();
          _focusNode.requestFocus();
        });
      }
    }
  }

  void _setupPin(String pin) {
    context.read<AuthProvider>().setupPin(
      pin,
      onSuccess: () {
        SnackBarUtils.showTopSnackBar(context, 'Thiết lập mã PIN thành công', isSuccess: true);
        if (widget.isFromPrompt) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const DashboardScreen()),
          );
        } else {
          Navigator.pop(context);
        }
      },
      onError: (msg) {
        SnackBarUtils.showTopSnackBar(context, msg, isSuccess: false);
        setState(() {
          _isConfirming = false;
          _firstPin = '';
          _pinController.clear();
          _focusNode.requestFocus();
        });
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
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, size: 20, color: subtitleColor),
          onPressed: () {
            if (_isConfirming) {
              setState(() {
                _isConfirming = false;
                _firstPin = '';
                _pinController.clear();
              });
            } else {
              if (widget.isFromPrompt) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const DashboardScreen()),
                );
              } else {
                Navigator.pop(context);
              }
            }
          },
        ),
        title: Text(
          'Thiết lập PIN',
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
                _isConfirming ? 'Xác nhận mã PIN' : 'Nhập mã PIN mới',
                style: GoogleFonts.inter(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _isConfirming 
                    ? 'Nhập lại mã PIN để xác nhận.' 
                    : 'Mã PIN gồm 6 chữ số dùng để đăng nhập và bảo mật.',
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
                      obscureText: true,
                      showCursor: false,
                      keyboardType: TextInputType.number,
                      onCompleted: _onCompleted,
                      autofocus: true,
                    ),
                  );
                }
              ),
            ],
          ),
        ),
      ),
    );
  }
}
