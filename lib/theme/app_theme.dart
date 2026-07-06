import 'package:flutter/material.dart';
import 'package:triage/theme/app_colors.dart';

export 'package:triage/theme/app_colors.dart';
export 'package:triage/theme/app_dimens.dart';
export 'package:triage/theme/app_typography.dart';

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
    inputDecorationTheme: const InputDecorationTheme(
      hintStyle: TextStyle(color: AppColors.text3),
      labelStyle: TextStyle(color: AppColors.text2),
    ),
  );
}
