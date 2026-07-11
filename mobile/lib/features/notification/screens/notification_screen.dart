import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/notification_provider.dart';
import '../models/notification_model.dart';
import 'package:mobile/core/providers/theme_provider.dart';
import 'package:mobile/features/goal/screens/goal_detail_screen.dart';
import 'package:mobile/features/budget/screens/budget_screen.dart';
import 'package:mobile/features/transaction/screens/transaction_screen.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  bool _showUnreadOnly = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationProvider>().fetchNotifications(refresh: true);
    });
  }

  IconData _getIconForType(NotificationType type) {
    switch (type) {
      case NotificationType.transaction:
        return Icons.receipt_long_rounded;
      case NotificationType.budget:
        return Icons.pie_chart_rounded;
      case NotificationType.goal:
        return Icons.flag_rounded;
      case NotificationType.reminder:
        return Icons.notifications_active_rounded;
      case NotificationType.system:
        return Icons.cloud_sync_rounded;
      default:
        return Icons.notifications_rounded;
    }
  }

  Color _getColorForType(NotificationType type) {
    switch (type) {
      case NotificationType.transaction:
        return const Color(0xFF10B981);
      case NotificationType.budget:
        return const Color(0xFFF59E0B);
      case NotificationType.goal:
        return const Color(0xFF3B82F6);
      case NotificationType.reminder:
        return const Color(0xFF8B5CF6);
      case NotificationType.system:
        return const Color(0xFF6B7280);
      default:
        return const Color(0xFF3B82F6);
    }
  }

  String _getTypeLabel(NotificationType type) {
    switch (type) {
      case NotificationType.transaction:
        return 'Giao dịch';
      case NotificationType.budget:
        return 'Ngân sách';
      case NotificationType.goal:
        return 'Mục tiêu';
      case NotificationType.reminder:
        return 'Nhắc nhở';
      case NotificationType.system:
        return 'Hệ thống';
      default:
        return 'Thông báo';
    }
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inMinutes < 1) return 'Vừa xong';
    if (diff.inMinutes < 60) return '${diff.inMinutes} phút trước';
    if (diff.inHours < 24) return '${diff.inHours} giờ trước';
    if (diff.inDays == 1) return '1 ngày trước';
    if (diff.inDays < 7) return '${diff.inDays} ngày trước';
    return DateFormat('dd/MM/yyyy').format(dateTime);
  }

  void _onNotificationTap(BuildContext context, NotificationModel notification) {
    if (!notification.isRead) {
      context.read<NotificationProvider>().markAsRead(notification.id);
    }
    if (notification.referenceId == null) return;

    switch (notification.type) {
      case NotificationType.goal:
        Navigator.push(context, MaterialPageRoute(
          builder: (_) => GoalDetailScreen(goalId: notification.referenceId!),
        ));
        break;
      case NotificationType.budget:
        Navigator.push(context, MaterialPageRoute(
          builder: (_) => const BudgetScreen(),
        ));
        break;
      case NotificationType.transaction:
        Navigator.push(context, MaterialPageRoute(
          builder: (_) => const TransactionScreen(),
        ));
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDarkMode;

    final bgColor = isDark ? const Color(0xFF111827) : const Color(0xFFF9FAFB);
    final cardColor = isDark ? const Color(0xFF1F2937) : Colors.white;
    final titleColor = isDark ? Colors.white : const Color(0xFF111827);
    final subtitleColor = isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280);
    final dividerColor = isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF1F2937) : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: isDark ? Colors.white : const Color(0xFF111827)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Thông báo',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: titleColor,
          ),
        ),
        centerTitle: true,
        actions: [
          Consumer<NotificationProvider>(
            builder: (context, provider, _) {
              if (provider.unreadCount == 0) return const SizedBox.shrink();
              return TextButton(
                onPressed: () => provider.markAllAsRead(),
                child: Text(
                  'Đọc tất cả',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF3B82F6),
                  ),
                ),
              );
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: dividerColor),
        ),
      ),
      body: Column(
        children: [
          // Filter tabs
          Container(
            color: isDark ? const Color(0xFF1F2937) : Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Consumer<NotificationProvider>(
              builder: (context, provider, _) {
                final unreadCount = provider.unreadCount;
                return Row(
                  children: [
                    _buildFilterChip(
                      label: 'Tất cả',
                      isSelected: !_showUnreadOnly,
                      isDark: isDark,
                      onTap: () => setState(() => _showUnreadOnly = false),
                    ),
                    const SizedBox(width: 8),
                    _buildFilterChip(
                      label: 'Chưa đọc',
                      badge: unreadCount > 0 ? unreadCount : null,
                      isSelected: _showUnreadOnly,
                      isDark: isDark,
                      onTap: () => setState(() => _showUnreadOnly = true),
                    ),
                  ],
                );
              },
            ),
          ),
          Divider(height: 1, color: dividerColor),

          // List
          Expanded(
            child: Consumer<NotificationProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading && provider.notifications.isEmpty) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: const Color(0xFF3B82F6),
                      strokeWidth: 2,
                    ),
                  );
                }

                final filtered = _showUnreadOnly
                    ? provider.notifications.where((n) => !n.isRead).toList()
                    : provider.notifications;

                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.notifications_off_rounded,
                          size: 64,
                          color: isDark ? const Color(0xFF374151) : const Color(0xFFD1D5DB),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _showUnreadOnly
                              ? 'Không có thông báo chưa đọc'
                              : 'Chưa có thông báo nào',
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            color: subtitleColor,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => provider.fetchNotifications(refresh: true),
                  color: const Color(0xFF3B82F6),
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final notification = filtered[index];
                      return _buildNotificationCard(
                        context: context,
                        notification: notification,
                        cardColor: cardColor,
                        titleColor: titleColor,
                        subtitleColor: subtitleColor,
                        isDark: isDark,
                        onTap: () => _onNotificationTap(context, notification),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    int? badge,
    required bool isSelected,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF3B82F6)
              : (isDark ? const Color(0xFF374151) : const Color(0xFFF3F4F6)),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? Colors.white
                    : (isDark ? const Color(0xFF9CA3AF) : const Color(0xFF4B5563)),
              ),
            ),
            if (badge != null) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white.withOpacity(0.3) : const Color(0xFF3B82F6),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$badge',
                  style: GoogleFonts.inter(
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

  Widget _buildNotificationCard({
    required BuildContext context,
    required NotificationModel notification,
    required Color cardColor,
    required Color titleColor,
    required Color subtitleColor,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    final typeColor = _getColorForType(notification.type);
    final unreadBg = isDark
        ? const Color(0xFF1E3A5F).withOpacity(0.4)
        : const Color(0xFFEFF6FF);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: notification.isRead ? cardColor : unreadBg,
          borderRadius: BorderRadius.circular(14),
          border: notification.isRead
              ? null
              : Border.all(
                  color: const Color(0xFF3B82F6).withOpacity(0.3),
                  width: 1,
                ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: typeColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(_getIconForType(notification.type), color: typeColor, size: 22),
            ),
            const SizedBox(width: 12),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Type label + time
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _getTypeLabel(notification.type),
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: typeColor,
                        ),
                      ),
                      Row(
                        children: [
                          Text(
                            _formatTime(notification.createdAt),
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color: subtitleColor,
                            ),
                          ),
                          if (!notification.isRead) ...[
                            const SizedBox(width: 6),
                            Container(
                              width: 7,
                              height: 7,
                              decoration: const BoxDecoration(
                                color: Color(0xFF3B82F6),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),

                  // Title
                  Text(
                    notification.title,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: notification.isRead ? FontWeight.w500 : FontWeight.w700,
                      color: titleColor,
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Message
                  Text(
                    notification.message,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: subtitleColor,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
