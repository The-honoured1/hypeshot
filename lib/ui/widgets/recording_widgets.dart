import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme.dart';

/// Animated recording indicator bars — uses accent coral color
class RecordingWave extends StatelessWidget {
  const RecordingWave({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 14,
      width: 28,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(4, (index) {
          return Container(
            width: 2.5,
            decoration: BoxDecoration(
              color: AppTheme.accentSecondary.withOpacity(0.9),
              borderRadius: BorderRadius.circular(2),
            ),
          )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .scaleY(
                begin: 0.3,
                end: 1.0,
                duration: Duration(milliseconds: 400 + (index * 120)),
                curve: Curves.easeInOut,
              );
        }),
      ),
    );
  }
}

/// Recording status pill — compact "REC" or "STANDBY"
class StatusPill extends StatelessWidget {
  final bool isRecording;
  const StatusPill({super.key, required this.isRecording});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isRecording
            ? AppTheme.accentSecondary.withOpacity(0.15)
            : AppTheme.bgCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isRecording
              ? AppTheme.accentSecondary.withOpacity(0.4)
              : Colors.white.withOpacity(0.06),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isRecording) const RecordingWave() else Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.textMuted,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            isRecording ? 'REC' : 'IDLE',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
              color: isRecording ? AppTheme.accentSecondary : AppTheme.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

/// Large animated capture button with gradient ring
class CaptureButton extends StatefulWidget {
  final bool isRecording;
  final VoidCallback onTap;
  const CaptureButton({super.key, required this.isRecording, required this.onTap});

  @override
  State<CaptureButton> createState() => _CaptureButtonState();
}

class _CaptureButtonState extends State<CaptureButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    if (widget.isRecording) _pulseController.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(CaptureButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isRecording && !_pulseController.isAnimating) {
      _pulseController.repeat(reverse: true);
    } else if (!widget.isRecording && _pulseController.isAnimating) {
      _pulseController.stop();
      _pulseController.reset();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _pulseController,
        builder: (context, child) {
          final pulseVal = widget.isRecording ? _pulseController.value : 0.0;
          return Container(
            width: 100 + (pulseVal * 8),
            height: 100 + (pulseVal * 8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: widget.isRecording
                  ? SweepGradient(
                      colors: [
                        AppTheme.accentPrimary,
                        AppTheme.accentSecondary,
                        AppTheme.accentPrimary,
                      ],
                    )
                  : null,
              border: widget.isRecording
                  ? null
                  : Border.all(
                      color: AppTheme.accentPrimary.withOpacity(0.3),
                      width: 2,
                    ),
            ),
            child: Container(
              margin: EdgeInsets.all(widget.isRecording ? 3 : 0),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.isRecording
                    ? AppTheme.bgDeep
                    : Colors.transparent,
              ),
              child: Center(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: widget.isRecording ? 32 : 48,
                  height: widget.isRecording ? 32 : 48,
                  decoration: BoxDecoration(
                    shape: widget.isRecording ? BoxShape.rectangle : BoxShape.circle,
                    borderRadius: widget.isRecording ? BorderRadius.circular(8) : null,
                    gradient: AppTheme.brandGradient,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
