import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:mobile/features/goal/providers/goal_provider.dart';
import 'package:mobile/features/goal/models/goal_model.dart';
import 'package:mobile/features/goal/widgets/goal_icon_mapper.dart';
import 'package:flutter/services.dart';
import 'package:mobile/core/providers/theme_provider.dart';
import 'goal_detail_screen.dart';
import 'create_goal_screen.dart';

class SavingGoalsScreen extends StatefulWidget {
  const SavingGoalsScreen({Key? key}) : super(key: key);

  @override
  State<SavingGoalsScreen> createState() => _SavingGoalsScreenState();
}

class _SavingGoalsScreenState extends State<SavingGoalsScreen> {
  int _selectedFilter = 0; // 0=Tất cả, 1=Đang thực hiện, 2=Đã hoàn thành
  final List<String> _filters = ['Tất cả', 'Đang thực hiện', 'Đã hoàn thành'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GoalProvider>().loadGoals();
    });
  }

  String _formatMoneyFull(double amount) {
    final str = amount.toInt().toString();
    final result = StringBuffer();
    int count = 0;
    for (int i = str.length - 1; i >= 0; i--) {
      if (count > 0 && count % 3 == 0) result.write('.');
      result.write(str[i]);
      count++;
    }
    return '${result.toString().split('').reversed.join('')}đ';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDarkMode;
    final bgColor = isDark ? const Color(0xFF111827) : const Color(0xFFF5F7FA);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: PreferredSize(
        preferredSize: Size.zero,
        child: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          systemOverlayStyle: isDark ? SystemUiOverlayStyle.light.copyWith(statusBarColor: Colors.transparent) : SystemUiOverlayStyle.dark.copyWith(statusBarColor: Colors.transparent),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(isDark),
            Expanded(
              child: Consumer<GoalProvider>(
                builder: (context, provider, child) {
                  if (provider.isLoading && provider.goals.isEmpty) {
                    return Center(child: CircularProgressIndicator(color: isDark ? const Color(0xFF60A5FA) : const Color(0xFF246BFD)));
                  }

                  List<GoalModel> filteredGoals = provider.goals;
                  if (_selectedFilter == 1) {
                    filteredGoals = provider.activeGoals;
                  } else if (_selectedFilter == 2) {
                    filteredGoals = provider.completedGoals;
                  }

                  return RefreshIndicator(
                    onRefresh: () => provider.loadGoals(),
                    color: isDark ? const Color(0xFF60A5FA) : const Color(0xFF246BFD),
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Column(
                        children: [
                          _buildSummaryCard(provider),
                          const SizedBox(height: 20),
                          _buildFilterTabs(isDark),
                          const SizedBox(height: 16),
                          ...filteredGoals.map((goal) => _buildGoalCard(goal, isDark)),
                          _buildEmptyCard(isDark),
                          const SizedBox(height: 20),
                        ],
                      ),
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

  Widget _buildHeader(bool isDark) {
    final cardColor = isDark ? const Color(0xFF1F2937) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1A1A2E);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: cardColor,
                shape: BoxShape.circle,
                boxShadow: isDark ? [] : [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8, offset: const Offset(0, 2))],
              ),
              child: Icon(Icons.arrow_back, size: 20, color: textColor),
            ),
          ),
          Text(
            'Mục tiêu',
            style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateGoalScreen())).then((_) {
                if (mounted) context.read<GoalProvider>().loadGoals();
              });
            },
            child: Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: cardColor,
                shape: BoxShape.circle,
                boxShadow: isDark ? [] : [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8, offset: const Offset(0, 2))],
              ),
              child: Icon(Icons.add, size: 20, color: isDark ? const Color(0xFF60A5FA) : const Color(0xFF246BFD)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(GoalProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: double.infinity,
        height: 120,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2563EB).withOpacity(0.35),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
          image: const DecorationImage(
            image: AssetImage('assets/images/goal_card_bg.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            // Coin jar illustration aligned right
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 20),
                child: Image.asset(
                  'assets/images/coin_jar.png',
                  width: 100,
                  height: 100,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            // Text content
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 14, 150, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Tổng số tiền',
                    style: GoogleFonts.inter(fontSize: 13, color: Colors.white.withOpacity(0.9)),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatMoneyFull(provider.totalSaved),
                    style: GoogleFonts.inter(
                      fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Từ ${provider.goals.length} mục tiêu',
                    style: GoogleFonts.inter(fontSize: 13, color: Colors.white.withOpacity(0.9)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterTabs(bool isDark) {
    final cardColor = isDark ? const Color(0xFF1F2937) : Colors.white;
    final inactiveTextColor = isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: List.generate(_filters.length, (index) {
          final isSelected = _selectedFilter == index;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedFilter = index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: EdgeInsets.only(right: index < _filters.length - 1 ? 8 : 0),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? (isDark ? const Color(0xFF60A5FA) : const Color(0xFF246BFD)) : cardColor,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: isSelected ? (isDark ? const Color(0xFF60A5FA).withOpacity(0.3) : const Color(0xFF246BFD).withOpacity(0.3)) : (isDark ? Colors.transparent : Colors.black.withOpacity(0.04)),
                      blurRadius: 8, offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    _filters[index],
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white : inactiveTextColor,
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildGoalCard(GoalModel goal, bool isDark) {
    final cardColor = isDark ? const Color(0xFF1F2937) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1A1A2E);
    final secondaryTextColor = isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280);
    final iconBgColor = isDark ? const Color(0xFF374151) : const Color(0xFFEEF2FF);
    final progressBgColor = isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB);
    final statusBgActive = isDark ? const Color(0xFF1E3A8A) : const Color(0xFFE8F3FF);
    final statusBgCompleted = isDark ? const Color(0xFF064E3B) : const Color(0xFFE8FFF3);
    final statusTextActive = isDark ? const Color(0xFF60A5FA) : const Color(0xFF246BFD);
    final statusTextCompleted = isDark ? const Color(0xFF34D399) : const Color(0xFF10B981);

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => GoalDetailScreen(goalId: goal.id)),
      ).then((_) {
        if (mounted) context.read<GoalProvider>().loadGoals();
      }),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: isDark ? [] : [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 2))],
        ),
        child: Row(
          children: [
            // Circle icon (Figma style)
            Container(
              width: 64, height: 64,
              decoration: BoxDecoration(
                color: iconBgColor,
                shape: BoxShape.circle,
              ),
              child: GoalIconMapper.buildGoalIcon(goal.icon, size: 34, color: isDark ? const Color(0xFF60A5FA) : const Color(0xFF246BFD)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          goal.name,
                          style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: textColor),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: goal.isActive ? statusBgActive : statusBgCompleted,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          goal.statusLabel,
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: goal.isActive ? statusTextActive : statusTextCompleted,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  RichText(
                    text: TextSpan(
                      style: GoogleFonts.inter(fontSize: 12),
                      children: [
                        TextSpan(
                          text: _formatMoneyFull(goal.currentAmount),
                          style: TextStyle(fontWeight: FontWeight.w600, color: isDark ? const Color(0xFF60A5FA) : const Color(0xFF246BFD)),
                        ),
                        TextSpan(
                          text: ' / ${_formatMoneyFull(goal.targetAmount)}',
                          style: TextStyle(color: secondaryTextColor),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: goal.progress,
                            backgroundColor: progressBgColor,
                            valueColor: AlwaysStoppedAnimation<Color>(isDark ? const Color(0xFF60A5FA) : const Color(0xFF246BFD)),
                            minHeight: 6,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${(goal.progress * 100).toInt()}%',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isDark ? const Color(0xFF60A5FA) : const Color(0xFF246BFD),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Hạn : ${DateFormat('dd/MM/yyyy').format(goal.deadline)}',
                    style: GoogleFonts.inter(fontSize: 11, color: secondaryTextColor),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyCard(bool isDark) {
    final cardBgColor = isDark ? const Color(0xFF1F2937) : const Color(0xFFF5F8FF);
    final borderColor = isDark ? const Color(0xFF374151) : const Color(0xFFE0E7FF);
    final textColor = isDark ? Colors.white : const Color(0xFF1A1A2E);
    final secondaryTextColor = isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280);
    final actionColor = isDark ? const Color(0xFF60A5FA) : const Color(0xFF2563EB);

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 6, 20, 6),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset('assets/images/goal_target.png', width: 56, height: 56, fit: BoxFit.contain),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Chưa có mục tiêu phù hợp ?',
                  style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: textColor),
                ),
                const SizedBox(height: 4),
                Text(
                  'Tạo mục tiêu tiết kiệm mới để\nđạt được những kế hoạch của bạn',
                  style: GoogleFonts.inter(fontSize: 11, color: secondaryTextColor, height: 1.5),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateGoalScreen())).then((_) {
                      if (mounted) context.read<GoalProvider>().loadGoals();
                    });
                  },
                  child: Text(
                    'Tạo mục tiêu mới',
                    style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: actionColor),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
