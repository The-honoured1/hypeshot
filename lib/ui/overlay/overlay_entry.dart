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
    setState(() => _isFlashing = true);
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) setState(() => _isFlashing = false);
    });
    FlutterOverlayWindow.shareData("CAPTURE_HIGHLIGHT");
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: GestureDetector(
        onTap: _onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: 54,
          height: 54,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _isFlashing ? Colors.white : const Color(0xFF8B5CF6).withOpacity(0.9), // accentPrimary
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF8B5CF6).withOpacity(_isFlashing ? 0.8 : 0.3),
                blurRadius: _isFlashing ? 20 : 10,
                spreadRadius: 2,
              )
            ],
          ),
          child: Center(
            child: Icon(
              LucideIcons.zap,
              size: 26,
              color: _isFlashing ? Colors.black : Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
