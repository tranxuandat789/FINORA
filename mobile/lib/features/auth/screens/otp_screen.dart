import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:mobile/features/auth/providers/auth_provider.dart';
import 'package:mobile/core/utils/snackbar_utils.dart';

/// Màn hình nhập mã OTP 6 số dùng chung cho cả đăng ký và quên mật khẩu.
///
/// [email]  Eemail nhận OTP
/// [purpose]  E"register" | "forgot_password"
/// [onVerified]  Ecallback khi xác minh thành công, nhận (resetToken)
class OtpScreen extends StatefulWidget {
  final String email;
  final String purpose;
  final void Function(String resetToken) onVerified;

  const OtpScreen({
    super.key,
    required this.email,
    required this.purpose,
    required this.onVerified,
  });

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  int _secondsLeft = 60;
  bool _canResend = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final c in _controllers) c.dispose();
    for (final f in _focusNodes) f.dispose();
    super.dispose();
  }

  void _startTimer() {
    _secondsLeft = 60;
    _canResend = false;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) { t.cancel(); return; }
      setState(() {
        if (_secondsLeft > 0) {
          _secondsLeft--;
        } else {
          _canResend = true;
          t.cancel();
        }
      });
    });
  }

  String get _otp => _controllers.map((c) => c.text).join();

  void _onChanged(String value, int index) {
    if (value.length == 1 && index < 5) {
      _focusNodes[index + 1].requestFocus();
    }
    if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
    // Auto-submit when all 6 digits filled
    if (_otp.length == 6) {
      _verify();
    }
  }

  void _verify() {
    if (_otp.length < 6) {
      SnackBarUtils.showTopSnackBar(context, 'Vui lòng nhập đủ 6 chữ số', isSuccess: false);
      return;
    }
    context.read<AuthProvider>().verifyOtp(
      widget.email,
      _otp,
      widget.purpose,
      onSuccess: (resetToken) {
        widget.onVerified(resetToken);
      },
      onError: (msg) {
        SnackBarUtils.showTopSnackBar(context, msg, isSuccess: false);
        // Clear OTP fields on error
        for (final c in _controllers) { c.clear(); }
        _focusNodes[0].requestFocus();
      },
    );
  }

  void _resend() {
    if (!_canResend) return;
    context.read<AuthProvider>().sendOtp(
      widget.email,
      widget.purpose,
      onSuccess: () {
        _startTimer();
        SnackBarUtils.showTopSnackBar(context, 'Đã gửi lại mã OTP!', isSuccess: true);
      },
      onError: (msg) {
        SnackBarUtils.showTopSnackBar(context, msg, isSuccess: false);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isRegister = widget.purpose == 'register';

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(children: [
                Image.asset('assets/images/logo.png', width: 24, height: 24),
                const SizedBox(width: 8),
                Text('Finora', style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600)),
              ]),
              const SizedBox(height: 40),

              // Back
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Row(children: [
                  const Icon(Icons.arrow_back_ios, size: 16, color: Color(0xFF6B7280)),
                  Text('Quay lại', style: GoogleFonts.poppins(fontSize: 14, color: const Color(0xFF6B7280))),
                ]),
              ),
              const SizedBox(height: 32),

              // Title
              Text(
                isRegister ? 'Xác nhận email' : 'Nhập mã xác nhận',
                style: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.w700, color: Colors.black),
              ),
              const SizedBox(height: 8),
              RichText(
                text: TextSpan(
                  style: GoogleFonts.poppins(fontSize: 15, color: const Color(0xFF4B5563), height: 1.5),
                  children: [
                    const TextSpan(text: 'Chúng tôi đã gửi mã OTP 6 số đến\n'),
                    TextSpan(
                      text: widget.email,
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: const Color(0xFF2563EB)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              // OTP boxes
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(6, (i) => _buildOtpBox(i)),
              ),
              const SizedBox(height: 40),

              // Verify button
              Consumer<AuthProvider>(
                builder: (context, auth, _) => SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: auth.isLoading ? null : _verify,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      elevation: 0,
                    ),
                    child: auth.isLoading
                        ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                        : Text('Xác nhận', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // Resend
              Center(
                child: Column(children: [
                  Text('Không nhận được mã?', style: GoogleFonts.poppins(fontSize: 14, color: const Color(0xFF6B7280))),
                  const SizedBox(height: 6),
                  GestureDetector(
                    onTap: _canResend ? _resend : null,
                    child: Text(
                      _canResend ? 'Gửi lại mã' : 'Gửi lại sau ${_secondsLeft}s',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: _canResend ? const Color(0xFF2563EB) : const Color(0xFF9CA3AF),
                      ),
                    ),
                  ),
                ]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOtpBox(int index) {
    return SizedBox(
      width: 46,
      height: 56,
      child: TextFormField(
        controller: _controllers[index],
        focusNode: _focusNodes[index],
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: const Color(0xFF111827)),
        decoration: InputDecoration(
          counterText: '',
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE5E7EB), width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF2563EB), width: 2),
          ),
          filled: true,
          fillColor: const Color(0xFFF9FAFB),
        ),
        onChanged: (v) => _onChanged(v, index),
      ),
    );
  }
}
