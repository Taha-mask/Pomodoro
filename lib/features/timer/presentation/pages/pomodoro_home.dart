import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pomodoro/core/theme/app_colors.dart';
import 'package:pomodoro/features/cycles/presentation/tabs/cycles_tab.dart';
import 'package:pomodoro/features/timer/presentation/cubit/timer_cubit.dart';
import 'package:pomodoro/features/timer/presentation/cubit/timer_state.dart';
import 'package:pomodoro/features/timer/presentation/tabs/break_tab.dart';
import 'package:pomodoro/features/timer/presentation/tabs/work_tab.dart';

class PomodoroHome extends StatelessWidget {
  const PomodoroHome({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TimerCubit, TimerState>(
      listenWhen: (prev, curr) =>
          // Phase completed
          (curr.phaseCompletedInfo != null && prev.phaseCompletedInfo == null) ||
          // All cycles done
          (curr.sessionCompleted && !prev.sessionCompleted),
      listener: (context, state) {
        if (state.phaseCompletedInfo != null) {
          _showPhaseCompletedDialog(context, state);
        } else if (state.sessionCompleted) {
          _showSessionDoneDialog(context, state.totalCycles);
          context.read<TimerCubit>().acknowledgeCompletion();
        }
      },
      builder: (context, state) {
        final cubit = context.read<TimerCubit>();
        final c = AppColors.of(context);

        return Scaffold(
          backgroundColor: c.background,
          body: SafeArea(
            child: Column(
              children: [
                // ── Header ──────────────────────────────────────────
                Container(
                  color: c.surface,
                  padding: const EdgeInsets.fromLTRB(20, 14, 12, 14),
                  child: Row(
                    children: [
                      Text(
                        'Pomodoro Timer',
                        style: TextStyle(
                          color: c.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const Spacer(),
                      if (state.currentCycle > 0)
                        Container(
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: state.phaseColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${state.currentCycle} / ${state.totalCycles}',
                            style: TextStyle(
                              color: state.phaseColor,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      // Theme toggle
                      IconButton(
                        onPressed: cubit.toggleTheme,
                        icon: Icon(
                          state.themeMode == ThemeMode.dark
                              ? Icons.light_mode_outlined
                              : Icons.dark_mode_outlined,
                          color: c.textSecondary,
                          size: 22,
                        ),
                        tooltip: state.themeMode == ThemeMode.dark
                            ? 'Light mode'
                            : 'Dark mode',
                      ),
                    ],
                  ),
                ),

                // ── Top Tab Bar ──────────────────────────────────────
                Container(
                  color: c.surface,
                  child: Row(
                    children: [
                      _TabItem(
                        label: 'Work',
                        index: 0,
                        current: state.currentTab,
                        color: AppAccent.work,
                        c: c,
                        onTap: () => cubit.onTabChanged(0),
                      ),
                      _TabItem(
                        label: 'Break',
                        index: 1,
                        current: state.currentTab,
                        color: AppAccent.breakColor,
                        c: c,
                        onTap: () => cubit.onTabChanged(1),
                      ),
                      _TabItem(
                        label: 'Cycles',
                        index: 2,
                        current: state.currentTab,
                        color: AppAccent.cycles,
                        c: c,
                        onTap: () => cubit.onTabChanged(2),
                      ),
                    ],
                  ),
                ),

                // ── Content ─────────────────────────────────────────
                Expanded(
                  child: IndexedStack(
                    index: state.currentTab,
                    children: const [WorkTab(), BreakTab(), CyclesTab()],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── Phase-end modal ──────────────────────────────────────────────────────
  void _showPhaseCompletedDialog(BuildContext context, TimerState state) {
    final info = state.phaseCompletedInfo!;
    final cubit = context.read<TimerCubit>();
    final color = info.isWork ? AppAccent.work : AppAccent.breakColor;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _PhaseCompletedDialog(
        info: info,
        color: color,
        hasSoundPath: state.soundPath != null,
        onStopSound: cubit.stopSound,
        onContinue: () {
          Navigator.pop(context);
          cubit.continueSession();
        },
      ),
    );
  }

  // ── All-done modal ───────────────────────────────────────────────────────
  void _showSessionDoneDialog(BuildContext context, int totalCycles) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text(
          '🏆 Session Complete!',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'You actually finished $totalCycles full cycles.\n'
          'Go touch some grass — you\'ve earned it.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Thanks, I guess'),
          ),
        ],
      ),
    );
  }
}

// ── Phase completed dialog ────────────────────────────────────────────────────
class _PhaseCompletedDialog extends StatefulWidget {
  final PhaseCompletedInfo info;
  final Color color;
  final bool hasSoundPath;
  final Future<void> Function() onStopSound;
  final VoidCallback onContinue;

  const _PhaseCompletedDialog({
    required this.info,
    required this.color,
    required this.hasSoundPath,
    required this.onStopSound,
    required this.onContinue,
  });

  @override
  State<_PhaseCompletedDialog> createState() => _PhaseCompletedDialogState();
}

class _PhaseCompletedDialogState extends State<_PhaseCompletedDialog> {
  bool _soundStopped = false;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final info = widget.info;
    final isWork = info.isWork;

    final title = isWork ? '🎯 Work Session Done!' : '⏰ Break\'s Over!';
    final subtitle = isWork
        ? (info.cycleNumber >= info.totalCycles
            ? 'Last cycle complete. You\'re done!'
            : 'Not bad. Break time — don\'t get too comfortable.')
        : 'Okay, the vacation\'s over. Back to work.';

    final nextLabel = isWork
        ? (info.cycleNumber >= info.totalCycles ? 'Wrap Up' : 'Start Break')
        : 'Back to Work';

    return AlertDialog(
      backgroundColor: c.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(
        title,
        style: TextStyle(
          color: c.textPrimary,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            subtitle,
            style: TextStyle(color: c.textSecondary, fontSize: 14, height: 1.4),
          ),
          const SizedBox(height: 16),
          // ── Stats ─────────────────────────────────────────────────────
          _StatRow(
            icon: Icons.timer_outlined,
            label: 'Duration',
            value: '${info.durationMin} min',
            color: widget.color,
            c: c,
          ),
          if (info.taskName != null && info.taskName!.isNotEmpty)
            _StatRow(
              icon: Icons.task_alt_outlined,
              label: 'Task',
              value: info.taskName!,
              color: widget.color,
              c: c,
            ),
          _StatRow(
            icon: Icons.repeat_rounded,
            label: 'Cycle',
            value: '${info.cycleNumber} of ${info.totalCycles}',
            color: widget.color,
            c: c,
          ),
          _StatRow(
            icon: Icons.check_circle_outline,
            label: 'Phase',
            value: isWork ? 'Work' : 'Break',
            color: widget.color,
            c: c,
          ),

          // ── Stop sound button ──────────────────────────────────────
          if (widget.hasSoundPath) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _soundStopped
                    ? null
                    : () async {
                        await widget.onStopSound();
                        setState(() => _soundStopped = true);
                      },
                icon: Icon(
                  _soundStopped ? Icons.volume_off : Icons.stop_circle_outlined,
                  size: 18,
                ),
                label: Text(_soundStopped ? 'Sound stopped' : 'Stop sound'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: _soundStopped ? c.textSecondary : Colors.red[400],
                  side: BorderSide(
                    color: _soundStopped
                        ? c.divider
                        : Colors.red.withValues(alpha: 0.4),
                  ),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: widget.onContinue,
          style: TextButton.styleFrom(
            backgroundColor: widget.color,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
          ),
          child: Text(nextLabel, style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}

class _StatRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final AppColors c;

  const _StatRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.c,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(color: c.textSecondary, fontSize: 13),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              color: c.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// ── Top tab item ──────────────────────────────────────────────────────────────
class _TabItem extends StatelessWidget {
  final String label;
  final int index;
  final int current;
  final Color color;
  final AppColors c;
  final VoidCallback onTap;

  const _TabItem({
    required this.label,
    required this.index,
    required this.current,
    required this.color,
    required this.c,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = index == current;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                label,
                style: TextStyle(
                  color: isSelected ? color : c.textSecondary,
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                ),
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 3,
              decoration: BoxDecoration(
                color: isSelected ? color : Colors.transparent,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(3)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
