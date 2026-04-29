import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pomodoro/core/theme/app_colors.dart';
import 'package:pomodoro/features/cycles/presentation/widgets/cycle_progress.dart';
import 'package:pomodoro/features/cycles/presentation/widgets/cycle_selector.dart';
import 'package:pomodoro/features/history/presentation/history_sheet.dart';
import 'package:pomodoro/features/sound/presentation/widgets/sound_picker_card.dart';
import 'package:pomodoro/features/timer/domain/phase.dart';
import 'package:pomodoro/features/timer/presentation/cubit/timer_cubit.dart';
import 'package:pomodoro/features/timer/presentation/cubit/timer_state.dart';

class CyclesTab extends StatelessWidget {
  const CyclesTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TimerCubit, TimerState>(
      builder: (context, state) {
        final cubit = context.read<TimerCubit>();
        final c = AppColors.of(context);

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
          child: Column(
            children: [
              // ── Cycle count selector ──────────────────────────────────
              _Card(
                c: c,
                child: CycleSelector(
                  value: state.totalCycles,
                  onChanged:
                      state.currentPhase == Phase.idle ? cubit.setTotalCycles : null,
                ),
              ),

              const SizedBox(height: 16),

              // ── Current progress ──────────────────────────────────────
              if (state.currentCycle > 0)
                _Card(
                  c: c,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Progress',
                        style: TextStyle(
                          color: c.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 14),
                      CycleProgress(
                        currentCycle: state.currentCycle,
                        totalCycles: state.totalCycles,
                        currentPhase: state.currentPhase,
                      ),
                    ],
                  ),
                ),

              if (state.currentCycle > 0) const SizedBox(height: 16),

              // ── Sound picker ──────────────────────────────────────────
              SoundPickerCard(
                soundPath: state.soundPath,
                onPick: cubit.pickSound,
                onPreview: cubit.previewSound,
                onClear: cubit.clearSound,
              ),

              const SizedBox(height: 16),

              // ── History ───────────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _showHistory(context, cubit),
                  icon: const Icon(Icons.history, size: 18),
                  label: const Text('Session History'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppAccent.cycles,
                    side: BorderSide(
                        color: AppAccent.cycles.withValues(alpha: 0.4)),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),

              // ── Info hint (idle only) ─────────────────────────────────
              if (state.currentPhase == Phase.idle) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppAccent.cycles.withValues(alpha: 0.07),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                        color: AppAccent.cycles.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline,
                          color: AppAccent.cycles, size: 18),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'One cycle = Work + Break.\nStart from the Work tab.',
                          style: TextStyle(
                            color: AppAccent.cycles,
                            fontSize: 13,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  void _showHistory(BuildContext context, TimerCubit cubit) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => HistorySheet(
        loadHistory: cubit.getHistory,
        clearHistory: cubit.clearHistory,
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final Widget child;
  final AppColors c;

  const _Card({required this.child, required this.c});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: c.divider),
      ),
      child: child,
    );
  }
}
