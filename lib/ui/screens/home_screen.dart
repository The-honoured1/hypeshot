import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme.dart';
import '../../providers/game_provider.dart';
import '../widgets/recording_widgets.dart';
import '../widgets/mesh_background.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isRecording = ref.watch(recordingProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AnimatedBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 48),
                _buildHeader(),
                const Spacer(),
                CaptureButton(
                  isRecording: isRecording,
                  onTap: () async {
                    if (isRecording) {
                      await ref.read(recordingProvider.notifier).stop();
                    } else {
                      await ref.read(recordingProvider.notifier).start();
                    }
                  },
                ),
                const SizedBox(height: 32),
                StatusPill(isRecording: isRecording),
                const Spacer(),
                const Text(
                  'PRESS START TO ENABLE BUFFER',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textDim,
                    letterSpacing: 1.5,
                  ),
                ),
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
      children: [
        const SizedBox(width: 48), // Spacer for centering title
        const Text(
          'HYPESHOT',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w900,
            letterSpacing: -1,
            color: AppTheme.textMain,
          ),
        ),
        IconButton(
          icon: const Icon(LucideIcons.settings, color: AppTheme.textDim, size: 20),
          onPressed: () => context.push('/settings'),
        ),
      ],
    );
  }
}
