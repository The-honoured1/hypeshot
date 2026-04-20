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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              _buildHeader(context),
              const SizedBox(height: 24),
              _buildControlPanel(isRecording),
              const SizedBox(height: 32),
              _buildGameLauncher(appsAsync),
              const Spacer(),
              _buildCaptureCentral(context, isRecording),
              const Spacer(),
              _buildRecentSection(context),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'HYPESHOT',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
                foreground: Paint()
                  ..shader = const LinearGradient(
                    colors: [AppTheme.primaryNeon, AppTheme.secondaryNeon],
                  ).createShader(const Rect.fromLTWH(0.0, 0.0, 200.0, 70.0)),
              ),
            ),
            const HypeMeter(level: 0.72),
          ],
        ),
        GestureDetector(
          onTap: () => context.push('/profile'),
          child: Hero(
            tag: 'profile_avatar',
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.secondaryNeon.withOpacity(0.5), width: 2),
              ),
              child: const CircleAvatar(
                radius: 20,
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
              if (isRecording) const RecordingWave() else const Icon(LucideIcons.radio, size: 16, color: Colors.white24),
              const SizedBox(width: 12),
              Text(
                isRecording ? 'RECORDING LIVE' : 'STANDBY',
                style: TextStyle(
                  color: isRecording ? AppTheme.accentRed : Colors.white24,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: GlassCard(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('AUTO-REC', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.white54)),
                Switch(
                  value: _autoRecord,
                  onChanged: (v) => setState(() => _autoRecord = v),
                  activeColor: AppTheme.secondaryNeon,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
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
          'GAME LAUNCHER',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 2, color: Colors.white54),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 90,
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
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(color: AppTheme.secondaryNeon.withOpacity(0.2), blurRadius: 10),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: app is ApplicationWithIcon 
                                ? Image.memory((app as ApplicationWithIcon).icon, fit: BoxFit.cover)
                                : const Icon(LucideIcons.gamepad2),
                          ),
                        ),
                        const SizedBox(height: 6),
                        SizedBox(
                          width: 60,
                          child: Text(
                            app.appName.toUpperCase(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w900),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, s) => const Text('Error loading games'),
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
              Animate(
                onPlay: (c) => c.repeat(reverse: true),
                child: Container(
                  width: 220,
                  height: 220,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: (isRecording ? AppTheme.accentRed : AppTheme.primaryNeon).withOpacity(0.1),
                  ),
                ),
              ).scale(begin: const Offset(0.9, 0.9), end: const Offset(1.1, 1.1), duration: 2.seconds),
              
              HypeButton(
                label: isRecording ? 'Stop Recording' : 'Capture Highlight',
                icon: isRecording ? LucideIcons.stopCircle : LucideIcons.camera,
                isPrimary: !isRecording,
                onTap: () async {
                  if (isRecording) {
                    final path = await ref.read(recordingProvider.notifier).stop();
                    if (path != null && mounted) {
                      context.push('/editor', extra: path);
                    }
                  } else {
                    context.push('/editor'); // Direct edit for retrospective trigger
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            isRecording ? 'RECORDING SESSION ACTIVE' : 'READY TO CLIP',
            style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: Colors.white38, letterSpacing: 2),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 16),
          child: Text(
            'RECENT HIGHLIGHTS',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 2, color: Colors.white54),
          ),
        ),
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
                      width: 110,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        image: const DecorationImage(
                          image: NetworkImage('https://picsum.photos/300/400'),
                          fit: BoxFit.cover,
                          opacity: 0.4,
                        ),
                      ),
                      child: const Center(child: Icon(LucideIcons.playCircle, color: Colors.white, size: 28)),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
