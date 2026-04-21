import 'package:flutter/material.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:lucide_icons/lucide_icons.dart';

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
  bool _isFlashing = false;

  void _onTap() async {
    // Visual feedback for capture
    setState(() => _isFlashing = true);
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) setState(() => _isFlashing = false);
    });

    // Send a message to the main app instance to trigger a capture
    FlutterOverlayWindow.shareData("CAPTURE_HIGHLIGHT");
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: GestureDetector(
        onTap: _onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _isFlashing ? Colors.white : const Color(0xFF121216).withOpacity(0.9), // AppTheme.surface
            border: Border.all(
              color: _isFlashing ? Colors.transparent : Colors.white.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: Center(
            child: Icon(
              LucideIcons.focus,
              size: 24,
              color: _isFlashing ? Colors.black : Colors.white70,
            ),
          ),
        ),
      ),
    );
  }
}
