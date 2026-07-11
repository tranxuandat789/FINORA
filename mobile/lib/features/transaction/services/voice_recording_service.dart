import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';

class VoiceRecordingService {
  static final VoiceRecordingService _instance = VoiceRecordingService._internal();

  factory VoiceRecordingService() {
    return _instance;
  }

  VoiceRecordingService._internal();

  final SpeechToText _speechToText = SpeechToText();

  Future<void> startListening({
    required Function(String) onResult,
    required Function(String) onStatus,
    required Function(dynamic) onError,
    required VoidCallback onInitFailed,
  }) async {
    bool available = await _speechToText.initialize(
      onStatus: onStatus,
      onError: onError,
    );

    if (!available) {
      onInitFailed();
      return;
    }

    await _speechToText.listen(
      onResult: (val) => onResult(val.recognizedWords),
    );
  }

  Future<void> stopListening() async {
    await _speechToText.stop();
  }
}
