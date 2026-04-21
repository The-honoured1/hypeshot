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
                const SizedBox(height: 60),
                _buildCaptureCentral(context, isRecording),
                const SizedBox(height: 60),
                _buildRecentSection(context),
                const SizedBox(height: 32),
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
                'HYPESHOT',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 4,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              const HypeMeter(level: 0.72),
            ],
          ),
        ),
        const SizedBox(width: 24),
        GestureDetector(
          onTap: () => context.push('/profile'),
          child: Hero(
            tag: 'profile_avatar',
            child: Container(
              padding: const EdgeInsets.all(1.5),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
              ),
              child: const CircleAvatar(
                radius: 18,
                backgroundImage: NetworkImage('https://i.pravatar.cc/100'),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildControlPanel(bool isRecording) {
    return Row(
      children: [
        GlassCard(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isRecording) const RecordingWave() else Icon(LucideIcons.circle, size: 12, color: Colors.white.withOpacity(0.2)),
              const SizedBox(width: 12),
              Text(
                isRecording ? 'RECORDING' : 'STANDBY',
                style: TextStyle(
                  color: isRecording ? Colors.white : Colors.white24,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: GlassCard(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('AUTO-CAPTURE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white54)),
                Transform.scale(
                  scale: 0.7,
                  child: Switch(
                    value: _autoRecord,
                    onChanged: (v) => setState(() => _autoRecord = v),
                    activeColor: Colors.white,
                    activeTrackColor: Colors.white.withOpacity(0.2),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGameLauncher(AsyncValue<List<Application>> appsAsync) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'LAST PLAYED',
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.5, color: Colors.white38),
        ),
        const SizedBox(height: 20),
        SizedBox(
          height: 80,
          child: appsAsync.when(
            data: (apps) => ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: apps.length,
              itemBuilder: (context, index) {
                final app = apps[index];
                return Padding(
                  padding: const EdgeInsets.only(right: 20),
                  child: GestureDetector(
                    onTap: () => _launchGameWithRecord(app.packageName),
                    child: Column(
                      children: [
                        Container(
                          width: 54,
                          height: 54,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: Colors.white.withOpacity(0.05)),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: Consumer(
                              builder: (context, ref, _) {
                                final iconAsync = ref.watch(appIconProvider(app.packageName));
                                return iconAsync.when(
                                  data: (iconData) => iconData != null
                                      ? Image.memory(iconData, fit: BoxFit.cover, opacity: const AlwaysStoppedAnimation(0.8))
                                      : const Icon(LucideIcons.layoutGrid, size: 20),
                                  loading: () => const Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white24))),
                                  error: (_, __) => const Icon(LucideIcons.layoutGrid, size: 20),
                                );
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: 54,
                          child: Text(
                            app.appName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w500, color: Colors.white54),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            loading: () => const Center(child: CircularProgressIndicator(strokeWidth: 2)),
            error: (e, s) => const Text('Error loading apps'),
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
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 240,
                height: 240,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withOpacity(0.03), width: 2),
                ),
              ),
              HypeButton(
                label: isRecording ? 'Finish Recording' : 'Capture Project',
                icon: isRecording ? LucideIcons.check : LucideIcons.camera,
                isPrimary: true,
                onTap: () async {
                  if (isRecording) {
                    final chunks = await ref.read(recordingProvider.notifier).stop();
                    if ((chunks['current'] != null || chunks['previous'] != null) && mounted) {
                      context.push('/editor', extra: chunks);
                    }
                  } else {
                    context.push('/editor');
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            'TAP TO RECORD HIGHLIGHT',
            style: TextStyle(fontSize: 8, fontWeight: FontWeight.w700, color: Colors.white24, letterSpacing: 1),
          ).animate().fadeIn(delay: 500.ms),
        ],
      ),
    );
  }

  Widget _buildRecentSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'RECENT PROJECTS',
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.5, color: Colors.white38),
        ),
        const SizedBox(height: 20),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 3,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Hero(
                  tag: 'home_clip_$index',
                  child: GlassCard(
                    padding: EdgeInsets.zero,
                    child: Container(
                      width: 140,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        image: DecorationImage(
                          image: NetworkImage('https://picsum.photos/seed/${index + 10}/400/300'),
                          fit: BoxFit.cover,
                          opacity: 0.3,
                        ),
                      ),
                      child: const Center(child: Icon(LucideIcons.play, color: Colors.white54, size: 24)),
                    ),
                  ),
                ),
              );
            },
          ),
        ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1, end: 0),
      ],
    );
  }
}
