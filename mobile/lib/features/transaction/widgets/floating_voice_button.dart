import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter/scheduler.dart';
import 'package:lottie/lottie.dart';
import 'package:mobile/core/utils/snackbar_utils.dart';
import '../services/voice_recording_service.dart';
import '../providers/transaction_provider.dart';
import '../screens/add_transaction_screen.dart';
import 'package:mobile/features/dashboard/providers/dashboard_provider.dart';
import 'voice_input_bottom_sheet.dart';
class FloatingVoiceButton extends StatefulWidget {
  const FloatingVoiceButton({super.key});

  @override
  State<FloatingVoiceButton> createState() => _FloatingVoiceButtonState();
}

class _FloatingVoiceButtonState extends State<FloatingVoiceButton> with TickerProviderStateMixin {
  late AnimationController _bobbingController;
  late Animation<double> _bobbingAnimation;
  late AnimationController _flightController;

  double _x = 0, _y = 0;
  bool _isInitialized = false;
  bool _isDragging = false, _isIdleFlying = false;
  bool _isRecording = false, _isAnalyzing = false;
  bool _facingRight = false; // Mặc định hướng trái

  late AnimationController _lottieController;
  late Ticker _lottieTicker;
  Duration _lastElapsed = Duration.zero;
  double _targetSpeed = 1.0;
  double _currentSpeed = 1.0;

  double _lastLayoutWidth = 360.0;
  double _lastLayoutHeight = 640.0;
  double _scale = 1.0;
  double _opacity = 1.0;

  Timer? _inactivityTimer;
  Timer? _idleRestTimer;
  double _startX = 0, _startY = 0, _targetX = 0, _targetY = 0;

  bool _showTooltip = false;
  String _tooltipText = 'Đang lắng nghe...';
  String _lastWords = '';

  final VoiceRecordingService _voiceService = VoiceRecordingService();

  void _updateSpeed() {
    if (_isRecording) {
      _targetSpeed = 2.5;
    } else if (_isDragging || _isIdleFlying) {
      _targetSpeed = 1.5;
    } else {
      _targetSpeed = 1.0;
    }
  }

  @override
  void initState() {
    super.initState();
    _bobbingController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
    _bobbingAnimation = Tween<double>(begin: -3.0, end: 3.0).animate(CurvedAnimation(parent: _bobbingController, curve: Curves.easeInOutQuad));
    _bobbingController.repeat(reverse: true);

    _flightController = AnimationController(vsync: this, duration: const Duration(milliseconds: 4500));
    _flightController.addListener(() {
      final safeAreaTop = MediaQuery.of(context).padding.top;
      final safeAreaBottom = MediaQuery.of(context).padding.bottom;
      final minY = safeAreaTop + 10.0;
      final maxY = _lastLayoutHeight - safeAreaBottom - 65.0 - 70.0;
      final curvedT = Curves.easeInOut.transform(_flightController.value);
      final sway = math.sin(curvedT * math.pi * 4.0) * 45.0;
      setState(() {
        _y = (_startY + (_targetY - _startY) * curvedT + sway).clamp(minY, maxY);
        _x = _startX + (_targetX - _startX) * curvedT;
      });
    });
    
    _flightController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _isIdleFlying = false;
        });
        _updateSpeed();
        _idleRestTimer?.cancel();
        _idleRestTimer = Timer(const Duration(milliseconds: 1500), () {
          if (!_isDragging && !_isRecording && mounted) {
            _triggerIdleFlight();
          }
        });
      }
    });

    _lottieController = AnimationController(vsync: this, duration: const Duration(seconds: 1));
    _lottieTicker = createTicker((elapsed) {
      final delta = (elapsed - _lastElapsed).inMilliseconds / 1000.0;
      _lastElapsed = elapsed;
      _currentSpeed += (_targetSpeed - _currentSpeed) * (delta * 5.0);
      double newValue = _lottieController.value + (delta * _currentSpeed);
      if (newValue > 1.0) {
        newValue -= 1.0;
      }
      _lottieController.value = newValue;
    });
    _lottieTicker.start();
  }

  void _resetInactivity() {
    _inactivityTimer?.cancel();
    _idleRestTimer?.cancel();
    _flightController.stop();
    setState(() {
      _isIdleFlying = false;
      _opacity = 1.0;
    });
    _updateSpeed();
    _inactivityTimer = Timer(const Duration(seconds: 5), () {
      if (mounted && !_isDragging && !_isRecording) {
        setState(() {
          _opacity = 0.7;
        });
        _triggerIdleFlight();
      }
    });
  }

  void _triggerIdleFlight() {
    if (!mounted) return;
    final safeAreaTop = MediaQuery.of(context).padding.top;
    final safeAreaBottom = MediaQuery.of(context).padding.bottom;
    final minX = 8.0;
    final maxX = _lastLayoutWidth - 65.0 - 8.0;
    final minY = safeAreaTop + 10.0;
    final maxY = _lastLayoutHeight - safeAreaBottom - 65.0 - 70.0;

    _startX = _x;
    _startY = _y;
    _targetX = (_x < _lastLayoutWidth / 2) ? maxX : minX;
    _targetY = minY + math.Random().nextDouble() * (maxY - minY);
    setState(() {
      _facingRight = _targetX > _startX;
      _isIdleFlying = true;
    });
    _updateSpeed();
    _flightController.forward(from: 0.0);
  }

  Future<void> _handleLongPressEnd() async {
    await _voiceService.stopListening();
    if (mounted) {
      setState(() {
        _scale = 1.0;
        _isRecording = false;
      });
      _updateSpeed();
      _bobbingController.duration = const Duration(milliseconds: 1200);
      _bobbingController.repeat(reverse: true);

      if (_lastWords.isEmpty) {
        setState(() {
          _showTooltip = false;
        });
      } else {
        setState(() {
          _tooltipText = 'Đang xử lý dữ liệu...';
          _isAnalyzing = true;
        });
        final result = await context.read<TransactionProvider>().analyzeVoice(
          _lastWords,
          VoiceInputBottomSheet.globalSelectedModel,
        );

        if (mounted) {
          setState(() {
            _isAnalyzing = false;
            _showTooltip = false;
          });
          if (result != null) {
            await Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => AddTransactionScreen(
                          voiceData: {
                            'amount': result.amount,
                            'categoryId': result.categoryId,
                            'categoryName': result.categoryName,
                            'note': result.note,
                            'transactionDate': result.transactionDate,
                          },
                        )));
            if (mounted) {
              context.read<DashboardProvider>().loadDashboardData();
            }
          } else {
            SnackBarUtils.showTopSnackBar(context, 'Không thể phân tích giọng nói. Vui lòng thử lại.', isSuccess: false);
          }
        }
      }
      _lastWords = '';
    }
  }

  @override
  void dispose() {
    _bobbingController.dispose();
    _flightController.dispose();
    _lottieController.dispose();
    _lottieTicker.dispose();
    _inactivityTimer?.cancel();
    _idleRestTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (!_isInitialized) {
          _lastLayoutWidth = constraints.maxWidth;
          _lastLayoutHeight = constraints.maxHeight;
          final safeAreaBottom = MediaQuery.of(context).padding.bottom;
          _x = _lastLayoutWidth - 65.0 - 8.0;
          _y = _lastLayoutHeight - safeAreaBottom - 65.0 - 100.0;
          _isInitialized = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _resetInactivity();
          });
        }

        final safeAreaTop = MediaQuery.of(context).padding.top;
        final safeAreaBottom = MediaQuery.of(context).padding.bottom;
        final minX = 8.0;
        final maxX = _lastLayoutWidth - 65.0 - 8.0;
        final minY = safeAreaTop + 10.0;
        final maxY = _lastLayoutHeight - safeAreaBottom - 65.0 - 70.0;

        return SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned.fill(
                child: Listener(
                  behavior: HitTestBehavior.translucent,
                  onPointerDown: (_) => _resetInactivity(),
                  child: const SizedBox.expand(),
                ),
              ),
              if (_showTooltip)
                Positioned(
                  top: _y + 20.0,
                  left: _x + 32.5 > (_lastLayoutWidth / 2) ? null : _x + 65.0 + 35.0,
                  right: _x + 32.5 > (_lastLayoutWidth / 2) ? (_lastLayoutWidth - _x) + 35.0 : null,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_isAnalyzing)
                          const Padding(
                            padding: EdgeInsets.only(right: 8.0),
                            child: SizedBox(
                              width: 12,
                              height: 12,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            ),
                          ),
                        Text(
                          _tooltipText,
                          style: GoogleFonts.inter(color: Colors.white, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),
              AnimatedPositioned(
                left: _x,
                top: _y,
                duration: (_isDragging || _isIdleFlying) ? Duration.zero : const Duration(milliseconds: 700),
                curve: Curves.bounceOut,
                child: AnimatedBuilder(
                  animation: _bobbingAnimation,
                  builder: (context, child) {
                    final double pulseScale = _isRecording ? 1.15 + (_bobbingAnimation.value / 30.0) : 1.0;
                    return Transform.translate(
                      offset: Offset(0, _bobbingAnimation.value),
                      child: Transform.scale(
                        scale: pulseScale * _scale,
                        child: AnimatedOpacity(
                          opacity: _opacity,
                          duration: const Duration(milliseconds: 500),
                          child: SizedBox(
                            width: 80,
                            height: 80,
                            child: GestureDetector(
                              onTap: () {
                                SnackBarUtils.showTopSnackBar(context, 'Nhấn giữ chú ong để ghi âm nhé!');
                                _resetInactivity();
                              },
                              onPanStart: (_) {
                                setState(() {
                                  _isDragging = true;
                                });
                                _updateSpeed();
                                _resetInactivity();
                              },
                              onPanUpdate: (details) {
                                setState(() {
                                  _x = (_x + details.delta.dx).clamp(minX, maxX);
                                  _y = (_y + details.delta.dy).clamp(minY, maxY);
                                  if (details.delta.dx != 0) {
                                    _facingRight = details.delta.dx > 0;
                                  }
                                });
                              },
                              onPanEnd: (_) {
                                setState(() {
                                  _isDragging = false;
                                  if (_x + 32.5 < _lastLayoutWidth / 2) {
                                    _x = minX;
                                    _facingRight = false;
                                  } else {
                                    _x = maxX;
                                    _facingRight = true;
                                  }
                                });
                                _updateSpeed();
                                _resetInactivity();
                              },
                              onLongPressStart: (_) async {
                                _resetInactivity();
                                setState(() {
                                  _isRecording = true;
                                  _scale = 1.2;
                                  _showTooltip = true;
                                  _tooltipText = 'Đang lắng nghe...';
                                });
                                _updateSpeed();
                                _bobbingController.duration = const Duration(milliseconds: 250);
                                _bobbingController.repeat(reverse: true);

                                await _voiceService.startListening(
                                  onResult: (val) {
                                    _lastWords = val;
                                    if (mounted && _isRecording) {
                                      setState(() {
                                        _tooltipText = val.isEmpty ? 'Đang lắng nghe...' : val;
                                      });
                                    }
                                  },
                                  onStatus: (val) {},
                                  onError: (val) {},
                                  onInitFailed: () {
                                    if (mounted) {
                                      SnackBarUtils.showTopSnackBar(context, 'Không thể khởi tạo ghi âm. Vui lòng kiểm tra quyền Micro hoặc Google App.', isSuccess: false);
                                      setState(() {
                                        _isRecording = false;
                                        _scale = 1.0;
                                        _showTooltip = false;
                                      });
                                      _updateSpeed();
                                      _bobbingController.duration = const Duration(milliseconds: 1200);
                                      _bobbingController.repeat(reverse: true);
                                    }
                                  },
                                );
                              },
                              onLongPressEnd: (_) {
                                _handleLongPressEnd();
                              },
                              onLongPressCancel: () {
                                _handleLongPressEnd();
                              },
                              child: Container(
                                color: Colors.transparent,
                                child: TweenAnimationBuilder<double>(
                                  tween: Tween<double>(end: _facingRight ? -1.0 : 1.0),
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                  builder: (context, scaleX, child) {
                                    return Transform(
                                      alignment: Alignment.center,
                                      transform: Matrix4.identity()..scale(scaleX, 1.0, 1.0),
                                      child: child,
                                    );
                                  },
                                  child: Lottie.asset(
                                    'assets/images/bee.json',
                                    controller: _lottieController,
                                    width: 70,
                                    height: 70,
                                    fit: BoxFit.contain,
                                    errorBuilder: (context, error, stackTrace) => Image.asset('assets/images/bee.png', fit: BoxFit.contain),
                                  ),
                                ),
                              ),
                            ),
                          ),
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
}
