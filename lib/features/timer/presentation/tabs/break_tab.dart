import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pomodoro/core/theme/app_colors.dart';
import 'package:pomodoro/core/widgets/circular_timer.dart';
import 'package:pomodoro/core/widgets/control_buttons.dart';
import 'package:pomodoro/core/widgets/minute_picker.dart';
import 'package:pomodoro/features/timer/domain/phase.dart';
import 'package:pomodoro/features/timer/presentation/cubit/timer_cubit.dart';
import 'package:pomodoro/features/timer/presentation/cubit/timer_state.dart';

class BreakTab extends StatelessWidget {
  const BreakTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TimerCubit, TimerState>(
      builder: (context, state) {
        final cubit = context.read<TimerCubit>();
        final isActive = state.currentPhase == Phase.breakTime;
        final c = AppColors.of(context);

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
          child: Column(
            children: [
              const SizedBox(height: 8),

              // ── Timer ─────────────────────────────────────────────────
              CircularTimer(
                timeDisplay:
                    isActive ? state.timeDisplay : _fmt(state.breakMinutes),
                progress: isActive ? state.progress : 0,
                color: AppAccent.breakColor,
                isActive: isActive,
                isPaused: isActive && state.isPaused,
                sublabel: isActive
                    ? 'Cycle ${state.currentCycle} of ${state.totalCycles}'
                    : null,
              ),

              const SizedBox(height: 32),

              // ── Duration picker ───────────────────────────────────────
              if (!state.isRunning || !isActive) ...[
                MinutePicker(
                  label: 'Break duration',
                  minutes: state.breakMinutes,
                  onChanged: cubit.setBreakMinutes,
                  color: AppAccent.breakColor,
                  enabled: state.currentPhase == Phase.idle,
                ),
                const SizedBox(height: 20),
              ],

              // ── Info box when work is running ─────────────────────────
              if (state.currentPhase == Phase.work) ...[
                _InfoBox(
                  icon: Icons.info_outline,
                  text: 'Break starts automatically once work ends. '
                      'Go back to Work tab.',
                  color: AppAccent.breakColor,
                  c: c,
                ),
                const SizedBox(height: 20),
              ],

              const SizedBox(height: 8),

              // ── Controls ──────────────────────────────────────────────
              ControlButtons(
                isRunning: state.isRunning && isActive,
                currentPhase: state.currentPhase,
                onStart: isActive ? cubit.startSession : null,
                onPause: cubit.pause,
                onReset: cubit.reset,
                color: AppAccent.breakColor,
              ),
            ],
          ),
        );
      },
    );
  }

  String _fmt(int m) => '${m.toString().padLeft(2, '0')}:00';
}

class _InfoBox extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;
  final AppColors c;

  const _InfoBox({
    required this.icon,
    required this.text,
    required this.color,
    required this.c,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: color, fontSize: 13, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}
