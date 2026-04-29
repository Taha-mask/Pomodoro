import 'package:flutter/material.dart';
import 'package:pomodoro/core/theme/app_colors.dart';
import 'package:pomodoro/features/timer/domain/phase.dart';

class CycleProgress extends StatelessWidget {
  final int currentCycle;
  final int totalCycles;
  final Phase currentPhase;

  const CycleProgress({
    super.key,
    required this.currentCycle,
    required this.totalCycles,
    required this.currentPhase,
  });

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      alignment: WrapAlignment.center,
      children: List.generate(totalCycles, (i) {
        final num = i + 1;
        final isDone = num < currentCycle;
        final isCurrent = num == currentCycle;
        final isBreak = isCurrent && currentPhase == Phase.breakTime;

        final Color activeColor;
        final Color bg;
        final Color border;
        final Widget child;

        if (isDone) {
          bg = AppAccent.work.withValues(alpha: 0.12);
          border = AppAccent.work.withValues(alpha: 0.5);
          child = Icon(Icons.check_rounded, color: AppAccent.work, size: 16);
        } else if (isCurrent) {
          activeColor = isBreak ? AppAccent.breakColor : AppAccent.work;
          bg = activeColor.withValues(alpha: 0.12);
          border = activeColor;
          child = Text(
            '$num',
            style: TextStyle(
              color: activeColor,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          );
        } else {
          bg = Colors.transparent;
          border = c.divider;
          child = Text(
            '$num',
            style: TextStyle(color: c.textSecondary, fontSize: 13),
          );
        }

        return Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: bg,
            shape: BoxShape.circle,
            border: Border.all(color: border, width: isCurrent ? 2 : 1),
          ),
          alignment: Alignment.center,
          child: child,
        );
      }),
    );
  }
}
