import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';

@pragma("vm:entry-point")
void overlayMain() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: OverlayControlWidget(),
  ));
}

class OverlayControlWidget extends StatefulWidget {
  const OverlayControlWidget({super.key});

  @override
  State<OverlayControlWidget> createState() => _OverlayControlWidgetState();
}

class _OverlayControlWidgetState extends State<OverlayControlWidget> {
  bool _isExpanded = false;
  bool _isRecording = true; // Overlay assumes recording is on when shown
  bool _isPaused = false;
  
  List<String> _enabledActions = ['capture', 'pause', 'screenshot', 'stop'];
  double _opacity = 1.0;
  double _scale = 1.0;

  @override
  void initState() {
    super.initState();
    _loadSettings();
    FlutterOverlayWindow.overlayListener.listen((event) {
       if (event == "REFRESH") {
         _loadSettings();
       }
    });
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _enabledActions = prefs.getStringList('fb_enabled_actions') ?? ['capture', 'pause', 'screenshot', 'stop'];
      _opacity = prefs.getDouble('fb_opacity') ?? 1.0;
      _scale = prefs.getDouble('fb_size_scale') ?? 1.0;
    });
  }

  void _onAction(String action) {
    if (action == 'pause') {
      setState(() => _isPaused = true);
      FlutterOverlayWindow.shareData("PAUSE_BUFFER");
    } else if (action == 'resume') {
      setState(() => _isPaused = false);
      FlutterOverlayWindow.shareData("RESUME_BUFFER");
    } else if (action == 'capture') {
      FlutterOverlayWindow.shareData("CAPTURE_HIGHLIGHT");
    } else if (action == 'screenshot') {
      FlutterOverlayWindow.shareData("TAKE_SCREENSHOT");
    } else if (action == 'stop') {
      FlutterOverlayWindow.shareData("STOP_BUFFER");
    }
    
    // Collapse after action if it was a capture/screenshot
    if (action == 'capture' || action == 'screenshot') {
      setState(() => _isExpanded = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Transform.scale(
        scale: _scale,
        child: Opacity(
          opacity: _opacity,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: const Color(0xFF141416),
              borderRadius: BorderRadius.circular(_isExpanded ? 12 : 25),
              border: Border.all(color: const Color(0xFF2C2C2E), width: 1),
            ),
            child: _isExpanded ? _buildDock() : _buildHandle(),
          ),
        ),
      ),
    );
  }

  Widget _buildHandle() {
    return GestureDetector(
      onTap: () => setState(() => _isExpanded = true),
      child: Container(
        width: 42,
        height: 42,
        decoration: const BoxDecoration(shape: BoxShape.circle),
        child: const Center(
          child: Icon(LucideIcons.chevronLeft, color: Colors.white, size: 20),
        ),
      ),
    );
  }

  Widget _buildDock() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(LucideIcons.chevronRight, color: Color(0xFF6E6E73), size: 16),
          onPressed: () => setState(() => _isExpanded = false),
        ),
        if (_enabledActions.contains('capture'))
          _actionIcon(LucideIcons.zap, const Color(0xFFFF3B30), () => _onAction('capture')),
        if (_enabledActions.contains('pause'))
          _isPaused 
            ? _actionIcon(LucideIcons.play, const Color(0xFFFFA500), () => _onAction('resume'))
            : _actionIcon(LucideIcons.pause, const Color(0xFFFFA500), () => _onAction('pause')),
        if (_enabledActions.contains('screenshot'))
          _actionIcon(LucideIcons.camera, Colors.white, () => _onAction('screenshot')),
        if (_enabledActions.contains('stop'))
          _actionIcon(LucideIcons.square, const Color(0xFF6E6E73), () => _onAction('stop')),
      ],
    );
  }

  Widget _actionIcon(IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFF1C1C1E),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }
}
