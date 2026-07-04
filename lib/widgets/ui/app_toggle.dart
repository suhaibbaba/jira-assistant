import 'package:flutter/material.dart';
import 'package:triage/theme/app_theme.dart';

/// The green mini toggle used in the sidebar (projects, teammates)
/// and in Settings (aging rules).
class AppToggle extends StatelessWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;
  final double width;
  final double height;

  const AppToggle({
    super.key,
    required this.value,
    this.onChanged,
    this.width = 28,
    this.height = 17,
  });

  @override
  Widget build(BuildContext context) {
    final knob = height - 4;
    return GestureDetector(
      onTap: onChanged == null ? null : () => onChanged!(!value),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: value ? AppColors.priority['Low'] : Colors.black.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(height / 2),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 120),
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.all(2),
            width: knob,
            height: knob,
            decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: Color(0x33000000), blurRadius: 2),
                ]),
          ),
        ),
      ),
    );
  }
}
