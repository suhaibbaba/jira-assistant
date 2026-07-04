import 'package:flutter/material.dart';
import 'package:triage/theme/app_theme.dart';

/// Standard dialog shell: rounded 14, consistent title style, actions row.
/// Use for every dialog in the app so they all look alike.
Future<T?> showAppDialog<T>({
  required BuildContext context,
  required String title,
  required Widget content,
  List<Widget> actions = const [],
}) {
  return showDialog<T>(
    context: context,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      title: Text(title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
      content: content,
      actions: actions,
    ),
  );
}

/// Small helper for the muted explanatory line at the top of dialogs.
class DialogHint extends StatelessWidget {
  final String text;
  const DialogHint(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(text,
        style: const TextStyle(fontSize: 12, color: AppColors.text2));
  }
}
