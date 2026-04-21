import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:video_player/video_player.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme.dart';
import '../../services/gallery_service.dart';

class PreviewScreen extends StatefulWidget {
  final String videoPath;
  const PreviewScreen({super.key, required this.videoPath});

  @override
  State<PreviewScreen> createState() => _PreviewScreenState();
}

class _PreviewScreenState extends State<PreviewScreen> {
  late VideoPlayerController _controller;
  bool _initialized = false;
  bool _isPlaying = true;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(File(widget.videoPath))
      ..initialize().then((_) {
        setState(() {
          _initialized = true;
          _controller.setLooping(true);
          _controller.play();
        });
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _togglePlay() {
    setState(() {
      if (_controller.value.isPlaying) {
        _controller.pause();
        _isPlaying = false;
      } else {
        _controller.play();
        _isPlaying = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Auto-playing video
          Positioned.fill(
            child: _initialized
                ? GestureDetector(
                    onTap: _togglePlay,
                    child: Center(
                      child: AspectRatio(
                        aspectRatio: _controller.value.aspectRatio,
                        child: VideoPlayer(_controller),
                      ),
                    ),
                  )
                : const Center(child: CircularProgressIndicator(strokeWidth: 1.5, color: Colors.white54)),
          ),
          
          // Header / Back
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(LucideIcons.chevronLeft, size: 24, color: Colors.white),
                      onPressed: () => context.pop(),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Foot controls
          Positioned(
            bottom: 32,
            left: 24,
            right: 24,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _actionIcon(LucideIcons.trash2, 'discard', () async {
                      await GalleryService.deleteClip(widget.videoPath);
                      if (context.mounted) context.pop();
                    }),
                    _actionIcon(LucideIcons.slidersHorizontal, 'edit', () {
                      _controller.pause();
                      context.push('/editor', extra: widget.videoPath);
                    }),
                    _actionIcon(LucideIcons.save, 'keep', () {
                      // Already auto-saved in gallery, just exit
                      context.pop();
                    }),
                  ],
                ),
              ],
            ).animate().fadeIn(duration: 400.ms),
          ),
          
          // Pause Indicator
          if (_initialized && !_isPlaying)
            Center(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.black45, shape: BoxShape.circle),
                child: const Icon(LucideIcons.play, size: 32, color: Colors.white),
              ).animate().scale(duration: 150.ms),
            ),
        ],
      ),
    );
  }

  Widget _actionIcon(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: AppTheme.surface,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 10, letterSpacing: 0.5),
          ),
        ],
      ),
    );
  }
}
