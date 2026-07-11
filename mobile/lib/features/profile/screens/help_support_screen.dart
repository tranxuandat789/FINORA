import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import 'package:mobile/core/providers/theme_provider.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                    _buildContactCard(context),
                    const SizedBox(height: 24),
                    _buildFaqTitle(isDark),
                    const SizedBox(height: 12),
                    _buildFaqCard(isDark),
                    const SizedBox(height: 24),
                    _buildVersionCard(isDark),
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
          IconButton(onPressed: () => Navigator.pop(context), icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : const Color(0xFF111827))),
          Expanded(child: Text('Trợ giúp & Hỗ trợ', textAlign: TextAlign.center,
              style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF111827)))),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildContactCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF8B5CF6), Color(0xFFA78BFA)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Cần hỗ trợ?', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 6),
          Text('Đội ngũ hỗ trợ luôn sẵn sàng giúp bạn\nPhản hồi trong vòng 24 giờ làm việc.',
              style: GoogleFonts.inter(fontSize: 13, color: Colors.white.withValues(alpha: 0.9), height: 1.5)),
          const SizedBox(height: 20),
          Row(children: [
            _buildContactBtn(icon: Icons.email_outlined, label: 'Email', onTap: () => _launchEmail()),
            const SizedBox(width: 12),
            _buildContactBtn(icon: Icons.chat_bubble_outline, label: 'Chat', onTap: () {}),
          ]),
        ],
      ),
    );
  }

  Widget _buildContactBtn({required IconData icon, required String label, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.25), borderRadius: BorderRadius.circular(12)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, color: Colors.white, size: 18),
          const SizedBox(width: 8),
          Text(label, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
        ]),
      ),
    );
  }

  Widget _buildFaqTitle(bool isDark) {
    return Text('Câu hỏi thường gặp', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF111827)));
  }

  Widget _buildFaqCard(bool isDark) {
    final faqs = [
      _FaqItem(q: 'Làm thế nào để thêm ví mới?', a: 'Vào mục "Ví của tôi" trên trang chủ, sau đó nhấn vào nút "+" ở góc phải trên cùng để tạo ví mới.'),
      _FaqItem(q: 'Tôi có thể đồng bộ dữ liệu trên nhiều thiết bị không?', a: 'Có, dữ liệu của bạn được lưu trên đám mây và tự động đồng bộ khi bạn đăng nhập cùng tài khoản trên các thiết bị khác.'),
      _FaqItem(q: 'Làm thế nào để đặt ngân sách?', a: 'Vào tab "Phân tích" và chọn "Thiết lập ngân sách" để cài đặt giới hạn chi tiêu theo từng danh mục.'),
      _FaqItem(q: 'Tôi quên mật khẩu phải làm sao?', a: 'Trên màn hình đăng nhập, nhấn "Quên mật khẩu" và nhập email để nhận hướng dẫn đặt lại mật khẩu.'),
      _FaqItem(q: 'Dữ liệu của tôi có được bảo mật không?', a: 'Tất cả dữ liệu được mã hóa và lưu trữ an toàn. Chúng tôi không chia sẻ thông tin cá nhân của bạn với bên thứ ba.'),
    ];

    return Container(
      decoration: BoxDecoration(color: isDark ? const Color(0xFF111827) : Colors.white, borderRadius: BorderRadius.circular(20),
          boxShadow: isDark ? [] : [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 12, offset: const Offset(0, 4))]),
      child: Column(
        children: faqs.asMap().entries.map((e) {
          return Column(
            children: [
              _buildFaqTile(e.value, isDark),
              if (e.key < faqs.length - 1) Divider(color: isDark ? const Color(0xFF374151) : const Color(0xFFF3F4F6), height: 1, indent: 20),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildFaqTile(_FaqItem item, bool isDark) {
    return ExpansionTile(
      tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      iconColor: isDark ? const Color(0xFF60A5FA) : const Color(0xFF2563EB),
      collapsedIconColor: isDark ? const Color(0xFF6B7280) : const Color(0xFF9CA3AF),
      title: Text(item.q, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: isDark ? Colors.white : const Color(0xFF111827))),
      children: [
        Text(item.a, style: GoogleFonts.inter(fontSize: 13, color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280), height: 1.6)),
      ],
    );
  }

  Widget _buildVersionCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(color: isDark ? const Color(0xFF111827) : Colors.white, borderRadius: BorderRadius.circular(16),
          boxShadow: isDark ? [] : [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))]),
      child: Row(children: [
        Container(width: 40, height: 40, decoration: BoxDecoration(color: isDark ? const Color(0xFF1E3A8A) : const Color(0xFFE0E7FF), borderRadius: BorderRadius.circular(10)),
            child: Icon(Icons.info_outline, color: isDark ? const Color(0xFF60A5FA) : const Color(0xFF2563EB), size: 20)),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Phiên bản ứng dụng', style: GoogleFonts.inter(fontSize: 13, color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280))),
          Text('Finora v1.0.0', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: isDark ? Colors.white : const Color(0xFF111827))),
        ])),
        TextButton(
          onPressed: () {},
          child: Text('Kiểm tra cập nhật', style: GoogleFonts.inter(fontSize: 12, color: isDark ? const Color(0xFF60A5FA) : const Color(0xFF2563EB), fontWeight: FontWeight.w600)),
        ),
      ]),
    );
  }

  void _launchEmail() async {
    final uri = Uri.parse('mailto:support@finora.app?subject=Hỗ trợ người dùng');
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }
}

class _FaqItem {
  final String q;
  final String a;
  const _FaqItem({required this.q, required this.a});
}
