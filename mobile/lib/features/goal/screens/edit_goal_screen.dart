import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile/features/goal/models/goal_model.dart';
import 'package:mobile/features/goal/providers/goal_provider.dart';
import 'package:mobile/features/goal/widgets/goal_icon_mapper.dart';
import 'package:mobile/core/utils/snackbar_utils.dart';

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
  String? _selectedImagePath;
  bool _useImage = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.goal.name);
    _amountController = TextEditingController(text: widget.goal.targetAmount.toInt().toString());
    _selectedDate = widget.goal.deadline;
    _selectedIcon = widget.goal.icon ?? 'savings';
    _useImage = GoalIconMapper.isUrl(_selectedIcon);
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

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImagePath = pickedFile.path;
        _useImage = true;
      });
    }
  }

  void _showIconOrImagePicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.image, color: Color(0xFF246BFD)),
                title: Text('Chọn ảnh từ thư viện', style: GoogleFonts.poppins()),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage();
                },
              ),
              ListTile(
                leading: const Icon(Icons.emoji_emotions, color: Color(0xFF246BFD)),
                title: Text('Chọn biểu tượng (icon)', style: GoogleFonts.poppins()),
                onTap: () {
                  Navigator.pop(context);
                  _useImage = false;
                  _showIconPicker();
                },
              ),
            ],
          ),
        );
      },
    );
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
      SnackBarUtils.showTopSnackBar(
        context,
        'Vui lòng chọn hạn hoàn thành',
        isSuccess: false,
      );
      return;
    }

    setState(() => _isLoading = true);
    
    final targetAmount = double.tryParse(_amountController.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;

    try {
      String finalIcon = _selectedIcon;
      if (_useImage && _selectedImagePath != null) {
        finalIcon = await context.read<GoalProvider>().uploadGoalImage(_selectedImagePath!);
      }

      await context.read<GoalProvider>().updateGoal(widget.goal.id, {
        'name': _nameController.text.trim(),
        'targetAmount': targetAmount,
        'deadline': _selectedDate!.toIso8601String(),
        'icon': finalIcon,
      });

      if (mounted) {
        Navigator.pop(context, true);
        SnackBarUtils.showTopSnackBar(
          context,
          'Cập nhật mục tiêu thành công!',
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
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF1F2937) : const Color(0xFFF5F7FA);
    final cardColor = isDark ? const Color(0xFF111827) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1A1A2E);
    final borderColor = isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB);
    final hintColor = isDark ? const Color(0xFF9CA3AF) : const Color(0xFF9CA3AF);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(isDark, cardColor, textColor),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildIconSelector(isDark),
                      const SizedBox(height: 24),
                      _buildTextField(
                        label: 'Tên mục tiêu',
                        controller: _nameController,
                        hint: 'VD: Mua xe máy, Du lịch...',
                        validator: (v) => v!.isEmpty ? 'Không được để trống' : null,
                        isDark: isDark, cardColor: cardColor, textColor: textColor, borderColor: borderColor, hintColor: hintColor,
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
                        isDark: isDark, cardColor: cardColor, textColor: textColor, borderColor: borderColor, hintColor: hintColor,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Hạn hoàn thành',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () => _selectDate(context),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          decoration: BoxDecoration(
                            color: cardColor,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: borderColor),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _selectedDate == null
                                    ? 'Chọn ngày hoàn thành'
                                    : DateFormat('dd/MM/yyyy').format(_selectedDate!),
                                style: GoogleFonts.poppins(
                                  color: _selectedDate == null ? hintColor : textColor,
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

  Widget _buildHeader(bool isDark, Color cardColor, Color textColor) {
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
            'Chỉnh sửa mục tiêu',
            style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
          ),
          const SizedBox(width: 36),
        ],
      ),
    );
  }

  Widget _buildIconSelector(bool isDark) {
    return Center(
      child: GestureDetector(
        onTap: _showIconOrImagePicker,
        child: Stack(
          children: [
            Container(
              width: 80, height: 80,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF374151) : const Color(0xFFF0F4FF),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF246BFD).withOpacity(0.3), width: 2),
                image: _useImage && _selectedImagePath != null
                    ? DecorationImage(
                        image: kIsWeb 
                            ? NetworkImage(_selectedImagePath!) as ImageProvider 
                            : FileImage(File(_selectedImagePath!)),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: (!_useImage || (_useImage && _selectedImagePath == null))
                  ? GoalIconMapper.buildGoalIcon(_selectedIcon, size: 40, color: const Color(0xFF246BFD))
                  : null,
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
    required bool isDark,
    required Color cardColor,
    required Color textColor,
    required Color borderColor,
    required Color hintColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: textColor),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          style: GoogleFonts.poppins(fontSize: 14, color: textColor),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.poppins(color: hintColor, fontSize: 14),
            filled: true,
            fillColor: cardColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: borderColor),
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
