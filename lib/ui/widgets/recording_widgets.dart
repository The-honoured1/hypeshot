import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme.dart';

class HypeMeter extends StatelessWidget {
  final double level; // 0.0 to 1.0
  const HypeMeter({super.key, required this.level});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'HYPE LEVEL',
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.5),
            ),
            Text(
              '${(level * 100).toInt()}%',
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: AppTheme.secondaryNeon),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Stack(
          children: [
            Container(
              height: 4,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white10,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            AnimatedContainer(
              duration: 1.seconds,
              height: 4,
              width: MediaQuery.of(context).size.width * level * 0.8,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2),
                gradient: const LinearGradient(
                  colors: [AppTheme.primaryNeon, AppTheme.secondaryNeon],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.secondaryNeon.withOpacity(0.5),
                    blurRadius: 10,
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class RecordingWave extends StatelessWidget {
  const RecordingWave({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 20,
      width: 40,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(5, (index) {
          return Container(
            width: 3,
            decoration: BoxDecoration(
              color: AppTheme.secondaryNeon,
              borderRadius: BorderRadius.circular(2),
            ),
          ).animate(onPlay: (c) => c.repeat(reverse: true))
           .scaleY(
             begin: 0.3, 
             end: 1.0, 
             duration: Duration(milliseconds: 300 + (index * 100)),
             curve: Curves.easeInOut,
           );
        }),
      ),
    );
  }
}
