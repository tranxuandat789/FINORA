import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile/features/auth/screens/login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> with SingleTickerProviderStateMixin {
  int _currentPage = 0;
  late PageController _pageController;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation1;
  late Animation<Offset> _slideAnimation1;
  late Animation<double> _fadeAnimation2;
  late Animation<Offset> _slideAnimation2;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _fadeAnimation1 = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: const Interval(0.2, 0.7, curve: Curves.easeOut)),
    );
    _slideAnimation1 = Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(
      CurvedAnimation(parent: _animationController, curve: const Interval(0.2, 0.7, curve: Curves.easeOut)),
    );

    _fadeAnimation2 = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: const Interval(0.5, 1.0, curve: Curves.easeOut)),
    );
    _slideAnimation2 = Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(
      CurvedAnimation(parent: _animationController, curve: const Interval(0.5, 1.0, curve: Curves.easeOut)),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Các mã màu lấy từ bản thiết kế
    const Color primaryBlue = Color(0xFF246BFD);
    const Color textBlack = Color(0xFF1E1E1E);
    const Color textGrey = Color(0xFF4B5563);
    const Color indicatorGrey = Color(0xFFD1D5DB);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // ====== TOP BAR (Logo + Finora + Bỏ qua) ======
            Padding(
              padding: const EdgeInsets.only(left: 24.0, right: 16.0, top: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Logo + Tên App
                  Row(
                    children: [
                      Image.asset(
                        'assets/images/logo.png', 
                        height: 28,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Finora',
                        style: GoogleFonts.inter(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: textBlack,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                  // Nút "Bỏ qua"
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const LoginScreen()),
                      );
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: textGrey,
                    ),
                    child: Text(
                      'Bỏ qua',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                  )
                ],
              ),
            ),
            
            // ====== PAGE VIEW ======
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (int page) {
                  setState(() {
                    _currentPage = page;
                  });
                  // Chạy lại hiệu ứng khi đổi trang
                  _animationController.reset();
                  _animationController.forward();
                },
                children: [
                  _buildPage1(primaryBlue, textBlack, textGrey),
                  _buildPage2(primaryBlue, textBlack, textGrey),
                  _buildPage3(primaryBlue, textBlack, textGrey),
                ],
              ),
            ),
            
            const SizedBox(height: 32),

            // ====== PAGE INDICATOR (3 dấu chấm) ======
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                3, 
                (index) => buildDot(index, context, primaryBlue, indicatorGrey)
              ),
            ),
            
            const SizedBox(height: 24),
            
            // ====== BOTTOM BUTTON ======
            Padding(
              padding: const EdgeInsets.only(left: 24.0, right: 24.0, bottom: 32.0),
              child: SizedBox(
                width: double.infinity,
                height: 56, // Chiều cao chuẩn cho button lớn
                child: ElevatedButton(
                  onPressed: () {
                    if (_currentPage < 2) {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeIn,
                      );
                    } else {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const LoginScreen()),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    _currentPage == 2 ? 'Bắt đầu' : 'Tiếp tục',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage1(Color primaryBlue, Color textBlack, Color textGrey) {
    return Column(
      children: [
        const SizedBox(height: 32),
        // ====== TITLE ======
        Text(
          'Quản lý tài chính',
          style: GoogleFonts.inter(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            color: textBlack,
            letterSpacing: -0.5,
          ),
          textAlign: TextAlign.center,
        ),
        Text(
          'Dễ dàng hơn mỗi ngày',
          style: GoogleFonts.inter(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            color: primaryBlue,
            letterSpacing: -0.5,
          ),
          textAlign: TextAlign.center,
        ),
        
        const SizedBox(height: 16),
        
        // ====== SUBTITLE ======
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40.0),
          child: Text(
            'Theo dõi chi tiêu, lập ngân sách và\nđạt mục tiêu tài chính của bạn',
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: textGrey,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        
        const SizedBox(height: 24),

        // ====== CENTER IMAGE ======
        Expanded(
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              // 1. Background Blob
              Positioned.fill(
                child: Transform.translate(
                  offset: const Offset(0, 15),
                  child: Transform.scale(
                    scale: 1.3,
                    child: Image.asset(
                      'assets/images/Background1.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
              
              // 2. Main Character Image
              Padding(
                padding: const EdgeInsets.only(left: 70.0, right: 70.0, bottom: 20.0),
                child: Image.asset(
                  'assets/images/Onboarding1.png',
                  fit: BoxFit.contain,
                ),
              ),

              // 3. Floating Card Left (Tổng số dư)
              Positioned(
                left: 0,
                top: 10,
                child: FadeTransition(
                  opacity: _fadeAnimation1,
                  child: SlideTransition(
                    position: _slideAnimation1,
                    child: _buildBalanceCard(),
                  ),
                ),
              ),

              // 4. Floating Card Right (Tiết kiệm)
              Positioned(
                right: 0,
                bottom: 40,
                child: FadeTransition(
                  opacity: _fadeAnimation2,
                  child: SlideTransition(
                    position: _slideAnimation2,
                    child: _buildSavingsCard(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPage2(Color primaryBlue, Color textBlack, Color textGrey) {
    return Column(
      children: [
        const SizedBox(height: 32),
        // ====== TITLE ======
        Text(
          'Tiết kiệm hiệu quả',
          style: GoogleFonts.inter(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            color: textBlack,
            letterSpacing: -0.5,
          ),
          textAlign: TextAlign.center,
        ),
        Text(
          'Đạt mục tiêu tài chính',
          style: GoogleFonts.inter(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            color: primaryBlue,
            letterSpacing: -0.5,
          ),
          textAlign: TextAlign.center,
        ),
        
        const SizedBox(height: 16),
        
        // ====== SUBTITLE ======
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40.0),
          child: Text(
            'Xây dựng mục tiêu, theo dõi tiến độ và\nnhận gợi ý để đạt được mục tiêu của bạn',
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: textGrey,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        
        const SizedBox(height: 24),

        // ====== CENTER IMAGE ======
        Expanded(
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              // 1. Background Blob
              Positioned.fill(
                child: Transform.translate(
                  offset: const Offset(0, 15),
                  child: Transform.scale(
                    scale: 1.3,
                    child: Image.asset(
                      'assets/images/Background2.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
              
              // 2. Main Character Image
              Positioned(
                left: 20,
                bottom: -25,
                child: Image.asset(
                  'assets/images/Onboarding2.png',
                  height: 330,
                ),
              ),

              // 3. Floating Target Icon (Onboarding2-Goal.png)
              Positioned(
                left: 175,
                top: -25,
                child: FadeTransition(
                  opacity: _fadeAnimation1,
                  child: SlideTransition(
                    position: _slideAnimation1,
                    child: Image.asset(
                      'assets/images/Onboarding2-Goal.png',
                      height: 75,
                    ),
                  ),
                ),
              ),

              // 4. Floating Card Top Right (Mục tiêu)
              Positioned(
                right: 5,
                top: 15,
                child: FadeTransition(
                  opacity: _fadeAnimation1,
                  child: SlideTransition(
                    position: _slideAnimation1,
                    child: _buildGoalCard(),
                  ),
                ),
              ),

              // 5. Floating Card Bottom Right (Gợi ý cho bạn)
              Positioned(
                right: 5,
                top: 155,
                child: FadeTransition(
                  opacity: _fadeAnimation2,
                  child: SlideTransition(
                    position: _slideAnimation2,
                    child: _buildSuggestionCard(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Widget vẽ các dấu chấm (indicator)
  Widget buildDot(int index, BuildContext context, Color primary, Color grey) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: 8,
      width: _currentPage == index ? 8 : 8,
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _currentPage == index ? primary : grey,
      ),
    );
  }

  Widget _buildBalanceCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tổng số dư',
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1E1E1E),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '24.000.000đ',
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1E1E1E),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: 105, 
            height: 24,
            child: CustomPaint(
              painter: ChartLinePainter(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSavingsCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bạn đã tiết kiệm được',
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1E1E1E),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '15%',
            style: GoogleFonts.inter(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF246BFD),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'So với tháng trước',
            style: GoogleFonts.inter(
              fontSize: 9,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF1E1E1E),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalCard() {
    return Container(
      width: 190,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Mục tiêu',
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1E1E1E),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Du lịch nhật bản',
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1E1E1E),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: 0.72,
                    minHeight: 6,
                    backgroundColor: const Color(0xFFE5E7EB),
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF246BFD)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '72%',
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1E1E1E),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionCard() {
    return Container(
      width: 190,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Gợi ý cho bạn',
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1E1E1E),
            ),
          ),
          const SizedBox(height: 6),
          RichText(
            text: TextSpan(
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1E1E1E),
                height: 1.6,
              ),
              children: [
                const TextSpan(text: 'Tiết kiệm '),
                TextSpan(
                  text: '1.200.000đ',
                  style: GoogleFonts.inter(
                    color: const Color(0xFF246BFD),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                const TextSpan(text: ' mỗi tháng để đạt mục tiêu đúng hạn'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPage3(Color primaryBlue, Color textBlack, Color textGrey) {
    return Column(
      children: [
        const SizedBox(height: 32),
        // ====== TITLE ======
        Text(
          'Quản lý tài chính',
          style: GoogleFonts.inter(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            color: textBlack,
            letterSpacing: -0.5,
          ),
          textAlign: TextAlign.center,
        ),
        Text(
          'Dễ dàng hơn mỗi ngày',
          style: GoogleFonts.inter(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            color: primaryBlue,
            letterSpacing: -0.5,
          ),
          textAlign: TextAlign.center,
        ),
        
        const SizedBox(height: 16),
        
        // ====== SUBTITLE ======
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40.0),
          child: Text(
            'Theo dõi chi tiêu, lập ngân sách và\nđạt mục tiêu tài chính của bạn',
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: textGrey,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        
        const SizedBox(height: 24),

        // ====== CENTER IMAGE ======
        Expanded(
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              // 1. Background Blob
              Positioned.fill(
                child: Transform.translate(
                  offset: const Offset(0, 15),
                  child: Transform.scale(
                    scale: 1.3,
                    child: Image.asset(
                      'assets/images/Background3.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
              
              // 2. Main Character Image
              Positioned(
                right: -10,
                bottom: -20,
                child: Image.asset(
                  'assets/images/Onboarding3.png',
                  height: 380,
                ),
              ),

              // 3. Floating Card Top Left (Tổng chi tiêu)
              Positioned(
                left: 20,
                top: 5,
                child: FadeTransition(
                  opacity: _fadeAnimation1,
                  child: SlideTransition(
                    position: _slideAnimation1,
                    child: _buildTotalExpenseCard(),
                  ),
                ),
              ),

              // 4. Floating Card Bottom Left (Danh mục chi tiêu)
              Positioned(
                left: 20,
                top: 115,
                child: FadeTransition(
                  opacity: _fadeAnimation2,
                  child: SlideTransition(
                    position: _slideAnimation2,
                    child: _buildCategoryExpenseCard(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTotalExpenseCard() {
    return Container(
      width: 190,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tổng chi tiêu',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '24.000.000đ',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.arrow_downward, color: Color(0xFF246BFD), size: 10),
                  const SizedBox(width: 2),
                  Text(
                    '8% so với tháng trước',
                    style: GoogleFonts.inter(
                      fontSize: 8,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF246BFD),
                    ),
                  ),
                ],
              ),
            ],
          ),
          // Chart
          SizedBox(
            width: 40,
            height: 40,
            child: CustomPaint(
              painter: PieChartPainter(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryExpenseCard() {
    return Container(
      width: 200,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Danh mục chi tiêu',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 12),
          _buildCategoryItem(Icons.restaurant, const Color(0xFF22C55E), 'Ăn uống', '4.200.000đ', '34%'),
          const SizedBox(height: 8),
          _buildCategoryItem(Icons.shopping_bag, const Color(0xFF3B82F6), 'Mua sắm', '2.100.000đ', '25%'),
          const SizedBox(height: 8),
          _buildCategoryItem(Icons.directions_car, const Color(0xFFF97316), 'Đi lại', '1.200.000đ', '20%'),
          const SizedBox(height: 8),
          _buildCategoryItem(Icons.sports_esports, const Color(0xFFA855F7), 'Giải trí', '900.000đ', '14%'),
          const SizedBox(height: 8),
          _buildCategoryItem(Icons.more_horiz, const Color(0xFF6B7280), 'Khác', '4.200.000đ', '7%'),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(IconData icon, Color color, String name, String amount, String percent) {
    return Row(
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icon, size: 12, color: color),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            name,
            style: GoogleFonts.inter(
              fontSize: 9,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Text(
          amount,
          style: GoogleFonts.inter(
            fontSize: 9,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(width: 4),
        SizedBox(
          width: 22,
          child: Text(
            percent,
            style: GoogleFonts.inter(
              fontSize: 9,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF246BFD),
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}

class PieChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.0
      ..strokeCap = StrokeCap.butt;

    final double startAngle = -3.14159 / 2; // Bắt đầu từ đỉnh trên
    
    // Phần màu xanh biển (Blue) - Khoảng 45% bên phải
    paint.color = const Color(0xFF3B82F6);
    canvas.drawArc(rect, startAngle, 3.14159 * 2 * 0.45, false, paint);
    
    // Phần màu tím (Purple) - Khoảng 30% góc dưới trái
    paint.color = const Color(0xFFA855F7);
    canvas.drawArc(rect, startAngle + 3.14159 * 2 * 0.45, 3.14159 * 2 * 0.30, false, paint);

    // Phần màu xanh lá (Green) - Khoảng 25% góc trên trái
    paint.color = const Color(0xFF22C55E);
    canvas.drawArc(rect, startAngle + 3.14159 * 2 * 0.75, 3.14159 * 2 * 0.25, false, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class ChartLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF246BFD)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final Rect drawRect = Rect.fromLTRB(2, 2, size.width - 2, size.height - 2);
    final double w = drawRect.width;
    final double h = drawRect.height;
    final double left = drawRect.left;
    final double top = drawRect.top;

    final path = Path();
    path.moveTo(left, top + h);
    path.lineTo(left + w * 0.15, top + h * 0.6);
    path.lineTo(left + w * 0.3, top + h * 0.85);
    path.lineTo(left + w * 0.5, top + h * 0.4);
    path.lineTo(left + w * 0.65, top + h * 0.6);
    path.lineTo(left + w * 0.85, top + h * 0.2);
    path.lineTo(left + w, top);

    canvas.drawPath(path, paint);

    // Arrow head
    final arrowPath = Path();
    arrowPath.moveTo(left + w - 6, top);
    arrowPath.lineTo(left + w, top);
    arrowPath.lineTo(left + w, top + 6);
    canvas.drawPath(arrowPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
