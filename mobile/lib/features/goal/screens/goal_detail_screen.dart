import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:mobile/features/goal/models/goal_model.dart';
import 'package:mobile/features/goal/providers/goal_provider.dart';
import 'package:mobile/features/goal/widgets/goal_icon_mapper.dart';
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

  void _showContributionSheet(bool isWithdrawal) {
    final amountController = TextEditingController();
    final noteController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool isSubmitting = false;

    showModalBottomSheet(
      context: context,
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
                          style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A2E)),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: const Icon(Icons.close, color: Color(0xFF6B7280)),
                        )
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text('Số tiền (đ)', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF1A1A2E))),
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
                      style: GoogleFonts.poppins(fontSize: 16),
                      decoration: InputDecoration(
                        hintText: 'Nhập số tiền...',
                        filled: true,
                        fillColor: const Color(0xFFF9FAFB),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text('Ghi chú (Không bắt buộc)', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF1A1A2E))),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: noteController,
                      style: GoogleFonts.poppins(fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'Nhập ghi chú...',
                        filled: true,
                        fillColor: const Color(0xFFF9FAFB),
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
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(isWithdrawal ? 'Rút tiền thành công' : 'Đóng góp thành công')),
                              );
                            }
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
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
                                style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
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

  Future<void> _deleteGoal() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Xóa mục tiêu', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: Text('Bạn có chắc chắn muốn xóa mục tiêu này? Nếu bạn xóa, các giao dịch liên quan sẽ không hiển thị trên mục tiêu này nữa.', style: GoogleFonts.poppins(fontSize: 14)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Hủy', style: GoogleFonts.poppins(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Xóa', style: GoogleFonts.poppins(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      try {
        await context.read<GoalProvider>().deleteGoal(_goal!.id);
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã xóa mục tiêu')));
        }
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF5F7FA),
        body: Center(child: CircularProgressIndicator(color: Color(0xFF246BFD))),
      );
    }

    if (_goal == null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF5F7FA),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Không tìm thấy mục tiêu', style: GoogleFonts.poppins(fontSize: 16)),
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Quay lại'))
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildMainCard(),
                    const SizedBox(height: 24),
                    _buildActionButtons(),
                    const SizedBox(height: 32),
                    Text(
                      'Lịch sử giao dịch',
                      style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A2E)),
                    ),
                    const SizedBox(height: 16),
                    _buildHistoryList(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
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
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8, offset: const Offset(0, 2))],
              ),
              child: const Icon(Icons.arrow_back, size: 20, color: Color(0xFF1A1A2E)),
            ),
          ),
          Text(
            'Chi tiết mục tiêu',
            style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A2E)),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Color(0xFF1A1A2E)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            onSelected: (value) {
              if (value == 'edit') {
                Navigator.push(context, MaterialPageRoute(builder: (_) => EditGoalScreen(goal: _goal!))).then((res) {
                  if (res == true) _loadGoal();
                });
              } else if (value == 'delete') {
                _deleteGoal();
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    const Icon(Icons.edit, size: 20, color: Color(0xFF246BFD)),
                    const SizedBox(width: 12),
                    Text('Chỉnh sửa', style: GoogleFonts.poppins(fontSize: 14, color: const Color(0xFF1A1A2E))),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    const Icon(Icons.delete, size: 20, color: Colors.red),
                    const SizedBox(width: 12),
                    Text('Xóa', style: GoogleFonts.poppins(fontSize: 14, color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMainCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 8)),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 80, height: 80,
            decoration: BoxDecoration(color: const Color(0xFFF0F4FF), shape: BoxShape.circle),
            child: Icon(GoalIconMapper.getIcon(_goal!.icon), size: 40, color: const Color(0xFF246BFD)),
          ),
          const SizedBox(height: 16),
          Text(
            _goal!.name,
            style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A2E)),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _goal!.isActive ? const Color(0xFFE8F3FF) : const Color(0xFFE8FFF3),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _goal!.statusLabel,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: _goal!.isActive ? const Color(0xFF246BFD) : const Color(0xFF10B981),
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
                  Text('Đã tiết kiệm', style: GoogleFonts.poppins(fontSize: 13, color: const Color(0xFF6B7280))),
                  const SizedBox(height: 4),
                  Text(
                    _formatMoneyFull(_goal!.currentAmount),
                    style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF246BFD)),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('Mục tiêu', style: GoogleFonts.poppins(fontSize: 13, color: const Color(0xFF6B7280))),
                  const SizedBox(height: 4),
                  Text(
                    _formatMoneyFull(_goal!.targetAmount),
                    style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: const Color(0xFF1A1A2E)),
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
              backgroundColor: const Color(0xFFF3F4F6),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF246BFD)),
              minHeight: 12,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${(_goal!.progress * 100).toInt()}% hoàn thành', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF246BFD))),
              Text(
                _goal!.isActive ? 'Còn ${_goal!.daysLeft} ngày' : 'Đã đạt mục tiêu',
                style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF6B7280)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: !_goal!.isActive ? null : () => _showContributionSheet(false),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF246BFD),
              disabledBackgroundColor: const Color(0xFF9CA3AF),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.add_circle_outline, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Text('Đóng góp', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: _goal!.currentAmount <= 0 ? null : () => _showContributionSheet(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF3F4F6),
              disabledBackgroundColor: const Color(0xFFF9FAFB),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.remove_circle_outline, color: _goal!.currentAmount <= 0 ? const Color(0xFF9CA3AF) : const Color(0xFF1A1A2E), size: 20),
                const SizedBox(width: 8),
                Text('Rút tiền', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: _goal!.currentAmount <= 0 ? const Color(0xFF9CA3AF) : const Color(0xFF1A1A2E))),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryList() {
    if (_goal!.contributions.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text('Chưa có giao dịch nào', style: GoogleFonts.poppins(color: const Color(0xFF9CA3AF))),
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
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 2))],
          ),
          child: Row(
            children: [
              Container(
                width: 48, height: 48,
                decoration: BoxDecoration(
                  color: isWithdraw ? const Color(0xFFFFF0F0) : const Color(0xFFE8FFF3),
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
                      style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF1A1A2E)),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      contribution.note?.isNotEmpty == true ? contribution.note! : 'Không có ghi chú',
                      style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF6B7280)),
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
                    style: GoogleFonts.poppins(
                      fontSize: 14, fontWeight: FontWeight.bold,
                      color: isWithdraw ? const Color(0xFFFF4D4D) : const Color(0xFF10B981),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('dd/MM/yyyy HH:mm').format(contribution.contributionDate),
                    style: GoogleFonts.poppins(fontSize: 11, color: const Color(0xFF9CA3AF)),
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
