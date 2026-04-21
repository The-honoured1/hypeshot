import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:device_apps/device_apps.dart';
import '../services/game_service.dart';
import '../services/recording_service.dart';

final appListProvider = FutureProvider<List<Application>>((ref) async {
  return await GameService.getInstalledGames();
});

class RecordingState extends Notifier<bool> {
  @override
  bool build() => false;

  Future<void> start() async {
    final success = await RecordingService.startRecording();
    if (success) state = true;
  }

  Future<String?> stop() async {
    final path = await RecordingService.stopRecording();
    state = false;
    return path;
  }
}

final recordingProvider = NotifierProvider<RecordingState, bool>(RecordingState.new);
