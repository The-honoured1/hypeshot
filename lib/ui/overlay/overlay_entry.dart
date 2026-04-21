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
    Future.delayed(const Duration(milliseconds: 100), () {
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
        child: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: _isFlashing ? Colors.white : const Color(0xFF141416),
            border: Border.all(
              color: _isFlashing ? Colors.white : const Color(0xFFFF3B30),
              width: 2,
            ),
            borderRadius: BorderRadius.circular(25),
          ),
          child: Center(
            child: Icon(
              LucideIcons.zap,
              size: 24,
              color: _isFlashing ? Colors.black : const Color(0xFFFF3B30),
            ),
          ),
        ),
      ),
    );
  }
}
