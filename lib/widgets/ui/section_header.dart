import 'package:flutter/material.dart';

/// Board/digest section header: colored dot + title + count badge + trailing.
class SectionHeader extends StatelessWidget {
  final String title;
  final int count;
  final Color color;
  final String? trailing;

  const SectionHeader({
    super.key,
    required this.title,
    required this.count,
    required this.color,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
            width: 9,
            height: 9,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Text(title,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 1),
          decoration:
              BoxDecoration(color: color, borderRadius: BorderRadius.circular(9)),
          child: Text('$count',
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w700)),
        ),
        const Spacer(),
        if (trailing != null)
          Text(trailing!,
              style: const TextStyle(fontSize: 10, color: Color(0xFFAEAEB2))),
      ],
    );
  }
}
