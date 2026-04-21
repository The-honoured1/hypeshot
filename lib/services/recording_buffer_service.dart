import 'dart:async';
import 'package:flutter_screen_recording/flutter_screen_recording.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class RecordingBufferService {
  static bool _isBuffering = false;
  static bool get isBuffering => _isBuffering;

  static Timer? _chunkTimer;
  static String? _currentChunkFileName;
  static String? _currentChunkPath;
  static String? _previousChunkPath;
  
  static final StreamController<bool> _bufferingStreamController = StreamController<bool>.broadcast();
  static Stream<bool> get bufferingStream => _bufferingStreamController.stream;

  static const int chunkDurationSeconds = 30;

  static Future<bool> startBuffer() async {
    if (_isBuffering) return true;

    final micStatus = await Permission.microphone.request();
    final extStatus = await Permission.storage.request();

    if (micStatus.isGranted || micStatus.isLimited) {
      _isBuffering = true;
      _bufferingStreamController.add(true);
      await _startNewChunk();
      
      // Start the cyclic timer
      _chunkTimer = Timer.periodic(const Duration(seconds: chunkDurationSeconds), (timer) async {
        await _cycleChunk();
      });
      return true;
    }
    return false;
  }

  static Future<void> _startNewChunk() async {
    _currentChunkFileName = "HypeShot_Buffer_${DateTime.now().millisecondsSinceEpoch}";
    try {
      final success = await FlutterScreenRecording.startRecordScreenAndAudio(
        _currentChunkFileName!,
        titleNotification: "HypeShot Buffer",
        messageNotification: "Auto-capturing gameplay...",
      );
      if (!success) {
        stopBuffer();
      }
    } catch (e) {
      stopBuffer();
    }
  }

  static Future<void> _cycleChunk() async {
    if (!_isBuffering) return;
    
    // Stop current
    try {
      final path = await FlutterScreenRecording.stopRecordScreen;
      _previousChunkPath = _currentChunkPath;
      _currentChunkPath = path;
      
      // Keep only last two chunks
      if (_previousChunkPath != null) {
        // Here we could delete older chunks if we kept a list to manage storage
      }
      
      // Restart recording
      await _startNewChunk();
    } catch (e) {
      stopBuffer();
    }
  }

  static Future<Map<String, String?>> captureMoment() async {
    // When the user hits capture, stop whatever is recording, and return the previous and current chunks.
    if (!_isBuffering) return {'current': null, 'previous': null};
    
    _chunkTimer?.cancel();
    try {
      final path = await FlutterScreenRecording.stopRecordScreen;
      final current = path;
      final previous = _currentChunkPath;
      
      // We don't automatically restart here - the user usually goes to the editor.
      _isBuffering = false;
      _bufferingStreamController.add(false);
      return {'current': current, 'previous': previous};
    } catch (e) {
      _isBuffering = false;
      _bufferingStreamController.add(false);
      return {'current': null, 'previous': null};
    }
  }

  static void stopBuffer() async {
    if (!_isBuffering) return;
    _chunkTimer?.cancel();
    try {
      await FlutterScreenRecording.stopRecordScreen;
    } catch (_) {}
    _isBuffering = false;
    _bufferingStreamController.add(false);
  }
}
