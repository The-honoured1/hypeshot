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
          content: Text('CLIP SAVED TO GALLERY! 🔥', style: TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: AppTheme.primaryNeon,
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
        title: const Text('EDIT HIGHLIGHT', style: TextStyle(letterSpacing: 2, fontSize: 16, fontWeight: FontWeight.w900)),
        leading: IconButton(icon: const Icon(LucideIcons.x), onPressed: () => context.pop()),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: TextButton(
              onPressed: _isProcessing ? null : _exportVideo,
              child: const Text('EXPORT', style: TextStyle(color: AppTheme.secondaryNeon, fontWeight: FontWeight.w900)),
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
                        margin: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 30),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              CropGridViewer.preview(controller: _controller),
                              if (_overlayText.isNotEmpty)
                                Center(
                                  child: Text(
                                    _overlayText.toUpperCase(),
                                    style: const TextStyle(
                                      fontSize: 56,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white,
                                      letterSpacing: -2,
                                      shadows: [
                                        Shadow(blurRadius: 20, color: AppTheme.primaryNeon, offset: Offset(0, 0)),
                                      ],
                                    ),
                                  ).animate().scale(begin: const Offset(0.5, 0.5), end: const Offset(1, 1), curve: Curves.elasticOut, duration: 800.ms),
                                ),
                              _buildPlayButton(),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 120), // Space for floating dock
                  ],
                ),
                _buildFloatingDock(),
                if (_isProcessing) _buildProcessingOverlay(),
              ],
            )
          : const Center(child: CircularProgressIndicator(color: AppTheme.primaryNeon)),
    );
  }

  Widget _buildPlayButton() {
    return AnimatedOpacity(
      opacity: _controller.isPlaying ? 0 : 1,
      duration: const Duration(milliseconds: 200),
      child: GestureDetector(
        onTap: () => _controller.video.play(),
        child: Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: Colors.black38,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white24),
          ),
          child: const Icon(LucideIcons.play, size: 40, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildFloatingDock() {
    return Positioned(
      bottom: 30,
      left: 20,
      right: 20,
      child: GlassCard(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 50,
              child: TrimSlider(
                controller: _controller,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _toolIcon(LucideIcons.timer, 'SLOW-MO', _isSlowMo, () => setState(() => _isSlowMo = !_isSlowMo)),
                _toolIcon(LucideIcons.type, 'TEXT', _overlayText.isNotEmpty, _showTextInput),
                _toolIcon(LucideIcons.maximize, 'ZOOM', false, () {}),
                _toolIcon(LucideIcons.music, 'SFX', false, () {}),
              ],
            ),
          ],
        ),
      ),
    ).animate().slideY(begin: 1, end: 0, duration: 600.ms, curve: Curves.easeOutCubic);
  }

  Widget _toolIcon(IconData icon, String label, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, color: active ? AppTheme.primaryNeon : Colors.white54, size: 22),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w900,
              color: active ? AppTheme.primaryNeon : Colors.white38,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProcessingOverlay() {
    return Container(
      color: Colors.black87,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: AppTheme.secondaryNeon, strokeWidth: 6),
            const SizedBox(height: 24),
            Text(
              'RENDERING HYPE...',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
                color: AppTheme.secondaryNeon,
                shadows: [Shadow(color: AppTheme.secondaryNeon.withOpacity(0.5), blurRadius: 10)],
              ),
            ).animate(onPlay: (c) => c.repeat()).shimmer(duration: 2.seconds),
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
                TextField(
                  autofocus: true,
                  textAlign: TextAlign.center,
                  decoration: const InputDecoration(hintText: 'SUMMON YOUR HYPE...', border: InputBorder.none),
                  style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900),
                  onChanged: (v) => current = v,
                ),
                const SizedBox(height: 24),
                Wrap(
                  spacing: 12,
                  children: ['CLUTCH', 'WTF', 'GG', 'EZ', 'SAVAGE'].map((t) => _presetChip(t)).toList(),
                ),
                const SizedBox(height: 32),
                HypeButton(
                  label: 'ADD OVERLAY',
                  onTap: () {
                    setState(() => _overlayText = current);
                    Navigator.pop(context);
                  },
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _presetChip(String t) {
    return ActionChip(
      label: Text(t, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 10)),
      backgroundColor: Colors.white10,
      onPressed: () {
        setState(() => _overlayText = t);
        Navigator.pop(context);
      },
    );
  }
}
