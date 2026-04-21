import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:device_apps/device_apps.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme.dart';
import '../../providers/game_provider.dart';
import '../../services/game_service.dart';
import '../widgets/recording_widgets.dart';
import '../widgets/mesh_background.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool _autoRecord = true;

  @override
  Widget build(BuildContext context) {
    final appsAsync = ref.watch(appListProvider);
    final isRecording = ref.watch(recordingProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AnimatedBackground(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(isRecording),
              const Spacer(),
              _buildCaptureCentral(isRecording),
              const Spacer(),
              _buildGameLibrary(appsAsync),
              _buildSettingsRow(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isRecording) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'HYPESHOT',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
              color: AppTheme.textPrimary,
            ),
          ),
          StatusPill(isRecording: isRecording),
        ],
      ),
    );
  }

  Widget _buildCaptureCentral(bool isRecording) {
    return Center(
      child: CaptureButton(
        isRecording: isRecording,
        onTap: () async {
          if (isRecording) {
            final chunks = await ref.read(recordingProvider.notifier).stop();
            // In the new flow, we might want to navigate to editor immediately
            // or just stay here. The user said "separate screen for video editing".
          } else {
            await ref.read(recordingProvider.notifier).start();
          }
        },
      ),
    );
  }

  Widget _buildGameLibrary(AsyncValue<List<Application>> appsAsync) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            'LIBRARY',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
              color: AppTheme.textSecondary,
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 90,
          child: appsAsync.when(
            data: (apps) => ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: apps.length,
              itemBuilder: (context, index) {
                final app = apps[index];
                return _buildGameCard(app);
              },
            ),
            loading: () => const Center(child: CircularProgressIndicator(strokeWidth: 2)),
            error: (_, __) => const SizedBox(),
          ),
        ),
      ],
    );
  }

  Widget _buildGameCard(Application app) {
    return Container(
      width: 72,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: GestureDetector(
        onTap: () => _launchGame(app.packageName),
        child: Column(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: AppTheme.surfaceCard(radius: BorderRadius.circular(16)),
              padding: const EdgeInsets.all(8),
              child: Consumer(
                builder: (context, ref, _) {
                  final iconAsync = ref.watch(appIconProvider(app.packageName));
                  return iconAsync.when(
                    data: (icon) => icon != null 
                        ? Image.memory(icon) 
                        : const Icon(LucideIcons.gamepad2),
                    loading: () => const SizedBox(),
                    error: (_, __) => const Icon(LucideIcons.gamepad2),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            Text(
              app.appName.toUpperCase(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'AUTO-CAPTURE',
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppTheme.textSecondary),
          ),
          Switch(
            value: _autoRecord,
            onChanged: (v) => setState(() => _autoRecord = v),
            activeColor: AppTheme.accentPrimary,
          ),
        ],
      ),
    );
  }

  Future<void> _launchGame(String packageName) async {
    if (_autoRecord) {
      await ref.read(recordingProvider.notifier).start();
    }
    await GameService.launchGame(packageName);
  }
}
