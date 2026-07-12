import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:mobile/features/analytics/providers/analytics_provider.dart';
import 'package:intl/intl.dart';
import 'package:mobile/core/providers/theme_provider.dart';
import 'package:mobile/features/dashboard/screens/dashboard_screen.dart';
import 'package:mobile/features/transaction/providers/transaction_provider.dart';
import 'package:auto_size_text/auto_size_text.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({Key? key}) : super(key: key);

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AnalyticsProvider>().fetchAnalytics();
    });
  }

  String _formatCurrency(double amount) {
    final formatter = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ', decimalDigits: 0);
    return formatter.format(amount);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDarkMode;
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF111827) : const Color(0xFFF9FAFB),
      body: SafeArea(
        child: Consumer<AnalyticsProvider>(
          builder: (context, provider, child) {
            return RefreshIndicator(
              onRefresh: () => provider.fetchAnalytics(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      children: [
                        if (Navigator.canPop(context))
                          IconButton(
                            icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.black),
                            onPressed: () => Navigator.pop(context),
                          ),
                        Expanded(
                          child: Center(
                            child: Padding(
                              padding: EdgeInsets.only(right: Navigator.canPop(context) ? 48.0 : 0),
                              child: Text(
                                'Phân tích',
                                style: GoogleFonts.inter(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : const Color(0xFF111827),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    _buildModePicker(context, provider, isDark),
                    const SizedBox(height: 16),

                    _buildDatePicker(context, provider, isDark),
                    const SizedBox(height: 24),

                    if (provider.isLoading && provider.analyticsData == null)
                      const Center(child: Padding(
                        padding: EdgeInsets.all(32.0),
                        child: CircularProgressIndicator(),
                      ))
                    else if (provider.error != null && provider.analyticsData == null)
                      Center(child: Text(provider.error!, style: const TextStyle(color: Colors.red)))
                    else if (provider.analyticsData != null) ...[
                      _buildOverviewCard(provider, isDark),
                      const SizedBox(height: 24),
                      _buildCategorySpendingCard(provider, isDark),
                      const SizedBox(height: 24),
                      _buildSpendingTrendCard(provider, isDark),
                      const SizedBox(height: 80),
                    ] else
                      const Center(child: Text('Không có dữ liệu')),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildModePicker(BuildContext context, AnalyticsProvider provider, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF374151) : const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => provider.changeMode('month'),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: provider.mode == 'month' ? (isDark ? const Color(0xFF4B5563) : Colors.white) : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: provider.mode == 'month' ? [
                    BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))
                  ] : null,
                ),
                child: Center(
                  child: Text(
                    'Tháng',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: provider.mode == 'month' ? FontWeight.w600 : FontWeight.w500,
                      color: provider.mode == 'month' ? (isDark ? Colors.white : const Color(0xFF111827)) : (isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280)),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => provider.changeMode('year'),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: provider.mode == 'year' ? (isDark ? const Color(0xFF4B5563) : Colors.white) : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: provider.mode == 'year' ? [
                    BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))
                  ] : null,
                ),
                child: Center(
                  child: Text(
                    'Năm',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: provider.mode == 'year' ? FontWeight.w600 : FontWeight.w500,
                      color: provider.mode == 'year' ? (isDark ? Colors.white : const Color(0xFF111827)) : (isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280)),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDatePicker(BuildContext context, AnalyticsProvider provider, bool isDark) {
    final dateStr = provider.mode == 'month' 
        ? DateFormat('MM/yyyy').format(provider.currentDate)
        : DateFormat('yyyy').format(provider.currentDate);
        
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF374151) : const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => provider.changeDate(-1),
              borderRadius: BorderRadius.circular(20),
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Icon(Icons.chevron_left, color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF4B5563)),
              ),
            ),
          ),
          Text(
            provider.mode == 'month' ? 'Tháng $dateStr' : 'Năm $dateStr',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDark ? const Color(0xFFD1D5DB) : const Color(0xFF4B5563),
            ),
          ),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => provider.changeDate(1),
              borderRadius: BorderRadius.circular(20),
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Icon(Icons.chevron_right, color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF4B5563)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewCard(AnalyticsProvider provider, bool isDark) {
    final data = provider.analyticsData!;
    return GestureDetector(
      onTap: () {
        context.read<TransactionProvider>().setSearchQuery('');
        final dashState = context.findAncestorStateOfType<DashboardScreenState>();
        dashState?.switchToTab(1);
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1F2937) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tổng quan',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF111827),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildOverviewItem(
                  title: 'Thu nhập',
                  amount: data.totalIncome,
                  color: const Color(0xFF10B981),
                  isDark: isDark,
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 32.0),
                  child: _buildOverviewItem(
                    title: 'Chi tiêu',
                    amount: data.totalExpense,
                    color: const Color(0xFFEF4444),
                    isDark: isDark,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildOverviewItem(
            title: 'Tổng thu chi',
            amount: data.netIncome,
            color: data.netIncome >= 0 ? const Color(0xFF3B82F6) : const Color(0xFFF59E0B),
            isDark: isDark,
            isLarge: true,
          ),
        ],
      ),
    ),
    );
  }

  Widget _buildOverviewItem({
    required String title,
    required double amount,
    required Color color,
    required bool isDark,
    bool isLarge = false,
  }) {
    return Column(
      crossAxisAlignment: isLarge ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: isLarge ? 14 : 12,
            color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          _formatCurrency(amount),
          style: GoogleFonts.inter(
            fontSize: isLarge ? 24 : 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildCategorySpendingCard(AnalyticsProvider provider, bool isDark) {
    final data = provider.analyticsData!;
    if (data.categoryExpenses.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1F2937) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Text(
            'Chưa có phát sinh chi tiêu',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
            ),
          ),
        ),
      );
    }

    final List<Color> colors = [
      const Color(0xFF2563EB),
      const Color(0xFF10B981),
      const Color(0xFFF59E0B),
      const Color(0xFF8B5CF6),
      const Color(0xFFEF4444),
      const Color(0xFF06B6D4),
      const Color(0xFFF43F5E),
      const Color(0xFF8B5CF6),
    ];

    int colorIndex = 0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1F2937) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Chi tiêu theo danh mục',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 20),
          Column(
            children: [
              // Donut Chart
              Center(
                child: SizedBox(
                  width: 240,
                  height: 240,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      PieChart(
                        PieChartData(
                          sectionsSpace: 2,
                          centerSpaceRadius: 80,
                          sections: data.categoryExpenses.map((cat) {
                            final color = colors[colorIndex % colors.length];
                            colorIndex++;
                            return PieChartSectionData(
                              color: color,
                              value: cat.amount,
                              title: '',
                              radius: 30,
                            );
                          }).toList(),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                _formatCurrency(data.totalExpense),
                                style: GoogleFonts.inter(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : Colors.black,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Tổng chi',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              // Legend
              Column(
                children: data.categoryExpenses.asMap().entries.map((entry) {
                  final index = entry.key;
                  final cat = entry.value;
                  final color = colors[index % colors.length];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Builder(
                      builder: (ctx) => GestureDetector(
                        onTap: () {
                          ctx.read<TransactionProvider>().setSearchQuery(cat.categoryName);
                          final dashState = ctx.findAncestorStateOfType<DashboardScreenState>();
                          dashState?.switchToTab(1);
                        },
                        behavior: HitTestBehavior.opaque,
                        child: Row(
                          children: [
                            Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                            const SizedBox(width: 12),
                            Expanded(child: Text(cat.categoryName, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: isDark ? const Color(0xFFE5E7EB) : const Color(0xFF374151)), overflow: TextOverflow.ellipsis)),
                            Text(_formatCurrency(cat.amount), style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: isDark ? Colors.white : Colors.black)),
                            const SizedBox(width: 12),
                            SizedBox(width: 50, child: Text('${cat.percentage.toStringAsFixed(1)}%', textAlign: TextAlign.right, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500, color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280)))),
                            const SizedBox(width: 8),
                            Icon(Icons.chevron_right, size: 18, color: isDark ? const Color(0xFF6B7280) : const Color(0xFF9CA3AF)),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSpendingTrendCard(AnalyticsProvider provider, bool isDark) {
    final data = provider.analyticsData!;
    
    double maxAmount = 0;
    for (var day in data.dailyExpenses) {
      if (day.amount > maxAmount) {
        maxAmount = day.amount;
      }
    }
    
    if (maxAmount == 0) maxAmount = 100;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1F2937) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Xu hướng chi tiêu',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _formatCurrency(data.totalExpense),
                    style: GoogleFonts.inter(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF111827),
                    ),
                  ),
                  Text(
                    'Tổng chi tiêu',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: data.percentageChange >= 0 ? const Color(0xFFFEE2E2) : const Color(0xFFD1FAE5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${data.percentageChange >= 0 ? '+' : ''}${data.percentageChange.toStringAsFixed(1)}%',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: data.percentageChange >= 0 ? const Color(0xFFEF4444) : const Color(0xFF059669),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          // Line Chart
          SizedBox(
            height: 150,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: maxAmount / 3 > 0 ? maxAmount / 3 : 1,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: isDark ? const Color(0xFF374151) : const Color(0xFFF3F4F6),
                      strokeWidth: 1,
                      dashArray: [5, 5],
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 22,
                      interval: 5,
                      getTitlesWidget: (value, meta) {
                        if (value == 0 || value >= data.dailyExpenses.length - 1) {
                          return const SizedBox.shrink();
                        }
                        final style = TextStyle(
                          color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
                          fontWeight: FontWeight.w500,
                          fontSize: 10,
                        );
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text('${value.toInt() + 1}', style: style),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: (data.dailyExpenses.length - 1).toDouble(),
                minY: 0,
                maxY: maxAmount * 1.2,
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (touchedSpot) => isDark ? const Color(0xFF374151) : Colors.white,
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((spot) {
                        return LineTooltipItem(
                          _formatCurrency(spot.y),
                          GoogleFonts.inter(
                            color: isDark ? Colors.white : const Color(0xFF111827),
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        );
                      }).toList();
                    },
                  ),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: data.dailyExpenses.asMap().entries.map((e) {
                      return FlSpot(e.key.toDouble(), e.value.amount);
                    }).toList(),
                    isCurved: true,
                    color: const Color(0xFF2563EB),
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: const Color(0xFF2563EB).withOpacity(0.1),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
