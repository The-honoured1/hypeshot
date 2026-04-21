import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'core/theme.dart';
import 'core/navigation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'ui/widgets/mesh_background.dart';
import 'ui/overlay/overlay_entry.dart';
import 'services/editor_pipeline.dart';
import 'services/gallery_service.dart';
import 'providers/game_provider.dart';
export 'ui/overlay/overlay_entry.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

void main() {
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
          importEditorPipeline(chunks);
        }
        await notifier.start();
      }
    });
  }

  Future<void> _initPermissionsAndNotifications() async {
    // Request SYSTEM_ALERT_WINDOW immediately to ensure overlay can work
    await Permission.systemAlertWindow.request();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
        
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        if (response.payload != null) {
          goRouter.push('/preview', extra: response.payload);
        }
      },
    );
  }

  void importEditorPipeline(Map<String, String?> chunks) async {
     final prev = chunks['previous'];
     final curr = chunks['current'];
     final mergedPath = await EditorPipeline.mergeChunks(prev, curr);
     
     if (mergedPath != null) {
       final finalPath = await EditorPipeline.processHighlight(
         inputPath: mergedPath,
         verticalCrop: true,
       );
       
       if (finalPath != null) {
         final savedPath = await GalleryService.saveClipToGallery(finalPath);
         _showSavedNotification(savedPath);
       }
     }
  }

  Future<void> _showSavedNotification(String path) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'hypeshot_saves', 
      'Saves',
      channelDescription: 'Notifications for saved clips',
      importance: Importance.max,
      priority: Priority.high,
    );
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
      0,
      'Highlight Saved! 🎬',
      'Tap to preview or edit your clip.',
      platformChannelSpecifics,
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
      builder: (context, child) {
        return Scaffold(
          body: MeshBackground(child: child ?? const SizedBox()),
        );
      },
    );
  }
}

