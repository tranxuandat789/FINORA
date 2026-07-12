import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:mobile/features/goal/models/goal_model.dart';
import 'package:mobile/features/goal/providers/goal_provider.dart';
import 'package:mobile/features/goal/widgets/goal_icon_mapper.dart';
import 'package:mobile/core/utils/snackbar_utils.dart';
import 'package:mobile/core/providers/theme_provider.dart';
import 'package:flutter/services.dart';
import 'edit_goal_screen.dart';

class GoalDetailScreen extends StatefulWidget {
  final String goalId;
  const GoalDetailScreen({Key? key, required this.goalId}) : super(key: key);

  @override
  State<GoalDetailScreen> createState() => _GoalDetailScreenState();
}

class _GoalDetailScreenState extends State<GoalDetailScreen> {
  GoalModel? _goal;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadGoal();
  }

  Future<void> _loadGoal() async {
    setState(() => _isLoading = true);
    final goal = await context.read<GoalProvider>().getGoalDetail(widget.goalId);
    if (mounted) {
      setState(() {
        _goal = goal;
        _isLoading = false;
      });
    }
  }

  String _formatMoneyFull(double amount) {
    final str = amount.abs().toInt().toString();
    final result = StringBuffer();
    int count = 0;
    for (int i = str.length - 1; i >= 0; i--) {
      if (count > 0 && count % 3 == 0) result.write('.');
      result.write(str[i]);
      count++;
    }
    return '${amount < 0 ? "-" : ""}${result.toString().split('').reversed.join('')}đ';
  }

  void _showContributionSheet(bool isWithdrawal, bool isDark) {
    final amountController = TextEditingController();
    amountController.addListener(() {
      String text = amountController.text.replaceAll(RegExp(r'[^0-9]'), '');
      if (text.isEmpty) return;
      final value = int.tryParse(text);
      if (value == null) return;
      final formatted = NumberFormat.decimalPattern('vi_VN').format(value);
      if (amountController.text != formatted) {
        amountController.value = TextEditingValue(
          text: formatted,
          selection: TextSelection.collapsed(offset: formatted.length),
        );
      }
    });
    
    final noteController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool isSubmitting = false;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF1F2937) : Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateSheet) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 20, right: 20, top: 24,
              ),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          isWithdrawal ? 'Rút tiền khỏi mục tiêu' : 'Đóng góp vào mục tiêu',
                          style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF1A1A2E)),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Icon(Icons.close, color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280)),
                        )
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text('Số tiền (đ)', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: isDark ? Colors.white : const Color(0xFF1A1A2E))),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: amountController,
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Không được để trống';
                        final val = double.tryParse(v.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
                        if (val <= 0) return 'Số tiền phải lớn hơn 0';
                        if (isWithdrawal && _goal != null && val > _goal!.currentAmount) {
                          return 'Vượt quá số tiền đang có';
                        }
                        return null;
                      },
                      style: GoogleFonts.inter(fontSize: 16, color: isDark ? Colors.white : const Color(0xFF1A1A2E)),
                      decoration: InputDecoration(
                        hintText: 'Nhập số tiền...',
                        hintStyle: GoogleFonts.inter(color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF9CA3AF)),
                        filled: true,
                        fillColor: isDark ? const Color(0xFF374151) : const Color(0xFFF9FAFB),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text('Ghi chú (Không bắt buộc)', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: isDark ? Colors.white : const Color(0xFF1A1A2E))),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: noteController,
                      style: GoogleFonts.inter(fontSize: 14, color: isDark ? Colors.white : const Color(0xFF1A1A2E)),
                      decoration: InputDecoration(
                        hintText: 'Nhập ghi chú...',
                        hintStyle: GoogleFonts.inter(color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF9CA3AF)),
                        filled: true,
                        fillColor: isDark ? const Color(0xFF374151) : const Color(0xFFF9FAFB),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      ),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: isSubmitting ? null : () async {
                          if (!formKey.currentState!.validate()) return;
                          setStateSheet(() => isSubmitting = true);
                          try {
                            final val = double.tryParse(amountController.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
                            final data = {'amount': val, 'note': noteController.text.trim()};
                            
                            if (isWithdrawal) {
                              await context.read<GoalProvider>().withdraw(_goal!.id, data);
                            } else {
                              await context.read<GoalProvider>().addContribution(_goal!.id, data);
                            }
                            
                              if (mounted) {
                                Navigator.pop(context);
                                _loadGoal();
                                SnackBarUtils.showTopSnackBar(
                                  context,
                                  isWithdrawal ? 'Rút tiền thành công' : 'Đóng góp thành công',
                                  isSuccess: true,
                                );
                            }
                          } catch (e) {
                            SnackBarUtils.showTopSnackBar(
                              context,
                              e.toString(),
                              isSuccess: false,
                            );
                          } finally {
                            if (mounted) setStateSheet(() => isSubmitting = false);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isWithdrawal ? const Color(0xFFFF4D4D) : const Color(0xFF10B981),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 0,
                        ),
                        child: isSubmitting
                            ? const CircularProgressIndicator(color: Colors.white)
                            : Text(
                                isWithdrawal ? 'Xác nhận rút' : 'Xác nhận đóng góp',
                                style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
                              ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _deleteGoal(bool isDark) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1F2937) : Colors.white,
        title: Text('Xóa mục tiêu', style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF111827))),
        content: Text('Bạn có chắc chắn muốn xóa mục tiêu này? Nếu bạn xóa, các giao dịch liên quan sẽ không hiển thị trên mục tiêu này nữa.', style: GoogleFonts.inter(fontSize: 14, color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF4B5563))),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Hủy', style: GoogleFonts.inter(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Xóa', style: GoogleFonts.inter(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      try {
        await context.read<GoalProvider>().deleteGoal(_goal!.id);
        if (mounted) {
          Navigator.pop(context);
          SnackBarUtils.showTopSnackBar(
            context,
            'Đã xóa mục tiêu',
            isSuccess: true,
          );
        }
      } catch (e) {
        if (mounted) {
          SnackBarUtils.showTopSnackBar(
            context,
            e.toString(),
            isSuccess: false,
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDarkMode;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: isDark ? const Color(0xFF111827) : const Color(0xFFF5F7FA),
        body: Center(child: CircularProgressIndicator(color: isDark ? const Color(0xFF60A5FA) : const Color(0xFF246BFD))),
      );
    }

    if (_goal == null) {
      return Scaffold(
        backgroundColor: isDark ? const Color(0xFF111827) : const Color(0xFFF5F7FA),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Không tìm thấy mục tiêu', style: GoogleFonts.inter(fontSize: 16, color: isDark ? Colors.white : const Color(0xFF111827))),
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Quay lại'))
            ],
          ),
        ),
      );
    }

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: isDark ? SystemUiOverlayStyle.light.copyWith(statusBarColor: Colors.transparent) : SystemUiOverlayStyle.dark.copyWith(statusBarColor: Colors.transparent),
      child: Scaffold(
        backgroundColor: isDark ? const Color(0xFF111827) : const Color(0xFFF5F7FA),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(isDark),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildMainCard(isDark),
                    const SizedBox(height: 24),
                    _buildActionButtons(isDark),
                    const SizedBox(height: 32),
                    Text(
                      'Lịch sử giao dịch',
                      style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF1A1A2E)),
                    ),
                    const SizedBox(height: 16),
                    _buildHistoryList(isDark),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
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
                color: isDark ? const Color(0xFF374151) : Colors.white,
                shape: BoxShape.circle,
                boxShadow: isDark ? [] : [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8, offset: const Offset(0, 2))],
              ),
              child: Icon(Icons.arrow_back, size: 20, color: isDark ? Colors.white : const Color(0xFF1A1A2E)),
            ),
          ),
          Text(
            'Chi tiết mục tiêu',
            style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF1A1A2E)),
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: isDark ? Colors.white : const Color(0xFF1A1A2E)),
            color: isDark ? const Color(0xFF374151) : Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            onSelected: (value) {
              if (value == 'edit') {
                Navigator.push(context, MaterialPageRoute(builder: (_) => EditGoalScreen(goal: _goal!))).then((res) {
                  if (res == true) _loadGoal();
                });
              } else if (value == 'delete') {
                _deleteGoal(isDark);
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit, size: 20, color: isDark ? const Color(0xFF60A5FA) : const Color(0xFF246BFD)),
                    const SizedBox(width: 12),
                    Text('Chỉnh sửa', style: GoogleFonts.inter(fontSize: 14, color: isDark ? Colors.white : const Color(0xFF1A1A2E))),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    const Icon(Icons.delete, size: 20, color: Colors.red),
                    const SizedBox(width: 12),
                    Text('Xóa', style: GoogleFonts.inter(fontSize: 14, color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMainCard(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1F2937) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: isDark ? [] : [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 8)),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 80, height: 80,
            decoration: BoxDecoration(color: isDark ? const Color(0xFF1E3A8A) : const Color(0xFFF0F4FF), shape: BoxShape.circle),
            child: GoalIconMapper.buildGoalIcon(_goal!.icon, size: 40, color: isDark ? const Color(0xFF60A5FA) : const Color(0xFF246BFD)),
          ),
          const SizedBox(height: 16),
          Text(
            _goal!.name,
            style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF1A1A2E)),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _goal!.isActive 
                ? (isDark ? const Color(0xFF1E3A8A) : const Color(0xFFE8F3FF)) 
                : (isDark ? const Color(0xFF064E3B) : const Color(0xFFE8FFF3)),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _goal!.statusLabel,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: _goal!.isActive ? (isDark ? const Color(0xFF60A5FA) : const Color(0xFF246BFD)) : const Color(0xFF10B981),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Đã tiết kiệm', style: GoogleFonts.inter(fontSize: 13, color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280))),
                  const SizedBox(height: 4),
                  Text(
                    _formatMoneyFull(_goal!.currentAmount),
                    style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? const Color(0xFF60A5FA) : const Color(0xFF246BFD)),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('Mục tiêu', style: GoogleFonts.inter(fontSize: 13, color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280))),
                  const SizedBox(height: 4),
                  Text(
                    _formatMoneyFull(_goal!.targetAmount),
                    style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: isDark ? Colors.white : const Color(0xFF1A1A2E)),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: _goal!.progress,
              backgroundColor: isDark ? const Color(0xFF374151) : const Color(0xFFF3F4F6),
              valueColor: AlwaysStoppedAnimation<Color>(isDark ? const Color(0xFF60A5FA) : const Color(0xFF246BFD)),
              minHeight: 12,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${(_goal!.progress * 100).toInt()}% hoàn thành', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: isDark ? const Color(0xFF60A5FA) : const Color(0xFF246BFD))),
              Text(
                _goal!.isActive ? 'Còn ${_goal!.daysLeft} ngày' : 'Đã đạt mục tiêu',
                style: GoogleFonts.inter(fontSize: 12, color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(bool isDark) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: !_goal!.isActive ? null : () => _showContributionSheet(false, isDark),
            style: ElevatedButton.styleFrom(
              backgroundColor: isDark ? const Color(0xFF60A5FA) : const Color(0xFF246BFD),
              disabledBackgroundColor: isDark ? const Color(0xFF4B5563) : const Color(0xFF9CA3AF),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.add_circle_outline, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Text('Đóng góp', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: _goal!.currentAmount <= 0 ? null : () => _showContributionSheet(true, isDark),
            style: ElevatedButton.styleFrom(
              backgroundColor: isDark ? const Color(0xFF374151) : const Color(0xFFF3F4F6),
              disabledBackgroundColor: isDark ? const Color(0xFF1F2937) : const Color(0xFFF9FAFB),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.remove_circle_outline, color: _goal!.currentAmount <= 0 ? (isDark ? const Color(0xFF4B5563) : const Color(0xFF9CA3AF)) : (isDark ? Colors.white : const Color(0xFF1A1A2E)), size: 20),
                const SizedBox(width: 8),
                Text('Rút tiền', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: _goal!.currentAmount <= 0 ? (isDark ? const Color(0xFF4B5563) : const Color(0xFF9CA3AF)) : (isDark ? Colors.white : const Color(0xFF1A1A2E)))),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryList(bool isDark) {
    if (_goal!.contributions.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text('Chưa có giao dịch nào', style: GoogleFonts.inter(color: const Color(0xFF9CA3AF))),
        ),
      );
    }
    
    return Column(
      children: _goal!.contributions.map((contribution) {
        final isWithdraw = contribution.isWithdrawal;
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1F2937) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: isDark ? [] : [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 2))],
          ),
          child: Row(
            children: [
              Container(
                width: 48, height: 48,
                decoration: BoxDecoration(
                  color: isWithdraw ? (isDark ? const Color(0xFF7F1D1D) : const Color(0xFFFFF0F0)) : (isDark ? const Color(0xFF064E3B) : const Color(0xFFE8FFF3)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isWithdraw ? Icons.arrow_upward : Icons.arrow_downward,
                  color: isWithdraw ? const Color(0xFFFF4D4D) : const Color(0xFF10B981),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isWithdraw ? 'Rút tiền' : 'Đóng góp',
                      style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: isDark ? Colors.white : const Color(0xFF1A1A2E)),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      contribution.note?.isNotEmpty == true ? contribution.note! : 'Không có ghi chú',
                      style: GoogleFonts.inter(fontSize: 12, color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280)),
                      maxLines: 1, overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${isWithdraw ? "" : "+"}${_formatMoneyFull(contribution.amount)}',
                    style: GoogleFonts.inter(
                      fontSize: 14, fontWeight: FontWeight.bold,
                      color: isWithdraw ? const Color(0xFFFF4D4D) : const Color(0xFF10B981),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('dd/MM/yyyy HH:mm').format(contribution.contributionDate),
                    style: GoogleFonts.inter(fontSize: 11, color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF9CA3AF)),
                  ),
                ],
              )
            ],
          ),
        );
      }).toList(),
    );
  }
}
