import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:device_apps/device_apps.dart';
import '../../core/theme.dart';
import '../../providers/game_provider.dart';
import '../../services/game_service.dart';
import '../widgets/glass_widgets.dart';
import '../widgets/recording_widgets.dart';

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
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 32),
                _buildHeader(context),
                const SizedBox(height: 32),
                _buildControlPanel(isRecording),
                const SizedBox(height: 40),
                _buildGameLauncher(appsAsync),
                const SizedBox(height: 40),
                _buildCaptureCentral(context, isRecording),
                const SizedBox(height: 60),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'hypeshot.',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
                  letterSpacing: -0.5,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              const HypeMeter(level: 0.85),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildControlPanel(bool isRecording) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isRecording) const RecordingWave() else Icon(LucideIcons.circle, size: 10, color: Colors.white.withOpacity(0.2)),
              const SizedBox(width: 8),
              Text(
                isRecording ? 'recording' : 'standby',
                style: TextStyle(
                  color: isRecording ? Colors.white : Colors.white54,
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
          GestureDetector(
            onTap: () => setState(() => _autoRecord = !_autoRecord),
            child: Row(
              children: [
                Text('auto-capture', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: _autoRecord ? Colors.white : Colors.white38)),
                const SizedBox(width: 6),
                Icon(_autoRecord ? LucideIcons.checkCircle2 : LucideIcons.circle, size: 14, color: _autoRecord ? Colors.white : Colors.white38),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameLauncher(AsyncValue<List<Application>> appsAsync) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            'library',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: AppTheme.textSecondary),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 70,
          child: appsAsync.when(
            data: (apps) => ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: apps.length,
              itemBuilder: (context, index) {
                final app = apps[index];
                return Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: GestureDetector(
                    onTap: () => _launchGameWithRecord(app.packageName),
                    child: Column(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(24),
                            child: Consumer(
                              builder: (context, ref, _) {
                                final iconAsync = ref.watch(appIconProvider(app.packageName));
                                return iconAsync.when(
                                  data: (iconData) => iconData != null
                                      ? Image.memory(iconData, fit: BoxFit.cover, opacity: const AlwaysStoppedAnimation(0.9))
                                      : const Icon(LucideIcons.layoutGrid, size: 20, color: AppTheme.textSecondary),
                                  loading: () => const Center(child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 1.5, color: Colors.white24))),
                                  error: (_, __) => const Icon(LucideIcons.layoutGrid, size: 20, color: AppTheme.textSecondary),
                                );
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: 54,
                          child: Text(
                            app.appName.toLowerCase(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w400, color: AppTheme.textSecondary),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            loading: () => const Center(child: CircularProgressIndicator(strokeWidth: 1.5, color: AppTheme.textSecondary)),
            error: (e, s) => const Text('could not load library', style: TextStyle(color: AppTheme.textSecondary)),
          ),
        ),
      ],
    );
  }

  Future<void> _launchGameWithRecord(String packageName) async {
    if (_autoRecord) {
      await ref.read(recordingProvider.notifier).start();
    }
    await GameService.launchGame(packageName);
  }

  Widget _buildCaptureCentral(BuildContext context, bool isRecording) {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 48),
          GestureDetector(
            onTap: () async {
              if (isRecording) {
                final chunks = await ref.read(recordingProvider.notifier).stop();
                if ((chunks['current'] != null || chunks['previous'] != null) && mounted) {
                  context.push('/editor', extra: chunks);
                }
              } else {
                await ref.read(recordingProvider.notifier).start();
              }
            },
            child: AnimatedContainer(
              duration: 300.ms,
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isRecording ? AppTheme.accent.withOpacity(0.05) : Colors.transparent,
                border: Border.all(
                  color: isRecording ? AppTheme.accent : Colors.white.withOpacity(0.1),
                  width: 1,
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isRecording ? LucideIcons.focus : LucideIcons.play,
                      size: 32,
                      color: isRecording ? AppTheme.textPrimary : AppTheme.textSecondary,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      isRecording ? 'capture shape' : 'initiate',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: isRecording ? AppTheme.textPrimary : AppTheme.textSecondary,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),
          Text(
            isRecording ? 'tap to extract' : 'tap to buffer',
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w400, color: AppTheme.textSecondary, letterSpacing: 0.5),
          ).animate(target: isRecording ? 1 : 0).fadeIn(delay: 200.ms),
        ],
      ),
    );
  }

}
