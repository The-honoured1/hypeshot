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
      _errorMessage = "EMPTY DATA";
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
        _errorMessage = "MERGE FAILED";
      });
    }
  }

  void _initEditor(String path) {
    _controller = VideoEditorController.file(
      File(path),
      minDuration: const Duration(seconds: 1),
      maxDuration: const Duration(seconds: 60),
    )..initialize().then((_) {
      if (mounted) setState(() {
        _initialized = true;
        _isProcessing = false;
      });
    }).catchError((e) {
      if (mounted) setState(() {
        _isProcessing = false;
        _errorMessage = "FILE ERROR";
      });
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
                    _buildMinimalDock(),
                    if (_isProcessing) _buildProcessingOverlay(),
                  ],
                )
              : const Center(child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.textDim)),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(LucideIcons.alertCircle, size: 40, color: AppTheme.accentSignal),
          const SizedBox(height: 16),
          Text(_errorMessage, style: const TextStyle(fontWeight: FontWeight.w900, color: AppTheme.textDim)),
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
              HypeButton(
                label: 'EXPORT',
                onTap: _exportVideo,
                isPrimary: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMinimalDock() {
    return Positioned(
      bottom: 24, left: 24, right: 24,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 48,
            child: TrimSlider(
              controller: _controller,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _tool(LucideIcons.scissors, 'TRIM'),
              _tool(LucideIcons.type, 'CAPTION'),
              _tool(LucideIcons.zoomIn, 'ZOOM'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _tool(IconData icon, String label) {
    return Column(
      children: [
        Icon(icon, size: 20, color: AppTheme.textMain),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w900, letterSpacing: 1)),
      ],
    );
  }

  Widget _buildProcessingOverlay() {
    return Container(
      color: Colors.black87,
      child: const Center(
        child: CircularProgressIndicator(color: AppTheme.accentAmber),
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
