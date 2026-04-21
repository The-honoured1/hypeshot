import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'core/theme.dart';
import 'core/navigation.dart';
import 'ui/widgets/mesh_background.dart';
import 'ui/overlay/overlay_entry.dart';
import 'services/editor_pipeline.dart';
import 'services/gallery_service.dart';
import 'providers/game_provider.dart';
export 'ui/overlay/overlay_entry.dart';

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
    FlutterOverlayWindow.overlayListener.listen((event) async {
      if (event == "CAPTURE_HIGHLIGHT") {
        // Trigger capture and auto-save
        final notifier = ref.read(recordingProvider.notifier);
        // We need to implement extraction saving in recordingProvider!
        // To be safe, we'll invoke the stop() feature.
        final chunks = await notifier.stop();
        if (chunks['current'] != null || chunks['previous'] != null) {
          // This requires EditorPipeline directly
          importEditorPipeline(chunks);
        }
        // Restart recording
        await notifier.start();
      }
    });
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
         await GalleryService.saveClipToGallery(finalPath);
         // Notification or toast could go here for "Saved to Gallery"
       }
     }
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

