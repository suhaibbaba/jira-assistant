import 'package:flutter/material.dart';

/// Centralised colors so the UI matches the approved Apple-style sketch.
class AppColors {
  static const accent = Color(0xFF007AFF);
  static const accentSoft = Color(0x1F007AFF);

  static const bgSidebar = Color(0xFFF6F6F8);
  static const bgContent = Color(0xFFFAFAFB);
  static const card = Colors.white;

  static const text = Color(0xFF1D1D1F);
  static const text2 = Color(0xFF86868B);
  static const text3 = Color(0xFFAEAEB2);
  static const separator = Color(0x14000000);

  static const aging = Color(0xFFFF9500);

  static const Map<String, Color> status = {
    'New': Color(0xFFFF3B30),
    'Blocked': Color(0xFFFF453A),
    'Need Clarification': Color(0xFFAF52DE),
    'In Progress': Color(0xFF007AFF),
    'Review': Color(0xFF5856D6),
    'Needs Attention': Color(0xFFFF9F0A),
  };

  static const Map<String, Color> priority = {
    'Highest': Color(0xFFFF3B30),
    'High': Color(0xFFFF9500),
    'Medium': Color(0xFFFFCC00),
    'Low': Color(0xFF34C759),
    'Lowest': Color(0xFF5AC8FA),
    'None': Color(0xFFAEAEB2),
  };

  static Color statusColor(String s) => status[s] ?? text3;
  static Color priorityColor(String p) => priority[p] ?? text3;

  /// Deterministic avatar color from a name.
  static Color avatarColor(String seed) {
    const palette = [
      Color(0xFFFF9500),
      Color(0xFF34C759),
      Color(0xFF5856D6),
      Color(0xFF007AFF),
      Color(0xFFAF52DE),
      Color(0xFFFF2D55),
    ];
    final h = seed.codeUnits.fold<int>(0, (a, b) => a + b);
    return palette[h % palette.length];
  }
}

ThemeData buildAppTheme() {
  return ThemeData(
    useMaterial3: true,
    fontFamily: '.SF Pro Text',
    scaffoldBackgroundColor: AppColors.bgContent,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.accent,
      primary: AppColors.accent,
    ),
    splashFactory: NoSplash.splashFactory,
    highlightColor: Colors.transparent,
  );
}
