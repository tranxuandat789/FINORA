import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'notification_detail_screen.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  int _selectedTab = 0; // 0: Tất cả, 1: Chưa đọc

  final List<NotificationItem> _notifications = [
    NotificationItem(
      id: '1',
      title: 'Chi tiêu vượt ngân sách',
      body: 'Danh mục Ăn uống đã vượt 85% ngân sách tháng này. Hãy kiểm tra lại chi tiêu của bạn.',
      category: 'Ngân sách',
      icon: Icons.pie_chart_outline,
      iconColor: const Color(0xFFEF4444),
      iconBg: const Color(0xFFFEE2E2),
      time: '2 phút trước',
      isRead: false,
    ),
    NotificationItem(
      id: '2',
      title: 'Mục tiêu tiết kiệm đạt 50%',
      body: 'Bạn đã đạt được 50% mục tiêu "Mua xe máy". Tiếp tục cố gắng nhé!',
      category: 'Mục tiêu',
      icon: Icons.track_changes,
      iconColor: const Color(0xFF8B5CF6),
      iconBg: const Color(0xFFF3E8FF),
      time: '1 giờ trước',
      isRead: false,
    ),
    NotificationItem(
      id: '3',
      title: 'Giao dịch mới được ghi nhận',
      body: 'Ghi nhận chi tiêu 150.000đ tại Shopee. Danh mục: Mua sắm.',
      category: 'Giao dịch',
      icon: Icons.receipt_long,
      iconColor: const Color(0xFF2563EB),
      iconBg: const Color(0xFFE0E7FF),
      time: '3 giờ trước',
      isRead: false,
    ),
    NotificationItem(
      id: '4',
      title: 'Nhắc nhở chi tiêu cuối tháng',
      body: 'Còn 5 ngày nữa là hết tháng. Tổng chi tiêu tháng này của bạn là 3.500.000đ.',
      category: 'Nhắc nhở',
      icon: Icons.notifications_active_outlined,
      iconColor: const Color(0xFFF59E0B),
      iconBg: const Color(0xFFFEF3C7),
      time: '1 ngày trước',
      isRead: true,
    ),
    NotificationItem(
      id: '5',
      title: 'Đồng bộ dữ liệu thành công',
      body: 'Tất cả dữ liệu của bạn đã được đồng bộ lên máy chủ thành công.',
      category: 'Hệ thống',
      icon: Icons.cloud_done_outlined,
      iconColor: const Color(0xFF10B981),
      iconBg: const Color(0xFFD1FAE5),
      time: '2 ngày trước',
      isRead: true,
    ),
    NotificationItem(
      id: '6',
      title: 'Chào mừng đến với Finora!',
      body: 'Cảm ơn bạn đã sử dụng ứng dụng. Hãy bắt đầu bằng cách thêm ví và ghi lại chi tiêu đầu tiên.',
      category: 'Hệ thống',
      icon: Icons.waving_hand_outlined,
      iconColor: const Color(0xFF2563EB),
      iconBg: const Color(0xFFE0E7FF),
      time: '7 ngày trước',
      isRead: true,
    ),
  ];

  List<NotificationItem> get _filteredNotifications {
    if (_selectedTab == 1) return _notifications.where((n) => !n.isRead).toList();
    return _notifications;
  }

  int get _unreadCount => _notifications.where((n) => !n.isRead).length;

  void _markAllAsRead() {
    setState(() {
      for (var n in _notifications) {
        n.isRead = true;
      }
    });
  }

  void _markAsRead(String id) {
    setState(() {
      final n = _notifications.firstWhere((n) => n.id == id);
      n.isRead = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context),
            _buildTabs(),
            Expanded(
              child: _filteredNotifications.isEmpty
                  ? _buildEmpty()
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                      itemCount: _filteredNotifications.length,
                      itemBuilder: (context, i) {
                        return _buildNotificationCard(_filteredNotifications[i], context);
                      },
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
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: Color(0xFF111827)),
          ),
          const Expanded(
            child: Text(
              'Thông báo',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF111827),
                fontFamily: 'Poppins',
              ),
            ),
          ),
          if (_unreadCount > 0)
            TextButton(
              onPressed: _markAllAsRead,
              child: Text(
                'Đọc tất cả',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: const Color(0xFF2563EB),
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          else
            const SizedBox(width: 72),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Row(
        children: [
          _buildTab('Tất cả', 0, badge: null),
          const SizedBox(width: 12),
          _buildTab('Chưa đọc', 1, badge: _unreadCount > 0 ? _unreadCount : null),
        ],
      ),
    );
  }

  Widget _buildTab(String label, int index, {int? badge}) {
    final isActive = _selectedTab == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF2563EB) : const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isActive ? Colors.white : const Color(0xFF6B7280),
              ),
            ),
            if (badge != null && badge > 0) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: isActive ? Colors.white.withValues(alpha: 0.3) : const Color(0xFF2563EB),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$badge',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationCard(NotificationItem item, BuildContext context) {
    return GestureDetector(
      onTap: () async {
        _markAsRead(item.id);
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => NotificationDetailScreen(item: item)),
        );
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: item.isRead ? Colors.white : const Color(0xFFF0F4FF),
          borderRadius: BorderRadius.circular(16),
          border: item.isRead
              ? null
              : Border.all(color: const Color(0xFF2563EB).withValues(alpha: 0.15)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(color: item.iconBg, shape: BoxShape.circle),
                child: Icon(item.icon, color: item.iconColor, size: 22),
              ),
              const SizedBox(width: 14),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: item.iconBg,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            item.category,
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: item.iconColor,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          item.time,
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: const Color(0xFF9CA3AF),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      item.title,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: item.isRead ? FontWeight.w500 : FontWeight.bold,
                        color: const Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.body,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: const Color(0xFF6B7280),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              // Unread dot
              if (!item.isRead) ...[
                const SizedBox(width: 8),
                Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.only(top: 4),
                  decoration: const BoxDecoration(
                    color: Color(0xFF2563EB),
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: const BoxDecoration(
              color: Color(0xFFE0E7FF),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.notifications_none, size: 40, color: Color(0xFF2563EB)),
          ),
          const SizedBox(height: 20),
          Text(
            'Không có thông báo',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Bạn đã đọc tất cả thông báo rồi!',
            style: GoogleFonts.poppins(fontSize: 13, color: const Color(0xFF6B7280)),
          ),
        ],
      ),
    );
  }
}

class NotificationItem {
  final String id;
  final String title;
  final String body;
  final String category;
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String time;
  bool isRead;

  NotificationItem({
    required this.id,
    required this.title,
    required this.body,
    required this.category,
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.time,
    required this.isRead,
  });
}
