import 'package:flutter/material.dart';
import 'package:pomodoro/core/theme/app_colors.dart';
import 'package:pomodoro/core/widgets/step_button.dart';

class CycleSelector extends StatelessWidget {
  final int value;
  final ValueChanged<int>? onChanged;

  const CycleSelector({super.key, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final active = onChanged != null;

    return Column(
      children: [
        Text(
          'Number of cycles',
          style: TextStyle(
            color: c.textSecondary,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            StepButton(
              icon: Icons.remove,
              onTap: active && value > 1 ? () => onChanged!(value - 1) : null,
              color: AppAccent.cycles,
            ),
            const SizedBox(width: 24),
            Column(
              children: [
                Text(
                  '$value',
                  style: TextStyle(
                    color: active ? c.textPrimary : c.textSecondary,
                    fontSize: 72,
                    fontWeight: FontWeight.w200,
                    height: 1,
                  ),
                ),
                Text(
                  value == 1 ? 'cycle' : 'cycles',
                  style: TextStyle(color: c.textSecondary, fontSize: 14),
                ),
              ],
            ),
            const SizedBox(width: 24),
            StepButton(
              icon: Icons.add,
              onTap: active && value < 20 ? () => onChanged!(value + 1) : null,
              color: AppAccent.cycles,
            ),
          ],
        ),
        if (!active) ...[
          const SizedBox(height: 10),
          Text(
            'Cannot change during a session',
            style: TextStyle(color: c.textSecondary, fontSize: 12),
          ),
        ],
      ],
    );
  }
}
