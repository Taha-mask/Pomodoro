import 'package:flutter/material.dart';

// ── Phase accent colors (same in both modes) ─────────────────────────────────
abstract final class AppAccent {
  static const work = Color(0xFF4361EE);
  static const breakColor = Color(0xFF06B6A2);
  static const cycles = Color(0xFFFF6B6B);
}

// ── Theme-aware surface/text colors ──────────────────────────────────────────
class AppColors {
  final Color background;
  final Color surface;
  final Color card;
  final Color textPrimary;
  final Color textSecondary;
  final Color divider;
  final Color inputFill;
  final Brightness brightness;

  const AppColors._({
    required this.background,
    required this.surface,
    required this.card,
    required this.textPrimary,
    required this.textSecondary,
    required this.divider,
    required this.inputFill,
    required this.brightness,
  });

  static const light = AppColors._(
    background: Color(0xFFF4F6FF),
    surface: Color(0xFFFFFFFF),
    card: Color(0xFFF0F3FF),
    textPrimary: Color(0xFF1A1A2E),
    textSecondary: Color(0xFF8892B0),
    divider: Color(0xFFE8EAFF),
    inputFill: Color(0xFFFFFFFF),
    brightness: Brightness.light,
  );

  static const dark = AppColors._(
    background: Color(0xFF0D0F1A),
    surface: Color(0xFF151828),
    card: Color(0xFF1E2235),
    textPrimary: Color(0xFFE8EEFF),
    textSecondary: Color(0xFF6B7A9E),
    divider: Color(0xFF252840),
    inputFill: Color(0xFF1E2235),
    brightness: Brightness.dark,
  );

  bool get isDark => brightness == Brightness.dark;

  static AppColors of(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? dark : light;
}
