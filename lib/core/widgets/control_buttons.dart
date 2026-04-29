import 'package:flutter/material.dart';
import 'package:pomodoro/core/theme/app_colors.dart';
import 'package:pomodoro/features/timer/domain/phase.dart';

class ControlButtons extends StatelessWidget {
  final bool isRunning;
  final Phase currentPhase;
  final VoidCallback? onStart;
  final VoidCallback onPause;
  final VoidCallback onReset;
  final Color color;

  const ControlButtons({
    super.key,
    required this.isRunning,
    required this.currentPhase,
    this.onStart,
    required this.onPause,
    required this.onReset,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _PillButton(
          isRunning: isRunning,
          onStart: onStart,
          onPause: onPause,
          color: color,
        ),
        if (currentPhase != Phase.idle) ...[
          const SizedBox(height: 16),
          GestureDetector(
            onTap: onReset,
            child: Text(
              'Reset session',
              style: TextStyle(
                color: c.textSecondary,
                fontSize: 13,
                decoration: TextDecoration.underline,
                decorationColor: c.textSecondary,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _PillButton extends StatelessWidget {
  final bool isRunning;
  final VoidCallback? onStart;
  final VoidCallback onPause;
  final Color color;

  const _PillButton({
    required this.isRunning,
    required this.onStart,
    required this.onPause,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = isRunning || onStart != null;
    final label = isRunning ? 'Pause' : 'Start';
    final icon = isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded;

    return SizedBox(
      width: double.infinity,
      height: 58,
      child: AnimatedOpacity(
        opacity: enabled ? 1.0 : 0.4,
        duration: const Duration(milliseconds: 200),
        child: ElevatedButton.icon(
          onPressed: enabled ? (isRunning ? onPause : onStart) : null,
          icon: Icon(icon, size: 24),
          label: Text(
            label,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            foregroundColor: Colors.white,
            disabledBackgroundColor: color.withValues(alpha: 0.35),
            disabledForegroundColor: Colors.white60,
            elevation: 0,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
        ),
      ),
    );
  }
}
