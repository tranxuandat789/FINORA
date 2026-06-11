import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:mobile/features/auth/providers/auth_provider.dart';
import 'package:mobile/features/profile/providers/profile_provider.dart';
import 'package:mobile/core/utils/snackbar_utils.dart';

class AccountInfoScreen extends StatefulWidget {
  const AccountInfoScreen({super.key});

  @override
  State<AccountInfoScreen> createState() => _AccountInfoScreenState();
}

class _AccountInfoScreenState extends State<AccountInfoScreen> {
  late TextEditingController _nameCtrl;
  late TextEditingController _emailCtrl;
  late TextEditingController _phoneCtrl;
  bool _isEditing = false;
  XFile? _pendingAvatar;
  String? _currentAvatarUrl;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().user;
    _nameCtrl = TextEditingController(text: user?['fullName'] ?? '');
    _emailCtrl = TextEditingController(text: user?['email'] ?? '');
    _phoneCtrl = TextEditingController(text: user?['phoneNumber'] ?? '');
    _currentAvatarUrl = user?['avatarUrl'] as String?;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  // ─── Pick image ──────────────────────────────────────────────────────────

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    // Chỉ cho phép chọn ảnh (image/jpeg, image/png...)
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 85,
      requestFullMetadata: false,
    );
    if (picked != null) {
      setState(() {
        _pendingAvatar = picked;
        _isEditing = true;
      });
    }
  }

  // ─── Save ────────────────────────────────────────────────────────────────

  Future<void> _save() async {
    // Validate
    if (_nameCtrl.text.trim().isEmpty) {
      SnackBarUtils.showTopSnackBar(context, 'Họ và tên không được để trống', isSuccess: false);
      return;
    }

    final phone = _phoneCtrl.text.trim();
    if (phone.isNotEmpty) {
      final phoneRegex = RegExp(r'^(0[3|5|7|8|9])+([0-9]{8})$');
      if (!phoneRegex.hasMatch(phone)) {
        SnackBarUtils.showTopSnackBar(context, 'Số điện thoại không hợp lệ', isSuccess: false);
        return;
      }
    }

    final authProvider = context.read<AuthProvider>();
    final profileProvider = context.read<ProfileProvider>();

    // 1. Upload avatar nếu chọn ảnh mới
    if (_pendingAvatar != null) {
      await profileProvider.uploadAvatar(
        imageFile: _pendingAvatar!,
        onSuccess: (url) {
          setState(() {
            _currentAvatarUrl = url;
            _pendingAvatar = null;
          });
          // Sync vào AuthProvider
          authProvider.updateUserField('avatarUrl', url);
        },
        onError: (msg) {
          SnackBarUtils.showTopSnackBar(context, msg, isSuccess: false);
        },
      );
    }

    // 2. Update profile info
    await profileProvider.updateProfile(
      fullName: _nameCtrl.text.trim(),
      phoneNumber: phone.isNotEmpty ? phone : null,
      onSuccess: (data) {
        // Sync vào AuthProvider
        authProvider.updateUserField('fullName', data['fullName']);
        authProvider.updateUserField('phoneNumber', data['phoneNumber']);
        setState(() => _isEditing = false);
        SnackBarUtils.showTopSnackBar(context, 'Cập nhật thành công!', isSuccess: true);
      },
      onError: (msg) {
        SnackBarUtils.showTopSnackBar(context, msg, isSuccess: false);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<ProfileProvider>().isLoading;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF1F2937) : const Color(0xFFF5F6FA),
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(isLoading, isDark),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          const SizedBox(height: 16),
                          _buildAvatarCard(isDark),
                          const SizedBox(height: 16),
                          _buildInfoCard(isDark),
                          if (_isEditing) ...[
                            const SizedBox(height: 28),
                            _buildSaveButton(isLoading),
                          ],
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(bool isLoading, bool isDark) {
    return Container(
      color: isDark ? const Color(0xFF111827) : Colors.white,
      padding: const EdgeInsets.fromLTRB(8, 12, 16, 12),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : const Color(0xFF111827)),
          ),
          Expanded(
            child: Text(
              'Thông tin tài khoản',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF111827)),
            ),
          ),
          GestureDetector(
            onTap: isLoading ? null : () => setState(() => _isEditing = !_isEditing),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _isEditing ? const Color(0xFF2563EB) : (isDark ? const Color(0xFF374151) : const Color(0xFFE0E7FF)),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                _isEditing ? Icons.close : Icons.edit,
                color: _isEditing ? Colors.white : const Color(0xFF2563EB),
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarCard(bool isDark) {
    Widget avatarWidget;

    if (_pendingAvatar != null) {
      avatarWidget = kIsWeb
          ? Image.network(
              _pendingAvatar!.path,
              fit: BoxFit.cover,
              width: 84,
              height: 84,
              errorBuilder: (context, error, stackTrace) => const Icon(Icons.error, color: Colors.red),
            )
          : Image.file(
              File(_pendingAvatar!.path),
              fit: BoxFit.cover,
              width: 84,
              height: 84,
              errorBuilder: (context, error, stackTrace) => const Icon(Icons.error, color: Colors.red),
            );
    } else if (_currentAvatarUrl != null && _currentAvatarUrl!.isNotEmpty) {
      avatarWidget = Image.network(
        _currentAvatarUrl!,
        fit: BoxFit.cover,
        width: 84,
        height: 84,
        errorBuilder: (context, error, stackTrace) => const Icon(Icons.person, color: Colors.grey),
      );
    } else {
      avatarWidget = Image.asset(
        'assets/images/logo.png',
        fit: BoxFit.cover,
        width: 84,
        height: 84,
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF111827) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: isDark ? [] : const [BoxShadow(color: Color(0x0A000000), blurRadius: 12, offset: Offset(0, 4))],
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: _isEditing ? _pickImage : null,
            child: Stack(
              children: [
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFF2563EB), width: 3),
                  ),
                  child: ClipOval(child: avatarWidget),
                ),
                if (_isEditing)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: const BoxDecoration(color: Color(0xFF2563EB), shape: BoxShape.circle),
                      child: const Icon(Icons.camera_alt, color: Colors.white, size: 16),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _nameCtrl.text,
            style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF111827)),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            _emailCtrl.text, 
            style: GoogleFonts.poppins(fontSize: 13, color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280)),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF111827) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: isDark ? [] : [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          _buildField(label: 'Họ và tên', controller: _nameCtrl, icon: Icons.person_outline, isDark: isDark),
          Divider(color: isDark ? const Color(0xFF374151) : const Color(0xFFF3F4F6), height: 1, indent: 60),
          _buildField(
              label: 'Email', controller: _emailCtrl, icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress, readOnly: true, isDark: isDark),
          Divider(color: isDark ? const Color(0xFF374151) : const Color(0xFFF3F4F6), height: 1, indent: 60),
          _buildField(
              label: 'Số điện thoại', controller: _phoneCtrl, icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone, isDark: isDark),
        ],
      ),
    );
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    TextInputType? keyboardType,
    bool readOnly = false,
    required bool isDark,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
                color: readOnly ? (isDark ? const Color(0xFF374151) : const Color(0xFFF3F4F6)) : (isDark ? const Color(0xFF1F2937) : const Color(0xFFE0E7FF)),
                borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: readOnly ? (isDark ? const Color(0xFF9CA3AF) : const Color(0xFF9CA3AF)) : const Color(0xFF2563EB), size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: (_isEditing && !readOnly)
                ? TextField(
                    controller: controller,
                    keyboardType: keyboardType,
                    style: GoogleFonts.poppins(fontSize: 14, color: isDark ? Colors.white : const Color(0xFF111827)),
                    decoration: InputDecoration(
                      labelText: label,
                      labelStyle: GoogleFonts.poppins(fontSize: 12, color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280)),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                    onChanged: (_) => setState(() {}),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(label, style: GoogleFonts.poppins(fontSize: 11, color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF9CA3AF))),
                      const SizedBox(height: 2),
                      Text(
                        controller.text.isEmpty ? 'Chưa cập nhật' : controller.text,
                        style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: controller.text.isEmpty
                                ? (isDark ? const Color(0xFF4B5563) : const Color(0xFFD1D5DB))
                                : (isDark ? Colors.white : const Color(0xFF111827))),
                      ),
                    ],
                  ),
          ),
          if (readOnly)
             Icon(Icons.lock_outline, size: 14, color: isDark ? const Color(0xFF4B5563) : const Color(0xFFD1D5DB)),
        ],
      ),
    );
  }

  Widget _buildSaveButton(bool isLoading) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: isLoading ? null : _save,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2563EB),
          disabledBackgroundColor: const Color(0xFF93C5FD),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
        ),
        child: isLoading
            ? const SizedBox(
                width: 24, height: 24,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : Text('Lưu thay đổi',
                style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
      ),
    );
  }
}
