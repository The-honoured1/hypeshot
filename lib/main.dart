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
import 'services/recording_buffer_service.dart';


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
    
    // Step 3-5: Floating Button -> Quick Preview Flow
    FlutterOverlayWindow.overlayListener.listen((event) async {
      final notifier = ref.read(recordingProvider.notifier);
      
      if (event == "CAPTURE_HIGHLIGHT") {
        final chunks = await notifier.stop();
        if (chunks['current'] != null || chunks['previous'] != null) {
          _handleCaptureSuccess(chunks);
        }
        await notifier.start(); // Auto-restart loop
      } else if (event == "PAUSE_BUFFER") {
        await RecordingBufferService.pauseBuffer();
      } else if (event == "RESUME_BUFFER") {
        await RecordingBufferService.resumeBuffer();
      } else if (event == "TAKE_SCREENSHOT") {
        final path = await RecordingBufferService.takeScreenshot();
        if (path != null) _showScreenshotNotification(path);
      } else if (event == "STOP_BUFFER") {
        await RecordingBufferService.stopBuffer();
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

  void _handleCaptureSuccess(Map<String, String?> chunks) async {
     // Step 4: Rapid Save & Process
     final mergedPath = await EditorPipeline.mergeChunks(chunks['previous'], chunks['current']);
     if (mergedPath != null) {
       final finalPath = await EditorPipeline.processHighlight(inputPath: mergedPath);
       if (finalPath != null) {
         final savedPath = await GalleryService.saveClipToGallery(finalPath);
         
         // Step 5: Critical UX - Pop notification for fast preview
         _showStudioNotification(savedPath);
         
         // Also jump app to preview if it's currently open
         if (mounted) {
           goRouter.push('/preview', extra: savedPath);
         }
       }
     }
  }

  Future<void> _showScreenshotNotification(String path) async {
    await flutterLocalNotificationsPlugin.show(
      1,
      'SCREENSHOT SAVED',
      'VIEW IN GALLERY',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'hypeshot_screenshots', 'SCREENSHOTS',
          importance: Importance.low, 
          priority: Priority.low,
          color: Color(0xFFFFA500),
        ),
      ),
      payload: path,
    );
  }

  Future<void> _showStudioNotification(String path) async {
    await flutterLocalNotificationsPlugin.show(
      0,
      'HIGHLIGHT STASHED',
      'VIEW NOW',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'hypeshot_saves', 'SAVES',
          importance: Importance.max, 
          priority: Priority.high,
          color: Color(0xFFFF3B30),
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
