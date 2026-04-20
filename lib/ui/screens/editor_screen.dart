import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_editor/video_editor.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme.dart';
import '../../services/share_service.dart';

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
    // Using a dummy path for now if none provided to prevent crashes during UI development
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
    
    // In a real app, we'd use _controller.file.path
    // For this demo, we'll simulate the export
    await Future.delayed(const Duration(seconds: 2));
    
    if (mounted) {
      setState(() => _isProcessing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('CLIP SAVED TO GALLERY! 🔥'),
          backgroundColor: AppTheme.primaryNeon,
        ),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('EDIT CLIP'),
        leading: IconButton(
          icon: const Icon(LucideIcons.x),
          onPressed: () => context.pop(),
        ),
        actions: [
          TextButton(
            onPressed: _isProcessing ? null : _exportVideo,
            child: Text(
              'EXPORT',
              style: TextStyle(
                color: _isProcessing ? Colors.grey : AppTheme.secondaryNeon,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: _controller.initialized
          ? Column(
              children: [
                Expanded(
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
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              shadows: [
                                Shadow(blurRadius: 10, color: Colors.black, offset: Offset(2, 2)),
                              ],
                            ),
                          ),
                        ),
                      AnimatedOpacity(
                        opacity: _controller.isPlaying ? 0 : 1,
                        duration: const Duration(milliseconds: 200),
                        child: GestureDetector(
                          onTap: () => _controller.video.play(),
                          child: Container(
                            width: 70,
                            height: 70,
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.5),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(LucideIcons.play, size: 40),
                          ),
                        ),
                      ),
                      if (_isProcessing)
                        Container(
                          color: Colors.black54,
                          child: const Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CircularProgressIndicator(color: AppTheme.primaryNeon),
                                SizedBox(height: 20),
                                Text('CRUNCHING PIXELS...', style: TextStyle(fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                _buildEditorTools(),
              ],
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildEditorTools() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          // Trim Slider
          SizedBox(
            height: 60,
            child: TrimSlider(
              controller: _controller,
            ),
          ),
          const SizedBox(height: 20),
          // Tool Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _toolItem(
                icon: LucideIcons.timer,
                label: 'SLOW MO',
                isActive: _isSlowMo,
                onTap: () => setState(() => _isSlowMo = !_isSlowMo),
              ),
              _toolItem(
                icon: LucideIcons.type,
                label: 'TEXT',
                isActive: _overlayText.isNotEmpty,
                onTap: () => _showTextInput(),
              ),
              _toolItem(
                icon: LucideIcons.maximize,
                label: 'ZOOM',
                isActive: false,
                onTap: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _toolItem({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isActive ? AppTheme.primaryNeon : Colors.transparent,
              shape: BoxShape.circle,
              border: Border.all(
                color: isActive ? AppTheme.primaryNeon : Colors.white24,
              ),
            ),
            child: Icon(
              icon,
              color: isActive ? Colors.white : Colors.white70,
              size: 24,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: isActive ? AppTheme.primaryNeon : Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  void _showTextInput() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      isScrollControlled: true,
      builder: (context) {
        String current = _overlayText;
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'TYPE SOMETHING LIT...',
                  border: InputBorder.none,
                ),
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                onChanged: (val) => current = val,
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _presetChip('CLUTCH'),
                  _presetChip('WTF'),
                  _presetChip('GG'),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  setState(() => _overlayText = current);
                  Navigator.pop(context);
                },
                child: const Text('ADD OVERLAY'),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _presetChip(String text) {
    return ActionChip(
      label: Text(text),
      backgroundColor: AppTheme.background,
      onPressed: () {
        setState(() => _overlayText = text);
        Navigator.pop(context);
      },
    );
  }
}
