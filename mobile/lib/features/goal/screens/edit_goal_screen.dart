import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:mobile/features/goal/models/goal_model.dart';
import 'package:mobile/features/goal/providers/goal_provider.dart';
import 'package:mobile/features/goal/widgets/goal_icon_mapper.dart';

class EditGoalScreen extends StatefulWidget {
  final GoalModel goal;
  const EditGoalScreen({Key? key, required this.goal}) : super(key: key);

  @override
  State<EditGoalScreen> createState() => _EditGoalScreenState();
}

class _EditGoalScreenState extends State<EditGoalScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _amountController;
  
  DateTime? _selectedDate;
  late String _selectedIcon;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.goal.name);
    _amountController = TextEditingController(text: widget.goal.targetAmount.toInt().toString());
    _selectedDate = widget.goal.deadline;
    _selectedIcon = widget.goal.icon ?? 'savings';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2050),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF246BFD),
              onPrimary: Colors.white,
              onSurface: Color(0xFF1A1A2E),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _showIconPicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          height: 400,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Chọn biểu tượng',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1A1A2E),
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 5,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                  ),
                  itemCount: GoalIconMapper.availableIconNames.length,
                  itemBuilder: (context, index) {
                    final iconName = GoalIconMapper.availableIconNames[index];
                    final isSelected = iconName == _selectedIcon;
                    return GestureDetector(
                      onTap: () {
                        setState(() => _selectedIcon = iconName);
                        Navigator.pop(context);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFF246BFD) : const Color(0xFFF0F4FF),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          GoalIconMapper.getIcon(iconName),
                          color: isSelected ? Colors.white : const Color(0xFF246BFD),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn hạn hoàn thành')),
      );
      return;
    }

    setState(() => _isLoading = true);
    
    final targetAmount = double.tryParse(_amountController.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;

    try {
      await context.read<GoalProvider>().updateGoal(widget.goal.id, {
        'name': _nameController.text.trim(),
        'targetAmount': targetAmount,
        'deadline': _selectedDate!.toIso8601String(),
        'icon': _selectedIcon,
      });

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cập nhật mục tiêu thành công!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildIconSelector(),
                      const SizedBox(height: 24),
                      _buildTextField(
                        label: 'Tên mục tiêu',
                        controller: _nameController,
                        hint: 'VD: Mua xe máy, Du lịch...',
                        validator: (v) => v!.isEmpty ? 'Không được để trống' : null,
                      ),
                      const SizedBox(height: 20),
                      _buildTextField(
                        label: 'Số tiền mục tiêu (đ)',
                        controller: _amountController,
                        hint: 'Nhập số tiền...',
                        keyboardType: TextInputType.number,
                        validator: (v) {
                          if (v!.isEmpty) return 'Không được để trống';
                          final val = double.tryParse(v.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
                          if (val <= 0) return 'Số tiền phải lớn hơn 0';
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Hạn hoàn thành',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1A1A2E),
                        ),
                      ),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () => _selectDate(context),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFE5E7EB)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _selectedDate == null
                                    ? 'Chọn ngày hoàn thành'
                                    : DateFormat('dd/MM/yyyy').format(_selectedDate!),
                                style: GoogleFonts.poppins(
                                  color: _selectedDate == null ? const Color(0xFF9CA3AF) : const Color(0xFF1A1A2E),
                                  fontSize: 14,
                                ),
                              ),
                              const Icon(Icons.calendar_today, color: Color(0xFF246BFD), size: 20),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _submitForm,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF246BFD),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 0,
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 24, height: 24,
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                )
                              : Text(
                                  'Cập nhật',
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
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
            'Chỉnh sửa mục tiêu',
            style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A2E)),
          ),
          const SizedBox(width: 36),
        ],
      ),
    );
  }

  Widget _buildIconSelector() {
    return Center(
      child: GestureDetector(
        onTap: _showIconPicker,
        child: Stack(
          children: [
            Container(
              width: 80, height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFFF0F4FF),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF246BFD).withOpacity(0.3), width: 2),
              ),
              child: Icon(GoalIconMapper.getIcon(_selectedIcon), size: 40, color: const Color(0xFF246BFD)),
            ),
            Positioned(
              right: 0, bottom: 0,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(color: Color(0xFF246BFD), shape: BoxShape.circle),
                child: const Icon(Icons.edit, size: 14, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF1A1A2E)),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          style: GoogleFonts.poppins(fontSize: 14, color: const Color(0xFF1A1A2E)),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.poppins(color: const Color(0xFF9CA3AF), fontSize: 14),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF246BFD)),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
      ],
    );
  }
}
