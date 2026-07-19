import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:mobile/features/auth/providers/auth_provider.dart';
import 'package:mobile/features/auth/screens/pin_lock_screen.dart';
import 'package:mobile/features/dashboard/screens/dashboard_screen.dart';
import 'onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _logoScale;
  late Animation<double> _textWidth;
  late Animation<double> _textOpacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    // 1. Logo thu nhỏ dần (0% - 40% thời gian)
    _logoScale = Tween<double>(begin: 2.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOutCubic),
      ),
    );

    // 2. Chữ bắt đầu mở rộng không gian, đẩy logo sang trái (40% - 80%)
    _textWidth = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 0.8, curve: Curves.easeInOutCubic),
      ),
    );

    // 3. Chữ hiện rõ lên (60% - 100%)
    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.6, 1.0, curve: Curves.easeIn),
      ),
    );

    // Chờ 500ms rồi mới bắt đầu chạy Animation cho tự nhiên
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _controller.forward().then((_) {
          // Khi animation kết thúc, chờ thêm 1.5s rồi chuyển màn
          Future.delayed(const Duration(milliseconds: 1500), () {
            if (mounted) {
              final authProvider = Provider.of<AuthProvider>(context, listen: false);
              
              if (authProvider.isAuthenticated) {
                // Nếu đã bật mã PIN → bắt nhập PIN trước khi vào app
                if (authProvider.hasPin) {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => const PinLockScreen(),
                    ),
                  );
                } else {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => const DashboardScreen(),
                    ),
                  );
                }
              } else {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => const OnboardingScreen(),
                  ),
                );
              }
            }
          });
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Logo
                Transform.scale(
                  scale: _logoScale.value,
                  child: Image.asset(
                    'assets/images/logo.png',
                    width: 80, // Kích thước gốc khi kết thúc animation
                    height: 80,
                    fit: BoxFit.contain,
                  ),
                ),
                
                // Hiệu ứng đẩy và hiện chữ Finora
                ClipRect(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    widthFactor: _textWidth.value,
                    child: Opacity(
                      opacity: _textOpacity.value,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 12.0),
                        child: Text(
                          'Finora',
                          style: GoogleFonts.inter(
                            fontSize: 64,
                            fontWeight: FontWeight.w800, // ExtraBold
                            color: Colors.black,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
