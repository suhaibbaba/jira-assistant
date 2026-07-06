import 'package:flutter/material.dart';
import 'package:triage/theme/app_theme.dart';

class AppStepper extends StatelessWidget {
  final String value;
  final bool enabled;
  final VoidCallback onMinus;
  final VoidCallback onPlus;

  const AppStepper({
    super.key,
    required this.value,
    required this.enabled,
    required this.onMinus,
    required this.onPlus,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : 0.4,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.separator),
          borderRadius: AppRadius.br6,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _btn('−', enabled ? onMinus : null),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.x10, vertical: 3),
              child: Text(value,
                  style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w600)),
            ),
            _btn('+', enabled ? onPlus : null),
          ],
        ),
      ),
    );
  }

  Widget _btn(String s, VoidCallback? onTap) => GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.x8, vertical: 3),
          color: Colors.black.withValues(alpha: 0.03),
          child: Text(s,
              style: const TextStyle(fontSize: 13, color: AppColors.text2)),
        ),
      );
}
