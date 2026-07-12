import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AiModelSelectionSheet extends StatefulWidget {
  final bool isDark;
  final String initialModel;
  final bool isDefaultSetting;

  const AiModelSelectionSheet({
    super.key,
    required this.isDark,
    required this.initialModel,
    this.isDefaultSetting = false,
  });

  @override
  State<AiModelSelectionSheet> createState() => _AiModelSelectionSheetState();
}

class _AiModelSelectionSheetState extends State<AiModelSelectionSheet> {
  late String _selectedModel;

  @override
  void initState() {
    super.initState();
    _selectedModel = widget.initialModel;
  }

  Widget _buildModelOption(String name, String description, IconData icon, bool isDark) {
    final isSelected = _selectedModel == name;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedModel = name;
        });
        if (!widget.isDefaultSetting) {
          Navigator.pop(context, name);
        }
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF111827) : const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF2563EB) : (isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB)),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF2563EB).withOpacity(0.1) : (isDark ? const Color(0xFF374151) : Colors.white),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: isSelected ? const Color(0xFF2563EB) : (isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280)), size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF111827))),
                  const SizedBox(height: 4),
                  Text(description, style: GoogleFonts.inter(fontSize: 12, color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280))),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check, color: Color(0xFF2563EB)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: widget.isDark ? const Color(0xFF1F2937) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(color: widget.isDark ? const Color(0xFF4B5563) : const Color(0xFFE5E7EB), borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: Text(widget.isDefaultSetting ? 'Chọn model mặc định' : 'Chọn mô hình AI', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: widget.isDark ? Colors.white : const Color(0xFF111827))),
          ),
          const SizedBox(height: 24),
          _buildModelOption('Gemini Flash', 'Nhanh, chính xác, tối ưu cho tiếng Việt', Icons.auto_awesome, widget.isDark),
          _buildModelOption('Voice thường', 'Mặc định\nChuyển giọng nói thành văn bản', Icons.mic_none, widget.isDark),
          const SizedBox(height: 24),
          if (widget.isDefaultSetting) ...[
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context, _selectedModel),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: Text('Xác nhận', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
              ),
            ),
            const SizedBox(height: 12),
          ],
          SizedBox(
            width: double.infinity,
            height: 50,
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                backgroundColor: widget.isDark ? const Color(0xFF374151) : const Color(0xFFF3F4F6),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text('Hủy', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: widget.isDark ? Colors.white : const Color(0xFF111827))),
            ),
          )
        ],
      ),
    );
  }
}

Future<String?> showAiModelSelection(BuildContext context, bool isDark, String currentModel, {bool isDefaultSetting = false}) {
  return showModalBottomSheet<String>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (context) => AiModelSelectionSheet(isDark: isDark, initialModel: currentModel, isDefaultSetting: isDefaultSetting),
  );
}
