import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pomodoro/core/theme/app_colors.dart';
import 'package:pomodoro/core/widgets/circular_timer.dart';
import 'package:pomodoro/core/widgets/control_buttons.dart';
import 'package:pomodoro/core/widgets/minute_picker.dart';
import 'package:pomodoro/features/timer/domain/phase.dart';
import 'package:pomodoro/features/timer/presentation/cubit/timer_cubit.dart';
import 'package:pomodoro/features/timer/presentation/cubit/timer_state.dart';

const _quotes = [
  "Still sitting there? The work won't do itself.",
  "Your future self is watching you procrastinate. Disappointing.",
  "Even your phone battery works harder than you right now.",
  "25 minutes. Even a goldfish can focus longer.",
  "Less scrolling. More doing. Revolutionary, I know.",
  "Stop pretending 'getting ready to work' counts as work.",
  "You've been 'about to start' for 20 minutes. Impressive.",
  "Your to-do list is judging you. And losing respect fast.",
  "The internet will still be there after. Focus.",
  "Your competition isn't on a break. Just saying.",
  "Tick tock. That deadline isn't moving.",
  "Coffee's getting cold. Let's go, genius.",
];

class WorkTab extends StatefulWidget {
  const WorkTab({super.key});

  @override
  State<WorkTab> createState() => _WorkTabState();
}

class _WorkTabState extends State<WorkTab> {
  late final String _quote;

  @override
  void initState() {
    super.initState();
    _quote = _quotes[Random().nextInt(_quotes.length)];
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TimerCubit, TimerState>(
      builder: (context, state) {
        final cubit = context.read<TimerCubit>();
        final isActive = state.currentPhase == Phase.work;
        final canStart = state.currentPhase != Phase.breakTime;
        final c = AppColors.of(context);

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
          child: Column(
            children: [
              // ── Snarky motivational quote (only when idle) ───────────
              if (state.currentPhase == Phase.idle) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppAccent.work.withValues(alpha: 0.07),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppAccent.work.withValues(alpha: 0.15),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Text('💬', style: TextStyle(fontSize: 16)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _quote,
                          style: TextStyle(
                            color: c.textSecondary,
                            fontSize: 13,
                            fontStyle: FontStyle.italic,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ] else
                const SizedBox(height: 8),

              // ── Timer ─────────────────────────────────────────────────
              CircularTimer(
                timeDisplay: isActive ? state.timeDisplay : _fmt(state.workMinutes),
                progress: isActive ? state.progress : 0,
                color: AppAccent.work,
                isActive: isActive,
                isPaused: isActive && state.isPaused,
                sublabel: isActive
                    ? 'Cycle ${state.currentCycle} of ${state.totalCycles}'
                    : null,
              ),

              const SizedBox(height: 28),

              // ── Task field (idle only) ────────────────────────────────
              if (state.currentPhase == Phase.idle) ...[
                _TaskField(value: state.taskName, onChanged: cubit.setTaskName, c: c),
                const SizedBox(height: 20),
              ],

              // ── Duration picker ───────────────────────────────────────
              if (!state.isRunning || !isActive) ...[
                MinutePicker(
                  label: 'Work duration',
                  minutes: state.workMinutes,
                  onChanged: cubit.setWorkMinutes,
                  color: AppAccent.work,
                  enabled: state.currentPhase == Phase.idle,
                ),
                const SizedBox(height: 28),
              ] else
                const SizedBox(height: 28),

              // ── Controls ──────────────────────────────────────────────
              ControlButtons(
                isRunning: state.isRunning && isActive,
                currentPhase: state.currentPhase,
                onStart: canStart ? cubit.startSession : null,
                onPause: cubit.pause,
                onReset: cubit.reset,
                color: AppAccent.work,
              ),
            ],
          ),
        );
      },
    );
  }

  String _fmt(int m) => '${m.toString().padLeft(2, '0')}:00';
}

class _TaskField extends StatefulWidget {
  final String? value;
  final ValueChanged<String> onChanged;
  final AppColors c;

  const _TaskField({this.value, required this.onChanged, required this.c});

  @override
  State<_TaskField> createState() => _TaskFieldState();
}

class _TaskFieldState extends State<_TaskField> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.value ?? '');
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.c;
    return TextField(
      controller: _ctrl,
      onChanged: widget.onChanged,
      style: TextStyle(color: c.textPrimary, fontSize: 15),
      maxLength: 80,
      decoration: InputDecoration(
        hintText: 'Task name (optional)',
        hintStyle: TextStyle(color: c.textSecondary, fontSize: 14),
        counterText: '',
        prefixIcon: Icon(Icons.task_alt_outlined, color: c.textSecondary, size: 20),
        filled: true,
        fillColor: c.inputFill,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: c.divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: c.divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppAccent.work, width: 1.5),
        ),
      ),
    );
  }
}
