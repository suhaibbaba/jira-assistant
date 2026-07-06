import 'package:flutter/material.dart';
import 'package:triage/theme/app_colors.dart';

class AppTypography {
  static const heading = TextStyle(
      fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.text);

  static const appBarTitle = TextStyle(fontSize: 14, fontWeight: FontWeight.w600);

  static const sectionTitle = TextStyle(fontSize: 14, fontWeight: FontWeight.w700);

  static const toolbarTitle = TextStyle(fontSize: 13, fontWeight: FontWeight.w600);

  static const bannerTitle = TextStyle(
      color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700);

  static const dialogTitle = TextStyle(fontSize: 16, fontWeight: FontWeight.w700);

  static const overline = TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.4,
      color: AppColors.text3);

  static const overlineSmall = TextStyle(
      fontSize: 10,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.4,
      color: AppColors.text3);

  static const detailLabel = TextStyle(
      fontSize: 10,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.3,
      color: AppColors.text3);

  static const body = TextStyle(fontSize: 13);

  static const cardSummary = TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w500,
      height: 1.35,
      color: AppColors.text);

  static const bodyLong =
      TextStyle(fontSize: 12, height: 1.45, color: AppColors.textBody);

  static const rowLabel = TextStyle(fontSize: 12);

  static const bodySecondary = TextStyle(fontSize: 12, color: AppColors.text2);

  static const caption = TextStyle(fontSize: 10, color: AppColors.text3);

  static const rowHint = TextStyle(fontSize: 10, color: AppColors.text2);

  static const mono = TextStyle(
      fontFamily: 'monospace',
      fontSize: 10,
      fontWeight: FontWeight.w600,
      color: AppColors.accent);

  static const buttonLabel = TextStyle(
      color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13);

  static const buttonLabelSecondary = TextStyle(
      color: AppColors.text, fontSize: 12, fontWeight: FontWeight.w600);
}
