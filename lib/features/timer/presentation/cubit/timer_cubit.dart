import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pomodoro/core/data/local/db_helper.dart';
import 'package:pomodoro/core/result/api_result.dart';
import 'package:pomodoro/features/sound/domain/usecases/pick_sound_usecase.dart';
import 'package:pomodoro/features/sound/domain/usecases/play_sound_usecase.dart';
import 'package:pomodoro/features/sound/domain/usecases/stop_sound_usecase.dart';
import 'package:pomodoro/features/timer/domain/phase.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'timer_state.dart';

class TimerCubit extends Cubit<TimerState> {
  final PickSoundUseCase _pickSound;
  final PlaySoundUseCase _playSound;
  final StopSoundUseCase _stopSound;
  final DbHelper _db;

  Timer? _ticker;
  final _stopwatch = Stopwatch();
  int _phaseTotalSeconds = 25 * 60;

  TimerCubit({
    required PickSoundUseCase pickSound,
    required PlaySoundUseCase playSound,
    required StopSoundUseCase stopSound,
    required DbHelper db,
  })  : _pickSound = pickSound,
        _playSound = playSound,
        _stopSound = stopSound,
        _db = db,
        super(const TimerState()) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final work = await _db.getSetting('workMinutes');
    final brk = await _db.getSetting('breakMinutes');
    final cycles = await _db.getSetting('totalCycles');
    final sound = await _db.getSetting('soundPath');
    final theme = await _db.getSetting('themeMode');

    final workMin = work != null ? int.tryParse(work) ?? 25 : 25;
    final isDark = theme == 'dark';

    emit(state.copyWith(
      workMinutes: workMin,
      breakMinutes: brk != null ? int.tryParse(brk) ?? 5 : null,
      totalCycles: cycles != null ? int.tryParse(cycles) ?? 4 : null,
      soundPath: (sound != null && sound.isNotEmpty) ? sound : null,
      remainingSeconds: workMin * 60,
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
    ));
  }

  @override
  Future<void> close() {
    _ticker?.cancel();
    _stopwatch.stop();
    WakelockPlus.disable();
    return super.close();
  }

  // ── Settings ──────────────────────────────────────────────────────────────

  void setWorkMinutes(int minutes) {
    _db.setSetting('workMinutes', '$minutes');
    emit(state.copyWith(
      workMinutes: minutes,
      remainingSeconds: state.currentPhase == Phase.idle ? minutes * 60 : null,
    ));
  }

  void setBreakMinutes(int minutes) {
    _db.setSetting('breakMinutes', '$minutes');
    emit(state.copyWith(breakMinutes: minutes));
  }

  void setTotalCycles(int cycles) {
    _db.setSetting('totalCycles', '$cycles');
    emit(state.copyWith(totalCycles: cycles));
  }

  void setTaskName(String name) => emit(state.copyWith(taskName: name));

  void onTabChanged(int tab) => emit(state.copyWith(currentTab: tab));

  void acknowledgeCompletion() => emit(state.copyWith(sessionCompleted: false));

  void toggleTheme() {
    final next = state.themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    _db.setSetting('themeMode', next == ThemeMode.dark ? 'dark' : 'light');
    emit(state.copyWith(themeMode: next));
  }

  // ── Timer controls ────────────────────────────────────────────────────────

  void startSession() {
    if (state.isRunning) return;

    if (state.currentPhase == Phase.idle) {
      _phaseTotalSeconds = state.workMinutes * 60;
      _stopwatch.reset();
      emit(state.copyWith(
        currentPhase: Phase.work,
        currentCycle: 1,
        remainingSeconds: _phaseTotalSeconds,
        currentTab: 0,
      ));
    }

    _stopwatch.start();
    WakelockPlus.enable();
    emit(state.copyWith(isRunning: true));
    _runTimer();
  }

  void pause() {
    _ticker?.cancel();
    _stopwatch.stop();
    emit(state.copyWith(isRunning: false));
    WakelockPlus.disable();
  }

  void reset() {
    _ticker?.cancel();
    _stopwatch.stop();
    _stopwatch.reset();
    WakelockPlus.disable();
    emit(state.copyWith(
      isRunning: false,
      currentPhase: Phase.idle,
      currentCycle: 0,
      remainingSeconds: state.workMinutes * 60,
      clearTaskName: true,
      clearPhaseCompleted: true,
    ));
  }

  /// Called when user taps "Continue" in the phase-completed modal.
  void continueSession() {
    final wasWork = state.currentPhase == Phase.work;
    emit(state.copyWith(clearPhaseCompleted: true));

    if (wasWork) {
      if (state.currentCycle >= state.totalCycles) {
        emit(state.copyWith(
          isRunning: false,
          currentPhase: Phase.idle,
          currentCycle: 0,
          remainingSeconds: state.workMinutes * 60,
          sessionCompleted: true,
          clearTaskName: true,
        ));
      } else {
        _phaseTotalSeconds = state.breakMinutes * 60;
        _stopwatch.reset();
        _stopwatch.start();
        WakelockPlus.enable();
        emit(state.copyWith(
          isRunning: true,
          currentPhase: Phase.breakTime,
          remainingSeconds: _phaseTotalSeconds,
          currentTab: 1,
        ));
        _runTimer();
      }
    } else {
      _phaseTotalSeconds = state.workMinutes * 60;
      _stopwatch.reset();
      _stopwatch.start();
      WakelockPlus.enable();
      emit(state.copyWith(
        isRunning: true,
        currentPhase: Phase.work,
        currentCycle: state.currentCycle + 1,
        remainingSeconds: _phaseTotalSeconds,
        currentTab: 0,
      ));
      _runTimer();
    }
  }

  void _runTimer() {
    _ticker?.cancel();
    final total = _phaseTotalSeconds;
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      final remaining = total - _stopwatch.elapsed.inSeconds;
      if (remaining > 0) {
        emit(state.copyWith(remainingSeconds: remaining));
      } else {
        emit(state.copyWith(remainingSeconds: 0));
        _onPhaseComplete();
      }
    });
  }

  Future<void> _onPhaseComplete() async {
    _ticker?.cancel();
    _stopwatch.stop();
    WakelockPlus.disable();

    if (state.soundPath != null) _playSound(state.soundPath!);

    final isWork = state.currentPhase == Phase.work;
    await _db.addPomodoro(
      task: state.taskName,
      phase: isWork ? 'work' : 'break',
      durationMin: isWork ? state.workMinutes : state.breakMinutes,
    );

    emit(state.copyWith(
      isRunning: false,
      remainingSeconds: 0,
      phaseCompletedInfo: PhaseCompletedInfo(
        isWork: isWork,
        durationMin: isWork ? state.workMinutes : state.breakMinutes,
        taskName: state.taskName,
        cycleNumber: state.currentCycle,
        totalCycles: state.totalCycles,
      ),
    ));
  }

  // ── Sound ─────────────────────────────────────────────────────────────────

  Future<void> pickSound() async {
    final result = await _pickSound();
    if (result is ApiSuccess<String?> && result.data != null) {
      _db.setSetting('soundPath', result.data!);
      emit(state.copyWith(soundPath: result.data));
    }
  }

  Future<void> previewSound() async {
    if (state.soundPath != null) await _playSound(state.soundPath!);
  }

  Future<void> stopSound() => _stopSound();

  void clearSound() {
    _db.setSetting('soundPath', '');
    emit(state.copyWith(clearSoundPath: true));
  }

  // ── History ───────────────────────────────────────────────────────────────

  Future<List<PomodoroRecord>> getHistory() => _db.getRecent();

  Future<void> clearHistory() => _db.clearHistory();
}
