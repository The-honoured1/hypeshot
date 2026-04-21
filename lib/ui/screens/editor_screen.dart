import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_editor/video_editor.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme.dart';
import '../../services/share_service.dart';
import '../../services/editor_pipeline.dart';
import '../widgets/glass_widgets.dart';

class EditorScreen extends StatefulWidget {
  final String? videoPath;
  final Map<String, String?>? chunks;
  const EditorScreen({super.key, this.videoPath, this.chunks});

  @override
  State<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends State<EditorScreen> {
  late VideoEditorController _controller;
  bool _isControllerInitialized = false;
  bool _isSlowMo = false;
  String _overlayText = "";
  bool _hasError = false;
  String _errorMessage = "";
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    if (widget.chunks != null) {
      _processChunks();
    } else {
      _initEditor(widget.videoPath ?? '/dummy/path/clip.mp4');
    }
  }

  Future<void> _processChunks() async {
    setState(() => _isProcessing = true);
    final prev = widget.chunks!['previous'];
    final curr = widget.chunks!['current'];
    
    final mergedPath = await EditorPipeline.mergeChunks(prev, curr);
    
    final finalPath = await EditorPipeline.processHighlight(
      inputPath: mergedPath ?? '/dummy/path/clip.mp4',
      verticalCrop: true,
      caption: "HYPE MOMENT"
    );
    
    if (mounted) {
      _initEditor(finalPath ?? mergedPath ?? '/dummy/path/clip.mp4');
      setState(() => _isProcessing = false);
    }
  }

  void _initEditor(String path) {
    if (_isControllerInitialized) {
      _controller.dispose();
    }
    final file = File(path);
    if (!file.existsSync() || path.contains('dummy')) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _errorMessage = "empty canvas.\nno capture found.";
        });
      }
      return;
    }
    
    _controller = VideoEditorController.file(
      file,
      minDuration: const Duration(seconds: 1),
      maxDuration: const Duration(seconds: 30),
    )..initialize().then((_) {
      if (mounted) {
        setState(() => _isControllerInitialized = true);
      }
    }).catchError((e) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _errorMessage = "could not load framework: $e";
        });
      }
    });
  }

  @override
  void dispose() {
    if (_isControllerInitialized) {
      _controller.dispose();
    }
    super.dispose();
  }

  Future<void> _exportVideo() async {
    setState(() => _isProcessing = true);
    await ShareService.saveToGallery(_controller.file.path);
    if (mounted) {
      setState(() => _isProcessing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('saved to local.', style: TextStyle(fontWeight: FontWeight.w400)),
          backgroundColor: AppTheme.surface,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _shareVideo() async {
    await ShareService.shareToPlatform(_controller.file.path);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: _hasError
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(LucideIcons.videoOff, color: AppTheme.textSecondary, size: 32),
                  const SizedBox(height: 16),
                  Text(
                    _errorMessage,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12, height: 1.5, letterSpacing: 0.5),
                  ),
                  const SizedBox(height: 32),
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white24),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: const Text('return', style: TextStyle(color: Colors.white, fontSize: 11, letterSpacing: 1)),
                    ),
                  ),
                ],
              ),
            )
          : _isControllerInitialized && _controller.initialized
              ? Stack(
                  children: [
                    // Canvas
                    Positioned.fill(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          CropGridViewer.preview(controller: _controller),
                          if (_overlayText.isNotEmpty)
                            Center(
                              child: Text(
                                _overlayText.toLowerCase(),
                                style: const TextStyle(
                                  fontSize: 48,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.white,
                                  letterSpacing: -1,
                                ),
                              ).animate().fadeIn(duration: 400.ms),
                            ),
                          _buildPlayPause(),
                        ],
                      ),
                    ),
                    // Floating Header
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(
                                icon: const Icon(LucideIcons.chevronLeft, size: 24, color: Colors.white),
                                onPressed: () => context.pop(),
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(LucideIcons.send, size: 20, color: Colors.white),
                                    onPressed: _isProcessing ? null : _shareVideo,
                                  ),
                                  const SizedBox(width: 8),
                                  IconButton(
                                    icon: const Icon(LucideIcons.download, size: 20, color: Colors.white),
                                    onPressed: _isProcessing ? null : _exportVideo,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Floating Dock
                    _buildMinimalDock(),
                    if (_isProcessing) _buildCalmOverlay(),
                  ],
                )
              : Stack(
                  children: [
                    const Center(child: CircularProgressIndicator(strokeWidth: 1.5, color: Colors.white54)),
                    if (_isProcessing) _buildCalmOverlay(),
                  ],
                ),
    );
  }

  Widget _buildPlayPause() {
    return AnimatedOpacity(
      opacity: _controller.isPlaying ? 0 : 1,
      duration: const Duration(milliseconds: 200),
      child: GestureDetector(
        onTap: () {
          if (_controller.isPlaying) {
             _controller.video.pause();
          } else {
             _controller.video.play();
          }
        },
        child: Container(
          width: 80,
          height: 80,
          decoration: const BoxDecoration(
            color: Colors.transparent,
          ),
          child: const Center(
            child: Icon(LucideIcons.play, size: 32, color: Colors.white54),
          ),
        ),
      ),
    );
  }

  Widget _buildMinimalDock() {
    return Positioned(
      bottom: 32,
      left: 24,
      right: 24,
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
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _toolIcon(LucideIcons.timer, 'slow', _isSlowMo, () => setState(() => _isSlowMo = !_isSlowMo)),
              _toolIcon(LucideIcons.type, 'text', _overlayText.isNotEmpty, _showTextInput),
              _toolIcon(LucideIcons.crop, 'crop', false, () {}),
              _toolIcon(LucideIcons.volume2, 'audio', false, () {}),
            ],
          ),
        ],
      ).animate().fadeIn(duration: 600.ms),
    );
  }

  Widget _toolIcon(IconData icon, String label, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, color: active ? Colors.white : Colors.white38, size: 18),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w400,
              color: active ? Colors.white : Colors.white38,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalmOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.85),
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 1.5, color: Colors.white)),
            SizedBox(height: 32),
            Text(
              'saving...',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: AppTheme.textSecondary,
                letterSpacing: 1,
              ),
            ),
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
          child: Container(
            decoration: const BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 12),
                Container(width: 32, height: 4, decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(2))),
                const SizedBox(height: 32),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: TextField(
                    autofocus: true,
                    textAlign: TextAlign.center,
                    decoration: const InputDecoration(hintText: 'abstract mark...', border: InputBorder.none, hintStyle: TextStyle(color: Colors.white24)),
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w400, color: Colors.white, letterSpacing: -0.5),
                    onChanged: (v) => current = v,
                  ),
                ),
                const SizedBox(height: 48),
                GestureDetector(
                  onTap: () {
                    setState(() => _overlayText = current);
                    Navigator.pop(context);
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 40),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppTheme.textPrimary,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Center(
                      child: Text('embed', style: TextStyle(color: AppTheme.surface, fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 0.5)),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        );
      },
    );
  }
}
