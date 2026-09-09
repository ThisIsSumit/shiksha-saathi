import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class VoiceService {
  static final VoiceService instance = VoiceService._();
  VoiceService._();

  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isInitialized = false;

  Future<bool> init() async {
    if (_isInitialized) return true;
    try {
      _isInitialized = await _speech.initialize(
        onError: (val) => debugPrint('VoiceService onError: $val'),
        onStatus: (val) => debugPrint('VoiceService onStatus: $val'),
      );
      return _isInitialized;
    } catch (e) {
      debugPrint('VoiceService init error: $e');
      return false;
    }
  }

  bool get isListening => _speech.isListening;

  Future<void> startListening({
    required Function(String text) onResult,
    String localeId = 'hi_IN',
  }) async {
    final hasInit = await init();
    if (!hasInit) return;

    try {
      await _speech.listen(
        onResult: (result) {
          onResult(result.recognizedWords);
        },
        localeId: localeId,
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 4),
        cancelOnError: true,
      );
    } catch (e) {
      debugPrint('Error starting speech listen: $e');
    }
  }

  Future<void> stopListening() async {
    if (_speech.isListening) {
      await _speech.stop();
    }
  }
}
