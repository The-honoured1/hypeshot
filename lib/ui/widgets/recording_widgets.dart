import 'package:flutter/material.dart';
import '../../core/theme.dart';

/// Studio Recording Wave — Simple solid bars
class RecordingWave extends StatelessWidget {
  const RecordingWave({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 12,
      width: 24,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(3, (index) {
          return TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.3, end: 1.0),
            duration: Duration(milliseconds: 400 + (index * 100)),
            builder: (context, value, child) {
              return Container(
                width: 3,
                height: 12 * value,
                decoration: const BoxDecoration(
                  color: AppTheme.accentSignal,
                ),
              );
            },
          );
        }),
      ),
    );
  }
}

/// Studio Status Pill — Matte badge
class StatusPill extends StatelessWidget {
  final bool isRecording;
  const StatusPill({super.key, required this.isRecording});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isRecording ? AppTheme.accentSignal.withOpacity(0.2) : AppTheme.bgElevated,
        border: Border.all(
          color: isRecording ? AppTheme.accentSignal : AppTheme.borderThin,
        ),
        borderRadius: BorderRadius.circular(2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isRecording ? AppTheme.accentSignal : AppTheme.accentAmber,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            isRecording ? 'LIVE' : 'STANDBY',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w900,
              color: isRecording ? AppTheme.accentSignal : AppTheme.textMain,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}

/// Studio Capture Button — Matte, functional, NO conflict between shape and borderRadius
class CaptureButton extends StatelessWidget {
  final bool isRecording;
  final VoidCallback onTap;
  const CaptureButton({super.key, required this.isRecording, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          color: AppTheme.bgElevated,
          border: Border.all(color: AppTheme.borderThin, width: 2),
          borderRadius: BorderRadius.circular(60), // Static radius for circular look
        ),
        padding: const EdgeInsets.all(12),
        child: Container(
          decoration: BoxDecoration(
            color: isRecording ? AppTheme.accentSignal : AppTheme.actionWhite,
            borderRadius: BorderRadius.circular(isRecording ? 12 : 48), // Transition between rect and circle using radius only
          ),
          child: Center(
            child: Icon(
              isRecording ? Icons.stop : Icons.fiber_manual_record,
              color: isRecording ? Colors.white : Colors.black,
              size: 40,
            ),
          ),
        ),
      ),
    );
  }
}
