import 'package:flutter/material.dart';

class AppColors {
  static const accent = Color(0xFF007AFF);
  static const accentSoft = Color(0x1F007AFF);

  static const bgSidebar = Color(0xFFF6F6F8);
  static const bgContent = Color(0xFFFAFAFB);
  static const card = Colors.white;
  static const surface = card;
  static const secondaryButtonBg = Color(0xFFF0F0F2);

  static const text = Color(0xFF1D1D1F);
  static const text2 = Color(0xFF86868B);
  static const text3 = Color(0xFFAEAEB2);
  static const textPrimary = text;
  static const textSecondary = text2;
  static const textTertiary = text3;

  static const textBody = Color(0xFF3A3A3C);

  static const fieldLabel = Color(0xFF374151);

  static const separator = Color(0x14000000);

  static const success = Color(0xFF34C759);
  static const warning = Color(0xFFFF9500);
  static const danger = Color(0xFFFF3B30);
  static const aging = warning;

  static const statusNew = danger;
  static const statusBlocked = Color(0xFFFF453A);
  static const statusNeedClarification = Color(0xFFAF52DE);
  static const statusInProgress = accent;
  static const statusReview = Color(0xFF5856D6);
  static const statusNeedsAttention = Color(0xFFFF9F0A);

  static const Map<String, Color> status = {
    'New': statusNew,
    'Blocked': statusBlocked,
    'Need Clarification': statusNeedClarification,
    'In Progress': statusInProgress,
    'Review': statusReview,
    'Needs Attention': statusNeedsAttention,
  };

  static const priorityHighest = danger;
  static const priorityHigh = warning;
  static const priorityMedium = Color(0xFFFFCC00);
  static const priorityLow = success;
  static const priorityLowest = Color(0xFF5AC8FA);
  static const priorityNone = text3;

  static const Map<String, Color> priority = {
    'Highest': priorityHighest,
    'High': priorityHigh,
    'Medium': priorityMedium,
    'Low': priorityLow,
    'Lowest': priorityLowest,
    'None': priorityNone,
  };

  static const offlineBannerBg = Color(0xFFFFF4E5);
  static const offlineBannerText = Color(0xFFB25E00);
  static const authBannerBg = Color(0xFFFDE7E9);
  static const authBannerText = Color(0xFFC0263A);
  static const errorSurface = Color(0xFFFEF2F2);
  static const errorBorder = Color(0xFFFECACA);
  static const errorText = Color(0xFFDC2626);

  static const dangerGradientEnd = Color(0xFFFF6259);
  static const warningGradientEnd = Color(0xFFFFB340);

  static const connectGradientTop = Color(0xFF0F172A);
  static const connectGradientBottom = Color(0xFF1E3A5F);
  static const fieldBorder = Color(0xFFE2E8F0);
  static const dragHandle = Color(0xFFD1D1D6);
  static const noteChipBg = Color(0x22FF9F0A);
  static const knobShadow = Color(0x33000000);

  static Color statusColor(String s) => status[s] ?? text3;
  static Color priorityColor(String p) => priority[p] ?? text3;

  static Color avatarColor(String seed) {
    const palette = [
      warning,
      success,
      statusReview,
      accent,
      statusNeedClarification,
      Color(0xFFFF2D55),
    ];
    final h = seed.codeUnits.fold<int>(0, (a, b) => a + b);
    return palette[h % palette.length];
  }
}
