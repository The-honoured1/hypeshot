import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme.dart';
import '../widgets/glass_widgets.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('MOMENTS', style: TextStyle(letterSpacing: 2, fontWeight: FontWeight.w700, fontSize: 13)),
        leading: IconButton(
          icon: const Icon(LucideIcons.chevronLeft, size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 32),
              _buildAvatarSection(context),
              const SizedBox(height: 48),
              _buildStatsRow(context),
              const SizedBox(height: 56),
              _buildClipsHeader(context),
              const SizedBox(height: 24),
              _buildClipsGrid(context),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarSection(BuildContext context) {
    return Column(
      children: [
        Hero(
          tag: 'profile_avatar',
          child: Container(
            padding: const EdgeInsets.all(1),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
            ),
            child: const CircleAvatar(
              radius: 56,
              backgroundImage: NetworkImage('https://i.pravatar.cc/300'),
            ),
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'ProGamer99',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, letterSpacing: -0.5),
        ).animate().fadeIn().moveY(begin: 10, end: 0),
        const SizedBox(height: 4),
        const Text(
          'Moment Collector',
          style: TextStyle(color: Colors.white38, fontWeight: FontWeight.w500, fontSize: 13, letterSpacing: 0.5),
        ).animate().fadeIn(delay: 200.ms),
      ],
    );
  }

  Widget _buildStatsRow(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _statColumn('42', 'CLIPS'),
        _statDivider(),
        _statColumn('1.2k', 'SHARES'),
        _statDivider(),
        _statColumn('15', 'WINS'),
      ],
    ).animate().fadeIn(delay: 400.ms);
  }

  Widget _statColumn(String value, String label) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: Colors.white30, letterSpacing: 1)),
      ],
    );
  }

  Widget _statDivider() {
    return Container(width: 1, height: 20, color: Colors.white.withOpacity(0.05));
  }

  Widget _buildClipsHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'COLLECTION',
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.5, color: Colors.white38),
        ),
        Icon(LucideIcons.list, size: 14, color: Colors.white12),
      ],
    );
  }

  Widget _buildClipsGrid(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 20,
        crossAxisSpacing: 20,
        childAspectRatio: 0.85,
      ),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Hero(
          tag: 'home_clip_$index',
          child: GlassCard(
            padding: EdgeInsets.zero,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                image: DecorationImage(
                  image: NetworkImage('https://picsum.photos/seed/${index + 50}/400/500'),
                  fit: BoxFit.cover,
                  opacity: 0.4,
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    bottom: 12,
                    left: 12,
                    child: Text(
                      '30s',
                      style: TextStyle(fontSize: 9, color: Colors.white30, fontWeight: FontWeight.w600),
                    ),
                  ),
                  const Center(
                    child: Icon(LucideIcons.play, color: Colors.white24, size: 28),
                  ),
                ],
              ),
            ),
          ),
        ).animate().fadeIn(delay: Duration(milliseconds: 100 * index)).moveY(begin: 20, end: 0);
      },
    );
  }
}
