import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_editor/video_editor.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:go_router/go_router.dart';
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
  bool _initialized = false;
  bool _isProcessing = false;
  String _errorMessage = "";

  @override
  void initState() {
    super.initState();
    if (widget.chunks != null) {
      _processChunks();
    } else if (widget.videoPath != null) {
      _initEditor(widget.videoPath!);
    } else {
      _errorMessage = "NO CLIP SELECTED";
    }
  }

  Future<void> _processChunks() async {
    setState(() => _isProcessing = true);
    final mergedPath = await EditorPipeline.mergeChunks(
      widget.chunks!['previous'], 
      widget.chunks!['current']
    );
    
    if (mergedPath != null) {
      _initEditor(mergedPath);
    } else {
      setState(() {
        _isProcessing = false;
        _errorMessage = "FAILED TO MERGE CHUNKS";
      });
    }
  }

  void _initEditor(String path) {
    final file = File(path);
    if (!file.existsSync()) {
      setState(() => _errorMessage = "FILE NOT FOUND");
      return;
    }

    _controller = VideoEditorController.file(
      file,
      minDuration: const Duration(seconds: 1),
      maxDuration: const Duration(seconds: 30),
    )..initialize().then((_) {
      if (mounted) setState(() => _initialized = true);
    }).catchError((e) {
      if (mounted) setState(() => _errorMessage = "LOAD ERROR");
    });
  }

  @override
  void dispose() {
    if (_initialized) _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: _errorMessage.isNotEmpty
          ? _buildErrorView()
          : _initialized
              ? Stack(
                  children: [
                    Center(child: CropGridViewer.preview(controller: _controller)),
                    _buildHeader(),
                    _buildDock(),
                    if (_isProcessing) _buildProcessingOverlay(),
                  ],
                )
              : const Center(child: CircularProgressIndicator(strokeWidth: 2)),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(LucideIcons.alertTriangle, size: 48, color: AppTheme.accentSecondary),
          const SizedBox(height: 16),
          Text(_errorMessage, style: const TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Positioned(
      top: 0, left: 0, right: 0,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(LucideIcons.chevronLeft),
                onPressed: () => context.pop(),
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(LucideIcons.share2),
                    onPressed: () => ShareService.shareToPlatform(_controller.file.path),
                  ),
                  const SizedBox(width: 8),
                  HypeButton(
                    label: 'SAVE',
                    onTap: _exportVideo,
                    isPrimary: true,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDock() {
    return Positioned(
      bottom: 24, left: 24, right: 24,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 40,
            child: TrimSlider(controller: _controller),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
            decoration: AppTheme.accentGlass(radius: BorderRadius.circular(32)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _toolIcon(LucideIcons.scissors, 'TRIM'),
                _toolIcon(LucideIcons.type, 'TEXT'),
                _toolIcon(LucideIcons.volume2, 'AUDIO'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _toolIcon(IconData icon, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 20, color: AppTheme.textPrimary),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w700)),
      ],
    );
  }

  Widget _buildProcessingOverlay() {
    return Container(
      color: Colors.black87,
      child: const Center(
        child: CircularProgressIndicator(color: AppTheme.accentPrimary),
      ),
    );
  }

  Future<void> _exportVideo() async {
    setState(() => _isProcessing = true);
    await ShareService.saveToGallery(_controller.file.path);
    if (mounted) {
      setState(() => _isProcessing = false);
      context.pop();
    }
  }
}
