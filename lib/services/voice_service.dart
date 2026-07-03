import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_tts/flutter_tts.dart';

/// Wraps native speech recognition (OS dictation) and text-to-speech.
/// No browser, no Google cloud dependency — uses the OS engines.
///
/// Note: speech_to_text supports macOS but NOT Windows desktop. All calls are
/// guarded so on Windows the mic silently does nothing and typed commands
/// work identically. flutter_tts (speaking) works on both platforms.
class VoiceService {
  final SpeechToText _stt = SpeechToText();
  final FlutterTts _tts = FlutterTts();

  bool _sttReady = false;
  bool get isListening {
    try {
      return _stt.isListening;
    } catch (_) {
      return false;
    }
  }

  Future<void> init() async {
    // Speech recognition — may be unavailable (Windows) or denied (no mic).
    try {
      _sttReady = await _stt.initialize(
        onError: (e) {},
        onStatus: (s) {},
      );
    } catch (_) {
      _sttReady = false;
    }

    // Text-to-speech — prefer a British male voice, fall back gracefully.
    try {
      await _tts.setLanguage('en-GB');
      await _tts.setSpeechRate(0.5);
      await _tts.setPitch(1.0);
      final voices = (await _tts.getVoices) as List?;
      if (voices != null) {
        for (final v in voices) {
          final m = Map<String, dynamic>.from(v as Map);
          final name = (m['name'] ?? '').toString().toLowerCase();
          final locale = (m['locale'] ?? '').toString().toLowerCase();
          final isBritishMale = locale.contains('gb') &&
              (name.contains('male') ||
                  name.contains('daniel') ||
                  name.contains('arthur'));
          if (isBritishMale) {
            await _tts.setVoice({
              'name': m['name'].toString(),
              'locale': m['locale'].toString(),
            });
            break;
          }
        }
      }
    } catch (_) {
      // Voice selection is best-effort; the default voice is fine.
    }
  }

  /// Start listening. [onResult] is called with the recognised text as it updates.
  Future<void> startListening(
      void Function(String text, bool isFinal) onResult) async {
    try {
      if (!_sttReady) {
        _sttReady = await _stt.initialize();
        if (!_sttReady) return;
      }
      await _stt.listen(
        onResult: (r) => onResult(r.recognizedWords, r.finalResult),
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 4),
        localeId: 'en_GB',
        cancelOnError: true,
      );
    } catch (_) {
      // Mic unavailable — typed input still works.
    }
  }

  Future<void> stopListening() async {
    try {
      await _stt.stop();
    } catch (_) {}
  }

  Future<void> speak(String text) async {
    try {
      await _tts.stop();
      await _tts.speak(text);
    } catch (_) {
      // TTS unavailable — the transcript still shows the reply.
    }
  }

  Future<void> shutUp() async {
    try {
      await _tts.stop();
    } catch (_) {}
  }
}
