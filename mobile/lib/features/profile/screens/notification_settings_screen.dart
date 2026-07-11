import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:mobile/core/providers/theme_provider.dart';
import '../providers/notification_settings_provider.dart';
import '../models/notification_setting.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationSettingsProvider>().loadSettings();
    });
  }

  void _updateSetting(BuildContext context, NotificationSetting current, NotificationSetting updated) {
    context.read<NotificationSettingsProvider>().updateSettings(updated);
  }

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
              child: Consumer<NotificationSettingsProvider>(
                builder: (context, provider, child) {
                  if (provider.isLoading && provider.settings == null) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (provider.error != null && provider.settings == null) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Lỗi: ${provider.error}', style: TextStyle(color: Colors.red)),
                          ElevatedButton(
                            onPressed: () => provider.loadSettings(),
                            child: const Text('Thử lại'),
                          ),
                        ],
                      ),
                    );
                  }

                  final settings = provider.settings;
                  if (settings == null) {
                    return const SizedBox.shrink();
                  }

                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildMasterCard(context, settings),
                        const SizedBox(height: 24),
                        _buildSectionTitle('Loại thông báo', isDark),
                        const SizedBox(height: 12),
                        _buildCategoryCard(context, settings, isDark),
                        const SizedBox(height: 24),
                        _buildSectionTitle('Báo cáo định kỳ', isDark),
                        const SizedBox(height: 12),
                        _buildReportCard(context, settings, isDark),
                        const SizedBox(height: 32),
                      ],
                    ),
                  );
                },
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
          Expanded(child: Text('Cài đặt thông báo', textAlign: TextAlign.center,
              style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF111827)))),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String t, bool isDark) =>
      Text(t, style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF111827)));

  Widget _buildMasterCard(BuildContext context, NotificationSetting settings) {
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
            Text('Thông báo đẩy', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
            Text('Bật/tắt toàn bộ thông báo', style: GoogleFonts.inter(fontSize: 12, color: Colors.white.withValues(alpha: 0.8))),
          ])),
          Switch(
            value: settings.pushNotifications,
            onChanged: (v) => _updateSetting(context, settings, settings.copyWith(pushNotifications: v)),
            activeColor: Colors.white,
            activeTrackColor: Colors.white.withValues(alpha: 0.4),
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: Colors.white.withValues(alpha: 0.2),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(BuildContext context, NotificationSetting settings, bool isDark) {
    final enabled = settings.pushNotifications;
    return AnimatedOpacity(
      opacity: enabled ? 1.0 : 0.4,
      duration: const Duration(milliseconds: 200),
      child: AbsorbPointer(
        absorbing: !enabled,
        child: Container(
          decoration: BoxDecoration(color: isDark ? const Color(0xFF111827) : Colors.white, borderRadius: BorderRadius.circular(20),
              boxShadow: isDark ? [] : [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 12, offset: const Offset(0, 4))]),
          child: Column(children: [
            _buildToggle(icon: Icons.receipt_long, iconColor: isDark ? const Color(0xFF60A5FA) : const Color(0xFF2563EB), iconBg: isDark ? const Color(0xFF1E3A8A) : const Color(0xFFE0E7FF),
                title: 'Giao dịch mới', value: settings.newTransactions, onChanged: (v) => _updateSetting(context, settings, settings.copyWith(newTransactions: v)), isDark: isDark),
            Divider(color: isDark ? const Color(0xFF374151) : const Color(0xFFF3F4F6), height: 1, indent: 68),
            _buildToggle(icon: Icons.pie_chart_outline, iconColor: isDark ? const Color(0xFFF87171) : const Color(0xFFEF4444), iconBg: isDark ? const Color(0xFF7F1D1D) : const Color(0xFFFEE2E2),
                title: 'Cảnh báo ngân sách', value: settings.budgetWarnings, onChanged: (v) => _updateSetting(context, settings, settings.copyWith(budgetWarnings: v)), isDark: isDark),
            Divider(color: isDark ? const Color(0xFF374151) : const Color(0xFFF3F4F6), height: 1, indent: 68),
            _buildToggle(icon: Icons.track_changes, iconColor: isDark ? const Color(0xFFA78BFA) : const Color(0xFF8B5CF6), iconBg: isDark ? const Color(0xFF4C1D95) : const Color(0xFFF3E8FF),
                title: 'Mục tiêu tiết kiệm', value: settings.savingGoals, onChanged: (v) => _updateSetting(context, settings, settings.copyWith(savingGoals: v)), isDark: isDark),
            Divider(color: isDark ? const Color(0xFF374151) : const Color(0xFFF3F4F6), height: 1, indent: 68),
            _buildToggle(icon: Icons.notifications_active_outlined, iconColor: isDark ? const Color(0xFFFBBF24) : const Color(0xFFF59E0B), iconBg: isDark ? const Color(0xFF78350F) : const Color(0xFFFEF3C7),
                title: 'Nhắc nhở chi tiêu', value: settings.spendingReminders, onChanged: (v) => _updateSetting(context, settings, settings.copyWith(spendingReminders: v)), isDark: isDark),
            Divider(color: isDark ? const Color(0xFF374151) : const Color(0xFFF3F4F6), height: 1, indent: 68),
            _buildToggle(icon: Icons.info_outline, iconColor: isDark ? const Color(0xFF34D399) : const Color(0xFF10B981), iconBg: isDark ? const Color(0xFF064E3B) : const Color(0xFFD1FAE5),
                title: 'Hệ thống', value: settings.systemAlerts, onChanged: (v) => _updateSetting(context, settings, settings.copyWith(systemAlerts: v)), isDark: isDark),
          ]),
        ),
      ),
    );
  }

  Widget _buildReportCard(BuildContext context, NotificationSetting settings, bool isDark) {
    final enabled = settings.pushNotifications;
    return AnimatedOpacity(
      opacity: enabled ? 1.0 : 0.4,
      duration: const Duration(milliseconds: 200),
      child: AbsorbPointer(
        absorbing: !enabled,
        child: Container(
          decoration: BoxDecoration(color: isDark ? const Color(0xFF111827) : Colors.white, borderRadius: BorderRadius.circular(20),
              boxShadow: isDark ? [] : [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 12, offset: const Offset(0, 4))]),
          child: Column(children: [
            _buildToggle(icon: Icons.calendar_view_week, iconColor: isDark ? const Color(0xFF60A5FA) : const Color(0xFF2563EB), iconBg: isDark ? const Color(0xFF1E3A8A) : const Color(0xFFE0E7FF),
                title: 'Báo cáo hàng tuần', value: settings.periodicReports, onChanged: (v) => _updateSetting(context, settings, settings.copyWith(periodicReports: v)), isDark: isDark),
          ]),
        ),
      ),
    );
  }

  Widget _buildToggle({required IconData icon, required Color iconColor, required Color iconBg,
      required String title, required bool value, required ValueChanged<bool> onChanged, required bool isDark}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(children: [
        Container(width: 44, height: 44, decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: iconColor, size: 22)),
        const SizedBox(width: 14),
        Expanded(child: Text(title, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: isDark ? Colors.white : const Color(0xFF111827)))),
        Switch(value: value, onChanged: onChanged, activeColor: isDark ? const Color(0xFF60A5FA) : const Color(0xFF2563EB)),
      ]),
    );
  }
}
