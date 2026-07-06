import 'package:flutter/material.dart';
import 'package:triage/theme/app_theme.dart';

class KeyChip extends StatefulWidget {
  final String label;
  final VoidCallback onTap;
  final bool large;
  final bool showOpenIcon;

  const KeyChip({
    super.key,
    required this.label,
    required this.onTap,
    this.large = false,
    this.showOpenIcon = false,
  });

  @override
  State<KeyChip> createState() => _KeyChipState();
}

class _KeyChipState extends State<KeyChip> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final text = Text(
      widget.label,
      style: TextStyle(
        fontFamily: 'monospace',
        fontSize: widget.large ? 11 : 10,
        fontWeight: FontWeight.w600,
        color: AppColors.accent,
        decoration: _hover && !widget.large
            ? TextDecoration.underline
            : TextDecoration.none,
        decorationColor: AppColors.accent,
      ),
    );

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.x6,
              vertical: widget.large ? AppSpacing.x2 : 1),
          decoration: const BoxDecoration(
            color: AppColors.accentSoft,
            borderRadius: AppRadius.br4,
          ),
          child: widget.showOpenIcon
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    text,
                    const SizedBox(width: AppSpacing.x4),
                    const Icon(Icons.open_in_new,
                        size: 12, color: AppColors.accent),
                  ],
                )
              : text,
        ),
      ),
    );
  }
}
