import 'package:flutter/material.dart';
import 'package:triage/theme/app_theme.dart';

/// Primary action button — blue, rounded, bold label.
/// Disabled (onTap == null): 30% alpha + not-allowed cursor.
class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool fullWidth;

  const AppButton({
    super.key,
    required this.label,
    required this.onTap,
    this.fullWidth = true,
  });

  bool get _disabled => onTap == null;

  @override
  Widget build(BuildContext context) {
    final btn = MouseRegion(
      cursor: _disabled
          ? SystemMouseCursors.forbidden // 🚫 not-allowed
          : SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 18),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: _disabled
                ? AppColors.accent.withValues(alpha: 0.3)
                : AppColors.accent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(label,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 13)),
        ),
      ),
    );
    return fullWidth ? SizedBox(width: double.infinity, child: btn) : btn;
  }
}

/// Secondary button — light gray, used next to a primary action.
class AppSecondaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;

  const AppSecondaryButton(
      {super.key, required this.label, required this.onTap});

  bool get _disabled => onTap == null;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor:
          _disabled ? SystemMouseCursors.forbidden : SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 18),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: _disabled
                ? const Color(0xFFF0F0F2).withValues(alpha: 0.3)
                : const Color(0xFFF0F0F2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(label,
              style: TextStyle(
                  color: _disabled
                      ? AppColors.text.withValues(alpha: 0.3)
                      : AppColors.text,
                  fontSize: 12,
                  fontWeight: FontWeight.w600)),
        ),
      ),
    );
  }
}

/// Small square toolbar icon button (settings, add, digest, ...).
class AppIconButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  final bool highlighted;

  const AppIconButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.highlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(7),
        child: Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: highlighted
                ? AppColors.accentSoft
                : Colors.black.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(7),
          ),
          child: Icon(icon,
              size: 16,
              color: highlighted ? AppColors.accent : AppColors.text2),
        ),
      ),
    );
  }
}
