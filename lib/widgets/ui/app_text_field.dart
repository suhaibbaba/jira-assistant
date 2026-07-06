import 'package:flutter/material.dart';
import 'package:triage/theme/app_theme.dart';

InputDecoration appInputDecoration({String? label, String? hint}) {
  return InputDecoration(
    labelText: label,
    hintText: hint,
    labelStyle: const TextStyle(fontSize: 12, color: AppColors.text2),
    hintStyle: const TextStyle(fontSize: 12, color: AppColors.text3),
    isDense: true,
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    enabledBorder: const OutlineInputBorder(
      borderRadius: AppRadius.br8,
      borderSide: BorderSide(color: AppColors.fieldBorder, width: 1.5),
    ),
    focusedBorder: const OutlineInputBorder(
      borderRadius: AppRadius.br8,
      borderSide: BorderSide(color: AppColors.accent, width: 1.5),
    ),
    border: const OutlineInputBorder(borderRadius: AppRadius.br8),
  );
}

class AppTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final bool labelAbove;
  final bool obscure;
  final bool autofocus;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;
  final ValueChanged<String>? onSubmitted;

  const AppTextField({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.labelAbove = false,
    this.obscure = false,
    this.autofocus = false,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.none,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    final field = TextField(
      controller: controller,
      obscureText: obscure,
      autofocus: autofocus,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      onSubmitted: onSubmitted,
      style: const TextStyle(fontSize: 13),
      decoration: appInputDecoration(
        label: labelAbove ? null : label,
        hint: hint,
      ),
    );

    if (!labelAbove || label == null) return field;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label!,
            style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.fieldLabel)),
        const SizedBox(height: 4),
        field,
      ],
    );
  }
}
