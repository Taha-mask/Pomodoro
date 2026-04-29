import 'package:flutter/material.dart';
import 'package:pomodoro/core/theme/app_colors.dart';

class StepButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final Color color;

  const StepButton({
    super.key,
    required this.icon,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final active = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: active ? color.withValues(alpha: 0.1) : Colors.transparent,
          shape: BoxShape.circle,
          border: Border.all(
            color: active ? color.withValues(alpha: 0.35) : c.divider,
          ),
        ),
        child: Icon(
          icon,
          color: active ? color : c.textSecondary.withValues(alpha: 0.35),
          size: 20,
        ),
      ),
    );
  }
}
