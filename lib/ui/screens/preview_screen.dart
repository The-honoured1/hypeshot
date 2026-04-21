import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(File(widget.videoPath))
      ..initialize().then((_) {
        if (mounted) {
          setState(() {
            _initialized = true;
            _controller.setLooping(true);
            _controller.play();
          });
        }
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          if (_initialized)
            Center(
              child: AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              ),
            )
          else
            const Center(child: CircularProgressIndicator(strokeWidth: 2)),
          
          _buildTopBar(),
          _buildActionBar(),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Positioned(
      top: 0, left: 0, right: 0,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(LucideIcons.arrowLeft, color: Colors.white),
                onPressed: () => context.pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionBar() {
    return Positioned(
      bottom: 40, left: 24, right: 24,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _previewAction(LucideIcons.trash2, AppTheme.accentSecondary, () async {
            await GalleryService.deleteClip(widget.videoPath);
            if (context.mounted) context.pop();
          }),
          _previewAction(LucideIcons.edit3, AppTheme.accentPrimary, () {
            _controller.pause();
            context.push('/editor', extra: widget.videoPath);
          }),
          _previewAction(LucideIcons.check, AppTheme.accentTertiary, () => context.pop()),
        ],
      ),
    );
  }

  Widget _previewAction(IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          shape: BoxShape.circle,
          border: Border.all(color: color.withOpacity(0.5), width: 1),
        ),
        child: Icon(icon, color: color, size: 24),
      ),
    );
  }
}
