import 'package:flutter/material.dart';
import '../models/ticket.dart';
import '../theme/app_theme.dart';

/// The detail popover shown when a card is tapped.
class TicketDetailDialog extends StatelessWidget {
  final Ticket ticket;
  final VoidCallback onOpenInBrowser;
  final VoidCallback? onDismissEstimate;

  const TicketDetailDialog({
    super.key,
    required this.ticket,
    required this.onOpenInBrowser,
    this.onDismissEstimate,
  });

  @override
  Widget build(BuildContext context) {
    final t = ticket;
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      InkWell(
                        onTap: onOpenInBrowser,
                        child: Container(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                              color: AppColors.accentSoft,
                              borderRadius: BorderRadius.circular(4)),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(t.key,
                                  style: const TextStyle(
                                      fontFamily: 'monospace',
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.accent)),
                              const SizedBox(width: 4),
                              const Icon(Icons.open_in_new,
                                  size: 12, color: AppColors.accent),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 9,
                        height: 9,
                        decoration: BoxDecoration(
                            color: AppColors.priorityColor(t.priority),
                            shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 4),
                      Text(t.priority,
                          style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.text2)),
                      const Spacer(),
                      _statusTag(t.status),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(t.summary,
                      style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          height: 1.3)),
                ],
              ),
            ),
            const Divider(height: 0.5, color: AppColors.separator),
            // Body
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (t.description.isNotEmpty) ...[
                    _label('Description'),
                    const SizedBox(height: 3),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 160),
                      child: SingleChildScrollView(
                        child: Text(t.description,
                            style: const TextStyle(
                                fontSize: 12,
                                height: 1.45,
                                color: Color(0xFF3A3A3C))),
                      ),
                    ),
                    const SizedBox(height: 14),
                  ],
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _field('Assignee', t.assigneeName ?? 'Unassigned'),
                      const SizedBox(width: 24),
                      _field('Project', '📁 ${t.projectName}'),
                      const SizedBox(width: 24),
                      _field('In status', t.ageLabel.isEmpty ? '—' : t.ageLabel),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _field('Type',
                      t.issueType.isEmpty ? '—' : '🐞 ${t.issueType}'),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _primaryBtn('Open in Jira  ↗', onOpenInBrowser),
                      ),
                      if (t.isEstimateRequest && onDismissEstimate != null) ...[
                        const SizedBox(width: 10),
                        _secondaryBtn('Done', () {
                          onDismissEstimate!();
                          Navigator.of(context).pop();
                        }),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusTag(String status) {
    final c = AppColors.statusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
          color: c.withOpacity(0.12), borderRadius: BorderRadius.circular(7)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(color: c, shape: BoxShape.circle)),
          const SizedBox(width: 5),
          Text(status,
              style: TextStyle(
                  fontSize: 11, fontWeight: FontWeight.w600, color: c)),
        ],
      ),
    );
  }

  Widget _label(String s) => Text(s.toUpperCase(),
      style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
          color: AppColors.text3));

  Widget _field(String k, String v) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _label(k),
          const SizedBox(height: 3),
          Text(v,
              style: const TextStyle(
                  fontSize: 12, color: Color(0xFF3A3A3C), height: 1.3)),
        ],
      );

  Widget _primaryBtn(String label, VoidCallback onTap) => GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          alignment: Alignment.center,
          decoration: BoxDecoration(
              color: AppColors.accent, borderRadius: BorderRadius.circular(8)),
          child: Text(label,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600)),
        ),
      );

  Widget _secondaryBtn(String label, VoidCallback onTap) => GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 18),
          alignment: Alignment.center,
          decoration: BoxDecoration(
              color: const Color(0xFFF0F0F2),
              borderRadius: BorderRadius.circular(8)),
          child: Text(label,
              style: const TextStyle(
                  color: AppColors.text,
                  fontSize: 12,
                  fontWeight: FontWeight.w600)),
        ),
      );
}
