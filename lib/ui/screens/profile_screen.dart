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
        title: const Text('PROFILE', style: TextStyle(letterSpacing: 4, fontWeight: FontWeight.w900, fontSize: 16)),
        leading: IconButton(
          icon: const Icon(LucideIcons.chevronLeft),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 20),
              _buildAvatarSection(context),
              const SizedBox(height: 32),
              _buildStatsGrid(context),
              const SizedBox(height: 40),
              _buildClipsHeader(context),
              const SizedBox(height: 20),
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
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppTheme.primaryNeon, width: 2),
            ),
            child: const CircleAvatar(
              radius: 60,
              backgroundImage: NetworkImage('https://i.pravatar.cc/300'),
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'PRO_GAMER_99',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: 1),
        ).animate().fadeIn().scale(),
        const Text(
          'LEGENDARY CLIPPER',
          style: TextStyle(color: AppTheme.secondaryNeon, fontWeight: FontWeight.w800, fontSize: 12, letterSpacing: 2),
        ).animate().fadeIn(delay: 200.ms),
      ],
    );
  }

  Widget _buildStatsGrid(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _statCard('42', 'CLIPS', LucideIcons.video, AppTheme.primaryNeon)),
        const SizedBox(width: 16),
        Expanded(child: _statCard('1.2k', 'SHARES', LucideIcons.share2, AppTheme.secondaryNeon)),
        const SizedBox(width: 16),
        Expanded(child: _statCard('15', 'WINS', LucideIcons.trophy, AppTheme.statGlow)),
      ],
    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _statCard(String value, String label, IconData icon, Color color) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(vertical: 16),
      glowColor: color,
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
          Text(label, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: Colors.white38)),
        ],
      ),
    );
  }

  Widget _buildClipsHeader(BuildContext context) {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'SAVED HIGHLIGHTS',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 2, color: Colors.white54),
        ),
        Icon(LucideIcons.filter, size: 16, color: Colors.white38),
      ],
    );
  }

  Widget _buildClipsGrid(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.8,
      ),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Hero(
          tag: 'clip_$index',
          child: GlassCard(
            padding: EdgeInsets.zero,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                image: DecorationImage(
                  image: NetworkImage('https://picsum.photos/seed/${index + 50}/300/400'),
                  fit: BoxFit.cover,
                  opacity: 0.6,
                ),
              ),
              child: const Center(
                child: Icon(LucideIcons.playCircle, color: Colors.white, size: 40),
              ),
            ),
          ),
        ).animate().fadeIn(delay: Duration(milliseconds: 100 * index)).slideY(begin: 0.1, end: 0);
      },
    );
  }
}
