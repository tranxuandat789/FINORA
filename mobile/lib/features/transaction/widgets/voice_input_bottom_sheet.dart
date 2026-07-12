import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/voice_recording_service.dart';
import '../providers/transaction_provider.dart';
import 'package:mobile/core/utils/snackbar_utils.dart';
import '../../../core/providers/theme_provider.dart';
import 'ai_model_selection_sheet.dart';

class VoiceInputBottomSheet extends StatefulWidget {
  static String globalSelectedModel = 'Voice thường';
  
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
        onError: (val) => debugPrint('onError: \$val'),
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
    if (VoiceInputBottomSheet.globalSelectedModel == 'Voice thường') {
      // Local regex extraction for amount
      int? parsedAmount;
      String lowerText = text.toLowerCase().trim();
      lowerText = lowerText.replaceAll(RegExp(r'(?<=\d)[.,](?=\d{3}(?!\d))'), '');
      
      final amountRegex = RegExp(r'(\d+(?:[.,]\d+)?)\s*(k|nghìn|ngàn|ngan|trăm|triệu|củ|m|tỏi|lít|loét|lốp|sọi|đ|vnd|chục|cành)?', caseSensitive: false);
      final matches = amountRegex.allMatches(lowerText);
      
      RegExpMatch? bestMatch;
      for (final match in matches) {
        if (match.group(2) != null && match.group(2)!.isNotEmpty) {
          bestMatch = match;
          break;
        }
      }
      if (bestMatch == null && matches.isNotEmpty) {
        bestMatch = matches.last;
      }

      if (bestMatch != null) {
        double? val = double.tryParse(bestMatch.group(1)!.replaceAll(',', '.'));
        if (val != null) {
          String unit = (bestMatch.group(2) ?? '').toLowerCase();
          if (['k', 'nghìn', 'ngàn', 'ngan', 'cành'].contains(unit)) parsedAmount = (val * 1000).toInt();
          else if (['trăm', 'lít', 'loét', 'lốp', 'sọi'].contains(unit)) parsedAmount = (val * 100000).toInt();
          else if (['triệu', 'củ', 'm'].contains(unit)) parsedAmount = (val * 1000000).toInt();
          else if (['tỏi'].contains(unit)) parsedAmount = (val * 1000000000).toInt();
          else if (['chục'].contains(unit)) parsedAmount = (val * 10000).toInt();
          else parsedAmount = val.toInt();

          if (unit.isEmpty && parsedAmount > 0 && parsedAmount < 1000) {
            parsedAmount = parsedAmount * 1000;
          }
        }
      }

      Navigator.pop(context, {
        'amount': parsedAmount,
        'note': text,
      });
      return;
    }

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

  void _showModelSelection(bool isDark) async {
    final result = await showAiModelSelection(context, isDark, VoiceInputBottomSheet.globalSelectedModel);
    if (result != null && mounted) {
      setState(() {
        VoiceInputBottomSheet.globalSelectedModel = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDarkMode;

    return Container(
      height: MediaQuery.of(context).size.height * 0.5,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1F2937) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          Container(
            width: 40, height: 4,
            decoration: BoxDecoration(color: isDark ? const Color(0xFF4B5563) : const Color(0xFFE5E7EB), borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(height: 24),
          Text(_isListening ? 'Đang nghe...' : 'Thêm bằng giọng nói', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF111827))),
          const SizedBox(height: 8),
          Text(
            _isListening ? 'Hãy nói rõ thông tin giao dịch' : 'Ví dụ: "Hôm nay ăn trưa hết 50 ngàn"',
            style: GoogleFonts.inter(fontSize: 14, color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280)),
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
              style: GoogleFonts.inter(fontSize: 18, color: _isListening ? (isDark ? Colors.white : const Color(0xFF111827)) : const Color(0xFF9CA3AF), fontWeight: _isListening ? FontWeight.w500 : FontWeight.normal),
            ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
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
            ],
          ),
          const SizedBox(height: 24),
          // Model selection button
          InkWell(
            onTap: () => _showModelSelection(isDark),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF374151) : const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Model đang dùng: ', style: GoogleFonts.inter(fontSize: 12, color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280))),
                  Text(VoiceInputBottomSheet.globalSelectedModel, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: isDark ? Colors.white : const Color(0xFF111827))),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
