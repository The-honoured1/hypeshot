import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:device_apps/device_apps.dart';
import '../services/game_service.dart';
import '../services/recording_buffer_service.dart';

final appListProvider = FutureProvider<List<Application>>((ref) async {
  return await GameService.getInstalledGames();
});

final appIconProvider = FutureProvider.family<Uint8List?, String>((ref, packageName) async {
  Application? app = await DeviceApps.getApp(packageName, true);
  if (app is ApplicationWithIcon) {
    return app.icon;
  }
  return null;
});

class RecordingState extends Notifier<bool> {
  @override
  bool build() {
    RecordingBufferService.bufferingStream.listen((isBuffering) {
      state = isBuffering;
    });
    return RecordingBufferService.isBuffering;
  }

  Future<void> start() async {
    final success = await RecordingBufferService.startBuffer();
    if (success) state = true;
  }

  Future<Map<String, String?>> stop() async {
    final chunks = await RecordingBufferService.captureMoment();
    state = false;
    return chunks;
  }
}

final recordingProvider = NotifierProvider<RecordingState, bool>(RecordingState.new);
