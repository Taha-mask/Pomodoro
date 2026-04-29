import 'dart:math';
import 'package:flutter/material.dart';
import 'package:pomodoro/core/theme/app_colors.dart';

class CircularTimer extends StatelessWidget {
  final String timeDisplay;
  final double progress;
  final Color color;
  final bool isActive;
  final bool isPaused;
  final String? sublabel;

  const CircularTimer({
    super.key,
    required this.timeDisplay,
    required this.progress,
    required this.color,
    required this.isActive,
    this.isPaused = false,
    this.sublabel,
  });

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final screenWidth = MediaQuery.sizeOf(context).width;
    final size = (screenWidth * 0.72).clamp(220.0, 300.0);
    final fontSize = size * 0.225;

    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _RingPainter(progress: progress, color: color, c: c),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                timeDisplay,
                style: TextStyle(
                  color: isActive ? color : c.textSecondary,
                  fontSize: fontSize,
                  fontWeight: FontWeight.w300,
                  letterSpacing: 2,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
              const SizedBox(height: 4),
              if (isPaused)
                _Chip(label: '⏸  Paused', textColor: c.textSecondary,
                    bgColor: c.textSecondary.withValues(alpha: 0.1))
              else if (isActive && sublabel != null)
                _Chip(label: sublabel!, textColor: color,
                    bgColor: color.withValues(alpha: 0.1))
              else if (!isActive)
                _Chip(label: 'Press Start', textColor: c.textSecondary,
                    bgColor: c.textSecondary.withValues(alpha: 0.08)),
            ],
          ),
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final Color textColor;
  final Color bgColor;

  const _Chip({required this.label, required this.textColor, required this.bgColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final Color color;
  final AppColors c;

  _RingPainter({required this.progress, required this.color, required this.c});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 12;
    const stroke = 10.0;

    // Glow ring
    canvas.drawCircle(center, radius, Paint()
      ..color = color.withValues(alpha: 0.06)
      ..strokeWidth = stroke + 8
      ..style = PaintingStyle.stroke);

    // Track
    canvas.drawCircle(center, radius, Paint()
      ..color = c.divider
      ..strokeWidth = stroke
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round);

    // Progress arc
    if (progress > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -pi / 2,
        2 * pi * progress,
        false,
        Paint()
          ..color = color
          ..strokeWidth = stroke
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.progress != progress || old.c != c;
}
