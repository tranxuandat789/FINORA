import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SecurityScreen extends StatefulWidget {
  const SecurityScreen({super.key});

  @override
  State<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends State<SecurityScreen> {
  final _currentPwCtrl = TextEditingController();
  final _newPwCtrl = TextEditingController();
  final _confirmPwCtrl = TextEditingController();
  bool _showCurrent = false;
  bool _showNew = false;
  bool _showConfirm = false;
  bool _biometricEnabled = false;
  bool _twoFactorEnabled = false;

  @override
  void dispose() {
    _currentPwCtrl.dispose();
    _newPwCtrl.dispose();
    _confirmPwCtrl.dispose();
    super.dispose();
  }

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
                    _buildSectionTitle('Bảo mật nâng cao'),
                    const SizedBox(height: 12),
                    _buildToggleCard(),
                    const SizedBox(height: 24),
                    _buildSectionTitle('Đổi mật khẩu'),
                    const SizedBox(height: 12),
                    _buildPasswordCard(),
                    const SizedBox(height: 28),
                    _buildSaveButton(context),
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
          Expanded(
            child: Text('Bảo mật & Mật khẩu', textAlign: TextAlign.center,
                style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF111827))),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) =>
      Text(title, style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.bold, color: const Color(0xFF111827)));

  Widget _buildToggleCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          _buildToggleRow(icon: Icons.fingerprint, iconColor: const Color(0xFF10B981), iconBg: const Color(0xFFD1FAE5),
              title: 'Đăng nhập bằng vân tay', subtitle: 'Sử dụng sinh trắc học', value: _biometricEnabled,
              onChanged: (v) => setState(() => _biometricEnabled = v)),
          const Divider(color: Color(0xFFF3F4F6), height: 1, indent: 68),
          _buildToggleRow(icon: Icons.shield_outlined, iconColor: const Color(0xFF2563EB), iconBg: const Color(0xFFE0E7FF),
              title: 'Xác thực 2 bước', subtitle: 'Tăng cường bảo mật tài khoản', value: _twoFactorEnabled,
              onChanged: (v) => setState(() => _twoFactorEnabled = v)),
        ],
      ),
    );
  }

  Widget _buildToggleRow({required IconData icon, required Color iconColor, required Color iconBg,
      required String title, required String subtitle, required bool value, required ValueChanged<bool> onChanged}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Container(width: 44, height: 44, decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: iconColor, size: 22)),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF111827))),
            Text(subtitle, style: GoogleFonts.poppins(fontSize: 11, color: const Color(0xFF6B7280))),
          ])),
          Switch(value: value, onChanged: onChanged, activeColor: const Color(0xFF2563EB)),
        ],
      ),
    );
  }

  Widget _buildPasswordCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 12, offset: const Offset(0, 4))]),
      child: Column(children: [
        _buildPwField('Mật khẩu hiện tại', _currentPwCtrl, _showCurrent, () => setState(() => _showCurrent = !_showCurrent)),
        const SizedBox(height: 16),
        _buildPwField('Mật khẩu mới', _newPwCtrl, _showNew, () => setState(() => _showNew = !_showNew)),
        const SizedBox(height: 16),
        _buildPwField('Xác nhận mật khẩu mới', _confirmPwCtrl, _showConfirm, () => setState(() => _showConfirm = !_showConfirm)),
      ]),
    );
  }

  Widget _buildPwField(String label, TextEditingController ctrl, bool show, VoidCallback toggle) {
    return TextField(
      controller: ctrl,
      obscureText: !show,
      style: GoogleFonts.poppins(fontSize: 14, color: const Color(0xFF111827)),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.poppins(fontSize: 13, color: const Color(0xFF6B7280)),
        filled: true, fillColor: const Color(0xFFF9FAFB),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        suffixIcon: IconButton(icon: Icon(show ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: const Color(0xFF9CA3AF), size: 20), onPressed: toggle),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  Widget _buildSaveButton(BuildContext context) {
    return SizedBox(
      width: double.infinity, height: 54,
      child: ElevatedButton(
        onPressed: () {
          if (_newPwCtrl.text.isNotEmpty && _newPwCtrl.text != _confirmPwCtrl.text) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Mật khẩu xác nhận không khớp', style: GoogleFonts.poppins()),
                backgroundColor: const Color(0xFFEF4444), behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))));
            return;
          }
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Cập nhật thành công!', style: GoogleFonts.poppins()),
              backgroundColor: const Color(0xFF10B981), behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))));
          Navigator.pop(context);
        },
        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2563EB), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), elevation: 0),
        child: Text('Cập nhật mật khẩu', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
      ),
    );
  }
}
