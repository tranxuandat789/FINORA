import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  // Master switch
  bool _pushEnabled = true;

  // Category switches
  bool _transactionAlerts = true;
  bool _budgetAlerts = true;
  bool _goalAlerts = true;
  bool _systemAlerts = false;
  bool _reminderAlerts = true;
  bool _weeklyReport = true;
  bool _monthlyReport = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildMasterCard(),
                    const SizedBox(height: 24),
                    _buildSectionTitle('Loại thông báo'),
                    const SizedBox(height: 12),
                    _buildCategoryCard(),
                    const SizedBox(height: 24),
                    _buildSectionTitle('Báo cáo định kỳ'),
                    const SizedBox(height: 12),
                    _buildReportCard(),
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

  Widget _buildAppBar(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(8, 12, 16, 12),
      child: Row(
        children: [
          IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back, color: Color(0xFF111827))),
          Expanded(child: Text('Cài đặt thông báo', textAlign: TextAlign.center,
              style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF111827)))),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String t) =>
      Text(t, style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.bold, color: const Color(0xFF111827)));

  Widget _buildMasterCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF2563EB), Color(0xFF3B82F6)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(width: 50, height: 50, decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(14)),
              child: const Icon(Icons.notifications_active, color: Colors.white, size: 26)),
          const SizedBox(width: 16),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Thông báo đẩy', style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
            Text('Bật/tắt toàn bộ thông báo', style: GoogleFonts.poppins(fontSize: 12, color: Colors.white.withValues(alpha: 0.8))),
          ])),
          Switch(
            value: _pushEnabled,
            onChanged: (v) => setState(() => _pushEnabled = v),
            activeColor: Colors.white,
            activeTrackColor: Colors.white.withValues(alpha: 0.4),
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: Colors.white.withValues(alpha: 0.2),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard() {
    return AnimatedOpacity(
      opacity: _pushEnabled ? 1.0 : 0.4,
      duration: const Duration(milliseconds: 200),
      child: AbsorbPointer(
        absorbing: !_pushEnabled,
        child: Container(
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 12, offset: const Offset(0, 4))]),
          child: Column(children: [
            _buildToggle(icon: Icons.receipt_long, iconColor: const Color(0xFF2563EB), iconBg: const Color(0xFFE0E7FF),
                title: 'Giao dịch mới', value: _transactionAlerts, onChanged: (v) => setState(() => _transactionAlerts = v)),
            const Divider(color: Color(0xFFF3F4F6), height: 1, indent: 68),
            _buildToggle(icon: Icons.pie_chart_outline, iconColor: const Color(0xFFEF4444), iconBg: const Color(0xFFFEE2E2),
                title: 'Cảnh báo ngân sách', value: _budgetAlerts, onChanged: (v) => setState(() => _budgetAlerts = v)),
            const Divider(color: Color(0xFFF3F4F6), height: 1, indent: 68),
            _buildToggle(icon: Icons.track_changes, iconColor: const Color(0xFF8B5CF6), iconBg: const Color(0xFFF3E8FF),
                title: 'Mục tiêu tiết kiệm', value: _goalAlerts, onChanged: (v) => setState(() => _goalAlerts = v)),
            const Divider(color: Color(0xFFF3F4F6), height: 1, indent: 68),
            _buildToggle(icon: Icons.notifications_active_outlined, iconColor: const Color(0xFFF59E0B), iconBg: const Color(0xFFFEF3C7),
                title: 'Nhắc nhở chi tiêu', value: _reminderAlerts, onChanged: (v) => setState(() => _reminderAlerts = v)),
            const Divider(color: Color(0xFFF3F4F6), height: 1, indent: 68),
            _buildToggle(icon: Icons.info_outline, iconColor: const Color(0xFF10B981), iconBg: const Color(0xFFD1FAE5),
                title: 'Hệ thống', value: _systemAlerts, onChanged: (v) => setState(() => _systemAlerts = v)),
          ]),
        ),
      ),
    );
  }

  Widget _buildReportCard() {
    return AnimatedOpacity(
      opacity: _pushEnabled ? 1.0 : 0.4,
      duration: const Duration(milliseconds: 200),
      child: AbsorbPointer(
        absorbing: !_pushEnabled,
        child: Container(
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 12, offset: const Offset(0, 4))]),
          child: Column(children: [
            _buildToggle(icon: Icons.calendar_view_week, iconColor: const Color(0xFF2563EB), iconBg: const Color(0xFFE0E7FF),
                title: 'Báo cáo hàng tuần', value: _weeklyReport, onChanged: (v) => setState(() => _weeklyReport = v)),
            const Divider(color: Color(0xFFF3F4F6), height: 1, indent: 68),
            _buildToggle(icon: Icons.calendar_month, iconColor: const Color(0xFF8B5CF6), iconBg: const Color(0xFFF3E8FF),
                title: 'Báo cáo hàng tháng', value: _monthlyReport, onChanged: (v) => setState(() => _monthlyReport = v)),
          ]),
        ),
      ),
    );
  }

  Widget _buildToggle({required IconData icon, required Color iconColor, required Color iconBg,
      required String title, required bool value, required ValueChanged<bool> onChanged}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(children: [
        Container(width: 44, height: 44, decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: iconColor, size: 22)),
        const SizedBox(width: 14),
        Expanded(child: Text(title, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500, color: const Color(0xFF111827)))),
        Switch(value: value, onChanged: onChanged, activeColor: const Color(0xFF2563EB)),
      ]),
    );
  }
}
