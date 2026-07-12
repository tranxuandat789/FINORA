import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile/features/goal/providers/goal_provider.dart';
import 'package:mobile/features/goal/widgets/goal_icon_mapper.dart';
import 'package:mobile/core/utils/snackbar_utils.dart';
import 'package:flutter/services.dart';
import 'package:mobile/core/providers/theme_provider.dart';

class CreateGoalScreen extends StatefulWidget {
  const CreateGoalScreen({Key? key}) : super(key: key);

  @override
  State<CreateGoalScreen> createState() => _CreateGoalScreenState();
}

class _CreateGoalScreenState extends State<CreateGoalScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  
  DateTime? _selectedDate;
  String _selectedIcon = 'savings';
  XFile? _selectedImageFile;
  bool _useImage = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _amountController.addListener(_formatAmount);
  }

  void _formatAmount() {
    String text = _amountController.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (text.isEmpty) return;
    
    final value = int.tryParse(text);
    if (value == null) return;
    
    final formatted = NumberFormat.decimalPattern('vi_VN').format(value);
    
    if (_amountController.text != formatted) {
      _amountController.value = TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    }
  }

  @override
  void dispose() {
    _amountController.removeListener(_formatAmount);
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final isDark = context.read<ThemeProvider>().isDarkMode;
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2050),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: isDark ? const ColorScheme.dark(
              primary: Color(0xFF60A5FA),
              onPrimary: Colors.white,
              surface: Color(0xFF1F2937),
              onSurface: Colors.white,
            ) : const ColorScheme.light(
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
        _selectedImageFile = pickedFile;
        _useImage = true;
      });
    }
  }

  void _showIconOrImagePicker() {
    final isDark = context.read<ThemeProvider>().isDarkMode;
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF1F2937) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.image, color: isDark ? const Color(0xFF60A5FA) : const Color(0xFF246BFD)),
                title: Text('Chọn ảnh từ thư viện', style: GoogleFonts.inter(color: isDark ? Colors.white : const Color(0xFF1A1A2E))),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage();
                },
              ),
              ListTile(
                leading: Icon(Icons.emoji_emotions, color: isDark ? const Color(0xFF60A5FA) : const Color(0xFF246BFD)),
                title: Text('Chọn biểu tượng (icon)', style: GoogleFonts.inter(color: isDark ? Colors.white : const Color(0xFF1A1A2E))),
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
    final isDark = context.read<ThemeProvider>().isDarkMode;
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF1F2937) : Colors.white,
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
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF1A1A2E),
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
                          color: isSelected ? (isDark ? const Color(0xFF60A5FA) : const Color(0xFF246BFD)) : (isDark ? const Color(0xFF374151) : const Color(0xFFF0F4FF)),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          GoalIconMapper.getIcon(iconName),
                          color: isSelected ? Colors.white : (isDark ? const Color(0xFF60A5FA) : const Color(0xFF246BFD)),
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
      SnackBarUtils.showTopSnackBar(context, 'Vui lòng chọn hạn hoàn thành', isSuccess: false);
      return;
    }

    setState(() => _isLoading = true);
    
    final targetAmount = double.tryParse(_amountController.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;

    try {
      String finalIcon = _selectedIcon;
      if (_useImage && _selectedImageFile != null) {
        finalIcon = await context.read<GoalProvider>().uploadGoalImage(_selectedImageFile!);
      }

      await context.read<GoalProvider>().createGoal({
        'name': _nameController.text.trim(),
        'targetAmount': targetAmount,
        'deadline': _selectedDate!.toUtc().toIso8601String(),
        'icon': finalIcon,
      });

      if (mounted) {
        Navigator.pop(context);
        SnackBarUtils.showTopSnackBar(context, 'Tạo mục tiêu thành công!', isSuccess: true);
      }
    } catch (e) {
      if (mounted) {
        SnackBarUtils.showTopSnackBar(context, e.toString(), isSuccess: false);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDarkMode;
    final bgColor = isDark ? const Color(0xFF111827) : const Color(0xFFF5F7FA);
    final cardColor = isDark ? const Color(0xFF1F2937) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1A1A2E);
    final borderColor = isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB);
    final hintColor = isDark ? const Color(0xFF9CA3AF) : const Color(0xFF9CA3AF);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: isDark ? SystemUiOverlayStyle.light.copyWith(statusBarColor: Colors.transparent) : SystemUiOverlayStyle.dark.copyWith(statusBarColor: Colors.transparent),
      child: Scaffold(
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
                        style: GoogleFonts.inter(
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
                                style: GoogleFonts.inter(
                                  color: _selectedDate == null ? hintColor : textColor,
                                  fontSize: 14,
                                ),
                              ),
                              Icon(Icons.calendar_today, color: isDark ? const Color(0xFF60A5FA) : const Color(0xFF246BFD), size: 20),
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
                            backgroundColor: isDark ? const Color(0xFF60A5FA) : const Color(0xFF246BFD),
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
                                  'Tạo mục tiêu',
                                  style: GoogleFonts.inter(
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
            'Tạo mục tiêu mới',
            style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
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
                border: Border.all(color: (isDark ? const Color(0xFF60A5FA) : const Color(0xFF246BFD)).withOpacity(0.3), width: 2),
                image: _useImage && _selectedImageFile != null
                    ? DecorationImage(
                        image: kIsWeb 
                            ? NetworkImage(_selectedImageFile!.path) as ImageProvider 
                            : FileImage(File(_selectedImageFile!.path)),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: (!_useImage)
                  ? Icon(GoalIconMapper.getIcon(_selectedIcon), size: 40, color: isDark ? const Color(0xFF60A5FA) : const Color(0xFF246BFD))
                  : null,
            ),
            Positioned(
              right: 0, bottom: 0,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(color: isDark ? const Color(0xFF60A5FA) : const Color(0xFF246BFD), shape: BoxShape.circle),
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
          style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: textColor),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          style: GoogleFonts.inter(fontSize: 14, color: textColor),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.inter(color: hintColor, fontSize: 14),
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
              borderSide: BorderSide(color: isDark ? const Color(0xFF60A5FA) : const Color(0xFF246BFD)),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
      ],
    );
  }
}
