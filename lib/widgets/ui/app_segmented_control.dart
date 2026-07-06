import 'package:flutter/material.dart';
import 'package:triage/theme/app_theme.dart';

class AppSegmentedControl extends StatelessWidget {
  final List<String> options;
  final int selectedIndex;
  final ValueChanged<int> onSelect;
  final bool expanded;

  const AppSegmentedControl({
    super.key,
    required this.options,
    required this.selectedIndex,
    required this.onSelect,
    this.expanded = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.05),
          borderRadius: AppRadius.br7),
      padding: expanded ? null : const EdgeInsets.all(AppSpacing.x2),
      child: Row(
        mainAxisSize: expanded ? MainAxisSize.max : MainAxisSize.min,
        children: [
          for (var i = 0; i < options.length; i++)
            expanded ? Expanded(child: _option(i)) : _option(i),
        ],
      ),
    );
  }

  Widget _option(int i) {
    final sel = selectedIndex == i;
    return GestureDetector(
      onTap: () => onSelect(i),
      child: Container(
        margin: expanded ? const EdgeInsets.all(AppSpacing.x2) : null,
        padding: expanded
            ? const EdgeInsets.symmetric(vertical: AppSpacing.x4)
            : const EdgeInsets.symmetric(
                horizontal: 11, vertical: AppSpacing.x4),
        alignment: expanded ? Alignment.center : null,
        decoration: BoxDecoration(
          color: sel ? Colors.white : Colors.transparent,
          borderRadius: AppRadius.br5,
          boxShadow: sel
              ? [
                  BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 2)
                ]
              : null,
        ),
        child: Text(options[i],
            style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: sel ? AppColors.text : AppColors.text2)),
      ),
    );
  }
}
