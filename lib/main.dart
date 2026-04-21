import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'core/theme.dart';
import 'core/navigation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'services/editor_pipeline.dart';
import 'services/gallery_service.dart';
import 'providers/game_provider.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const ProviderScope(
      child: HypeShotApp(),
    ),
  );
}

class HypeShotApp extends ConsumerStatefulWidget {
  const HypeShotApp({super.key});

  @override
  ConsumerState<HypeShotApp> createState() => _HypeShotAppState();
}

class _HypeShotAppState extends ConsumerState<HypeShotApp> {
  @override
  void initState() {
    super.initState();
    _initPermissionsAndNotifications();
    
    FlutterOverlayWindow.overlayListener.listen((event) async {
      if (event == "CAPTURE_HIGHLIGHT") {
        final notifier = ref.read(recordingProvider.notifier);
        final chunks = await notifier.stop();
        if (chunks['current'] != null || chunks['previous'] != null) {
          _importHighlight(chunks);
        }
        await notifier.start();
      }
    });
  }

  Future<void> _initPermissionsAndNotifications() async {
    await Permission.systemAlertWindow.request();
    await Permission.notification.request();

    const initializationSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    );
        
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (response) {
        if (response.payload != null) {
          goRouter.push('/preview', extra: response.payload);
        }
      },
    );
  }

  void _importHighlight(Map<String, String?> chunks) async {
     final mergedPath = await EditorPipeline.mergeChunks(chunks['previous'], chunks['current']);
     if (mergedPath != null) {
       final finalPath = await EditorPipeline.processHighlight(inputPath: mergedPath);
       if (finalPath != null) {
         final savedPath = await GalleryService.saveClipToGallery(finalPath);
         _showNotification(savedPath);
       }
     }
  }

  Future<void> _showNotification(String path) async {
    await flutterLocalNotificationsPlugin.show(
      0,
      'HIGHLIGHT SAVED',
      'TAP TO PREVIEW',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'hypeshot_saves', 'SAVES',
          importance: Importance.max, priority: Priority.high,
        ),
      ),
      payload: path,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'HypeShot',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      routerConfig: goRouter,
    );
  }
}
