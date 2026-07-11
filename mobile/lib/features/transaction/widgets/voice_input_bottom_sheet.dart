import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/voice_recording_service.dart';
import '../providers/transaction_provider.dart';
import 'package:mobile/core/utils/snackbar_utils.dart';

class VoiceInputBottomSheet extends StatefulWidget {
  const VoiceInputBottomSheet({super.key});

  @override
  State<VoiceInputBottomSheet> createState() => _VoiceInputBottomSheetState();
}

class _VoiceInputBottomSheetState extends State<VoiceInputBottomSheet> {
  final VoiceRecordingService _voiceService = VoiceRecordingService();
  bool _isListening = false;
  String _text = 'Nhấn vào Micro để nói...';
  bool _isAnalyzing = false;

  @override
  void initState() {
    super.initState();
  }

  void _startListening() async {
    if (!_isListening) {
      if (mounted) setState(() => _isListening = true);
      await _voiceService.startListening(
        onResult: (val) {
          if (mounted) {
            setState(() {
              _text = val;
            });
          }
        },
        onStatus: (val) {
          if (val == 'done' || val == 'notListening') {
            if (mounted) setState(() => _isListening = false);
          }
        },
        onError: (val) => debugPrint('onError: $val'),
        onInitFailed: () {
          if (mounted) {
            setState(() {
              _isListening = false;
              _text = 'Lỗi: Không thể khởi tạo Micro.';
            });
            SnackBarUtils.showTopSnackBar(context, 'Không thể khởi tạo ghi âm. Vui lòng kiểm tra quyền Micro hoặc Google App.', isSuccess: false);
          }
        },
      );
    }
  }

  void _stopListening() async {
    if (_isListening) {
      if (mounted) setState(() => _isListening = false);
      await _voiceService.stopListening();
      if (_text.isNotEmpty && _text != 'Nhấn vào Micro để nói...' && _text != 'Giữ Micro để nói...' && _text != 'Đang lắng nghe...') {
        _analyzeVoiceInput(_text);
      }
    } else {
      if (mounted && _text == 'Đang lắng nghe...') {
         setState(() => _text = 'Nhấn vào Micro để nói...');
      }
    }
  }

  void _analyzeVoiceInput(String text) async {
    setState(() {
      _isAnalyzing = true;
    });

    final result = await context.read<TransactionProvider>().analyzeVoice(text);

    setState(() {
      _isAnalyzing = false;
    });

    if (result != null && mounted) {
      Navigator.pop(context, {
        'amount': result.amount,
        'categoryId': result.categoryId,
        'categoryName': result.categoryName,
        'note': result.note,
        'transactionDate': result.transactionDate,
      });
    } else if (mounted) {
      SnackBarUtils.showTopSnackBar(context, 'Không thể phân tích giọng nói. Vui lòng thử lại.', isSuccess: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.45,
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          Container(
            width: 40, height: 4,
            decoration: BoxDecoration(color: const Color(0xFFE5E7EB), borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(height: 24),
          Text('Thêm bằng giọng nói', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF111827))),
          const SizedBox(height: 8),
          Text(
            'Ví dụ: "Hôm nay ăn trưa hết 50 ngàn"',
            style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF6B7280)),
          ),
          const Spacer(),
          if (_isAnalyzing)
            Column(
              children: [
                const CircularProgressIndicator(color: Color(0xFF2563EB)),
                const SizedBox(height: 16),
                Text('AI đang phân tích...', style: GoogleFonts.inter(color: const Color(0xFF2563EB), fontWeight: FontWeight.w500)),
              ],
            )
          else
            Text(
              _text,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(fontSize: 18, color: _isListening ? const Color(0xFF111827) : const Color(0xFF9CA3AF), fontWeight: _isListening ? FontWeight.w500 : FontWeight.normal),
            ),
          const Spacer(),
          GestureDetector(
            onLongPressDown: _isAnalyzing ? null : (_) {
              setState(() => _text = "Đang lắng nghe...");
              _startListening();
            },
            onLongPressUp: _isAnalyzing ? null : () {
              _stopListening();
            },
            onLongPressCancel: _isAnalyzing ? null : () {
              _stopListening();
            },
            child: Container(
              width: 80, height: 80,
              decoration: BoxDecoration(
                color: _isListening ? const Color(0xFFEF4444) : const Color(0xFF2563EB),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: (_isListening ? const Color(0xFFEF4444) : const Color(0xFF2563EB)).withOpacity(0.3), blurRadius: 20, spreadRadius: 5),
                ],
              ),
              child: Icon(_isListening ? Icons.mic_none : Icons.mic, color: Colors.white, size: 40),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _isListening ? 'Thả ra để gửi' : 'Giữ để nói',
            style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF6B7280)),
          ),
        ],
      ),
    );
  }
}
