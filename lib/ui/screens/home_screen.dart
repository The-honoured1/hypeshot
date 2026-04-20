import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme.dart';
import '../widgets/glass_widgets.dart';
import '../widgets/recording_widgets.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
              const SizedBox(height: 40),
              _buildWelcomeSection(context),
              const Spacer(),
              _buildCaptureCentral(context),
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
            const HypeMeter(level: 0.65),
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

  Widget _buildWelcomeSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'READY TO CLIP?',
          style: Theme.of(context).textTheme.displayLarge,
        ).animate().fadeIn(duration: 600.ms).slideX(begin: -0.2, end: 0),
        const SizedBox(height: 12),
        GlassCard(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const RecordingWave(),
              const SizedBox(width: 12),
              const Text(
                'BUFFER ACTIVE',
                style: TextStyle(
                  color: AppTheme.secondaryNeon,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
        ).animate().fadeIn(delay: 200.ms).scale(begin: const Offset(0.8, 0.8)),
      ],
    );
  }

  Widget _buildCaptureCentral(BuildContext context) {
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer Glow
          Container(
            width: 240,
            height: 240,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.primaryNeon.withOpacity(0.1),
            ),
          ).animate(onPlay: (c) => c.repeat(reverse: true))
           .scale(begin: const Offset(0.8, 0.8), end: const Offset(1.2, 1.2), duration: 2.seconds),
          
          Column(
            children: [
              HypeButton(
                label: 'Capture last 30s',
                icon: LucideIcons.camera,
                onTap: () => context.push('/editor'),
              ),
              const SizedBox(height: 24),
              const Text(
                'TAP TO SAVE MOMENT',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: Colors.white38,
                  letterSpacing: 2,
                ),
              ).animate().fadeIn(delay: 1.seconds),
            ],
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
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
              color: Colors.white54,
            ),
          ),
        ),
        SizedBox(
          height: 140,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 5,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Hero(
                  tag: 'clip_$index',
                  child: GlassCard(
                    padding: EdgeInsets.zero,
                    glowColor: index == 0 ? AppTheme.primaryNeon : null,
                    child: Container(
                      width: 120,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        image: DecorationImage(
                          image: NetworkImage('https://picsum.photos/seed/${index + 10}0/300/400'),
                          fit: BoxFit.cover,
                          opacity: 0.5,
                        ),
                      ),
                      child: Stack(
                        children: [
                          if (index == 0)
                            Positioned(
                              top: 8,
                              right: 8,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryNeon,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text('NEW', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold)),
                              ),
                            ),
                          const Center(
                            child: Icon(LucideIcons.playCircle, color: Colors.white, size: 32),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2, end: 0),
      ],
    );
  }
}
