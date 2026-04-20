import 'dart:io';
import 'package:flutter_screen_recording/flutter_screen_recording.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';

class RecordingService {
  static bool _isRecording = false;
  static String? _currentRecordingPath;

  static bool get isRecording => _isRecording;

  static Future<bool> startRecording() async {
    if (_isRecording) return true;

    // Check permissions
    final micStatus = await Permission.microphone.request();
    final storageStatus = await Permission.storage.request();
    final mediaStatus = await Permission.videos.request();

    if (micStatus.isGranted) {
      final Directory? extDir = await getExternalStorageDirectory();
      final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final String fileName = "HypeShot_$timestamp";

      try {
        final path = await FlutterScreenRecording.startRecordScreenAndAudio(fileName);
        if (path.isNotEmpty) {
          _isRecording = true;
          _currentRecordingPath = path;
          return true;
        }
      } catch (e) {
        // Handle error
        return false;
      }
    }
    return false;
  }

  static Future<String?> stopRecording() async {
    if (!_isRecording) return null;

    try {
      final path = await FlutterScreenRecording.stopRecordScreen;
      _isRecording = false;
      return path;
    } catch (e) {
      _isRecording = false;
      return null;
    }
  }
}
