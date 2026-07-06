import 'package:flutter/material.dart';
import 'package:triage/theme/app_theme.dart';

Future<T?> showAppDialog<T>({
  required BuildContext context,
  required String title,
  required Widget content,
  List<Widget> actions = const [],
}) {
  return showDialog<T>(
    context: context,
    builder: (ctx) => AlertDialog(
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.br14),
      title: Text(title, style: AppTypography.dialogTitle),
      content: content,
      actions: actions,
    ),
  );
}

class DialogHint extends StatelessWidget {
  final String text;
  const DialogHint(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(text, style: AppTypography.bodySecondary);
  }
}
