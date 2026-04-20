import 'package:flutter_screen_recording/flutter_screen_recording.dart';
import 'package:permission_handler/permission_handler.dart';

class RecordingService {
  static bool _isRecording = false;

  static bool get isRecording => _isRecording;

  static Future<bool> startRecording() async {
    if (_isRecording) return true;

    // Check permissions
    final micStatus = await Permission.microphone.request();
    final notificationsStatus = await Permission.notification.request();

    if (micStatus.isGranted || micStatus.isLimited) {
      final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final String fileName = "HypeShot_$timestamp";

      try {
        final success = await FlutterScreenRecording.startRecordScreenAndAudio(
          fileName,
          titleNotification: "HypeShot Recording",
          messageNotification: "Capture in progress...",
        );
        
        if (success) {
          _isRecording = true;
          return true;
        }
      } catch (e) {
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
      return path; // stopRecordScreen usually returns the path
    } catch (e) {
      _isRecording = false;
      return null;
    }
  }
}
