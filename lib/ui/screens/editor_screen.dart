import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_editor/video_editor.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme.dart';
import '../../services/share_service.dart';
import '../widgets/glass_widgets.dart';

class EditorScreen extends StatefulWidget {
  final String? videoPath;
  const EditorScreen({super.key, this.videoPath});

  @override
  State<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends State<EditorScreen> {
  late VideoEditorController _controller;
  bool _isSlowMo = false;
  String _overlayText = "";
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    final file = File(widget.videoPath ?? '/dummy/path/clip.mp4');
    _controller = VideoEditorController.file(
      file,
      minDuration: const Duration(seconds: 1),
      maxDuration: const Duration(seconds: 30),
    )..initialize().then((_) => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _exportVideo() async {
    setState(() => _isProcessing = true);
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      setState(() => _isProcessing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Saved to Gallery', style: TextStyle(fontWeight: FontWeight.w600)),
          backgroundColor: AppTheme.surface,
          behavior: SnackBarBehavior.floating,
        ),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('EDIT PROJECT', style: TextStyle(letterSpacing: 1, fontSize: 13, fontWeight: FontWeight.w700)),
        leading: IconButton(icon: const Icon(LucideIcons.x, size: 20), onPressed: () => context.pop()),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: TextButton(
              onPressed: _isProcessing ? null : _exportVideo,
              child: const Text('SAVE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
            ),
          ),
        ],
      ),
      body: _controller.initialized
          ? Stack(
              children: [
                Column(
                  children: [
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              CropGridViewer.preview(controller: _controller),
                              if (_overlayText.isNotEmpty)
                                Center(
                                  child: Text(
                                    _overlayText,
                                    style: const TextStyle(
                                      fontSize: 48,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                      letterSpacing: -1,
                                    ),
                                  ).animate().fadeIn(duration: 400.ms),
                                ),
                              _buildPlayPause(),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 140),
                  ],
                ),
                _buildMinimalDock(),
                if (_isProcessing) _buildCalmOverlay(),
              ],
            )
          : const Center(child: CircularProgressIndicator(strokeWidth: 2)),
    );
  }

  Widget _buildPlayPause() {
    return AnimatedOpacity(
      opacity: _controller.isPlaying ? 0 : 1,
      duration: const Duration(milliseconds: 200),
      child: GestureDetector(
        onTap: () => _controller.video.play(),
        child: Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: Colors.black26,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: const Icon(LucideIcons.play, size: 24, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildMinimalDock() {
    return Positioned(
      bottom: 24,
      left: 24,
      right: 24,
      child: GlassCard(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 40,
              child: TrimSlider(
                controller: _controller,
              ),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _toolIcon(LucideIcons.timer, 'Slow', _isSlowMo, () => setState(() => _isSlowMo = !_isSlowMo)),
                _toolIcon(LucideIcons.type, 'Text', _overlayText.isNotEmpty, _showTextInput),
                _toolIcon(LucideIcons.maximize, 'Crop', false, () {}),
                _toolIcon(LucideIcons.volume2, 'Audio', false, () {}),
              ],
            ),
          ],
        ),
      ),
    ).animate().fadeIn();
  }

  Widget _toolIcon(IconData icon, String label, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, color: active ? Colors.white : Colors.white24, size: 20),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w600,
              color: active ? Colors.white : Colors.white24,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalmOverlay() {
    return Container(
      color: AppTheme.background.withOpacity(0.9),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(strokeWidth: 2, color: Colors.white24),
            const SizedBox(height: 32),
            const Text(
              'Saving Project...',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.white54,
                letterSpacing: 0.5,
              ),
            ).animate(onPlay: (c) => c.repeat()).shimmer(duration: 3.seconds),
          ],
        ),
      ),
    );
  }

  void _showTextInput() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        String current = _overlayText;
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: GlassCard(
            radius: const BorderRadius.only(topLeft: Radius.circular(32), topRight: Radius.circular(32)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 4),
                Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(2))),
                const SizedBox(height: 32),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: TextField(
                    autofocus: true,
                    textAlign: TextAlign.center,
                    decoration: const InputDecoration(hintText: 'Add Caption...', border: InputBorder.none, hintStyle: TextStyle(color: Colors.white12)),
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
                    onChanged: (v) => current = v,
                  ),
                ),
                const SizedBox(height: 48),
                HypeButton(
                  label: 'Add to Project',
                  onTap: () {
                    setState(() => _overlayText = current);
                    Navigator.pop(context);
                  },
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        );
      },
    );
  }
}
