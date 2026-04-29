import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pomodoro/core/data/local/db_helper.dart';
import 'package:pomodoro/core/di/service_locator.dart';
import 'package:pomodoro/core/theme/app_colors.dart';
import 'package:pomodoro/features/timer/presentation/cubit/timer_cubit.dart';
import 'package:pomodoro/features/timer/presentation/cubit/timer_state.dart';
import 'package:pomodoro/features/timer/presentation/pages/pomodoro_home.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  DbHelper.initFfi();
  setupDependencies();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(
    BlocProvider(
      create: (_) => sl<TimerCubit>(),
      child: const PomodoroApp(),
    ),
  );
}

class PomodoroApp extends StatelessWidget {
  const PomodoroApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TimerCubit, TimerState>(
      buildWhen: (prev, curr) => prev.themeMode != curr.themeMode,
      builder: (context, state) {
        return MaterialApp(
          title: 'Pomodoro Timer',
          debugShowCheckedModeBanner: false,
          themeMode: state.themeMode,
          theme: _buildTheme(AppColors.light),
          darkTheme: _buildTheme(AppColors.dark),
          home: const PomodoroHome(),
        );
      },
    );
  }

  ThemeData _buildTheme(AppColors c) {
    return ThemeData(
      useMaterial3: true,
      brightness: c.brightness,
      scaffoldBackgroundColor: c.background,
      colorScheme: ColorScheme(
        brightness: c.brightness,
        primary: AppAccent.work,
        onPrimary: Colors.white,
        secondary: AppAccent.breakColor,
        onSecondary: Colors.white,
        error: Colors.red,
        onError: Colors.white,
        surface: c.surface,
        onSurface: c.textPrimary,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: c.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: TextStyle(
          color: c.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w800,
        ),
        iconTheme: IconThemeData(color: c.textPrimary),
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarBrightness: c.brightness,
          statusBarIconBrightness:
              c.isDark ? Brightness.light : Brightness.dark,
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: c.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }
}
