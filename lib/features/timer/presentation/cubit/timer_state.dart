import 'package:flutter/material.dart';
import 'package:pomodoro/core/theme/app_colors.dart';
import 'package:pomodoro/features/timer/domain/phase.dart';

// ── Completion info shown in the end-of-phase modal ─────────────────────────
class PhaseCompletedInfo {
  final bool isWork;
  final int durationMin;
  final String? taskName;
  final int cycleNumber;
  final int totalCycles;

  const PhaseCompletedInfo({
    required this.isWork,
    required this.durationMin,
    this.taskName,
    required this.cycleNumber,
    required this.totalCycles,
  });
}

// ── Timer state ───────────────────────────────────────────────────────────────
class TimerState {
  final int workMinutes;
  final int breakMinutes;
  final int totalCycles;
  final Phase currentPhase;
  final bool isRunning;
  final int currentCycle;
  final int remainingSeconds;
  final int currentTab;
  final String? soundPath;
  final bool sessionCompleted;
  final String? taskName;
  final ThemeMode themeMode;
  final PhaseCompletedInfo? phaseCompletedInfo;

  const TimerState({
    this.workMinutes = 25,
    this.breakMinutes = 5,
    this.totalCycles = 4,
    this.currentPhase = Phase.idle,
    this.isRunning = false,
    this.currentCycle = 0,
    this.remainingSeconds = 25 * 60,
    this.currentTab = 0,
    this.soundPath,
    this.sessionCompleted = false,
    this.taskName,
    this.themeMode = ThemeMode.light,
    this.phaseCompletedInfo,
  });

  bool get isPaused => !isRunning && currentPhase != Phase.idle;

  String get timeDisplay {
    final m = remainingSeconds ~/ 60;
    final s = remainingSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  double get progress {
    final total = currentPhase == Phase.work
        ? workMinutes * 60
        : currentPhase == Phase.breakTime
            ? breakMinutes * 60
            : workMinutes * 60;
    if (total == 0) return 0;
    return 1 - (remainingSeconds / total);
  }

  Color get phaseColor =>
      currentPhase == Phase.breakTime ? AppAccent.breakColor : AppAccent.work;

  TimerState copyWith({
    int? workMinutes,
    int? breakMinutes,
    int? totalCycles,
    Phase? currentPhase,
    bool? isRunning,
    int? currentCycle,
    int? remainingSeconds,
    int? currentTab,
    String? soundPath,
    bool clearSoundPath = false,
    bool? sessionCompleted,
    String? taskName,
    bool clearTaskName = false,
    ThemeMode? themeMode,
    PhaseCompletedInfo? phaseCompletedInfo,
    bool clearPhaseCompleted = false,
  }) {
    return TimerState(
      workMinutes: workMinutes ?? this.workMinutes,
      breakMinutes: breakMinutes ?? this.breakMinutes,
      totalCycles: totalCycles ?? this.totalCycles,
      currentPhase: currentPhase ?? this.currentPhase,
      isRunning: isRunning ?? this.isRunning,
      currentCycle: currentCycle ?? this.currentCycle,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      currentTab: currentTab ?? this.currentTab,
      soundPath: clearSoundPath ? null : soundPath ?? this.soundPath,
      sessionCompleted: sessionCompleted ?? this.sessionCompleted,
      taskName: clearTaskName ? null : taskName ?? this.taskName,
      themeMode: themeMode ?? this.themeMode,
      phaseCompletedInfo:
          clearPhaseCompleted ? null : phaseCompletedInfo ?? this.phaseCompletedInfo,
    );
  }
}
