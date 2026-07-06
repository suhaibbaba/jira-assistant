import 'package:flutter/material.dart';
import 'package:triage/l10n/gen/app_localizations.dart';
import 'package:triage/models/ticket.dart';
import 'package:triage/theme/app_theme.dart';
import 'package:triage/widgets/ui/ui.dart';

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
    final l10n = AppLocalizations.of(context);
    return Dialog(
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.br14),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      KeyChip(
                          label: t.key,
                          onTap: onOpenInBrowser,
                          large: true,
                          showOpenIcon: true),
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
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (t.description.isNotEmpty) ...[
                    _label(l10n.detailDescription),
                    const SizedBox(height: 3),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 160),
                      child: SingleChildScrollView(
                        child: Text(t.description,
                            style: AppTypography.bodyLong),
                      ),
                    ),
                    const SizedBox(height: 14),
                  ],
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _field(l10n.detailAssignee,
                          t.assigneeName ?? l10n.detailUnassigned),
                      const SizedBox(width: 24),
                      _field(l10n.detailProject,
                          l10n.detailProjectValue(t.projectName)),
                      const SizedBox(width: 24),
                      _field(l10n.detailInStatus,
                          t.ageLabel.isEmpty ? l10n.commonEmDash : t.ageLabel),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _field(
                      l10n.detailType,
                      t.issueType.isEmpty
                          ? l10n.commonEmDash
                          : l10n.detailTypeValue(t.issueType)),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child:
                            _primaryBtn(l10n.detailOpenInJira, onOpenInBrowser),
                      ),
                      if (t.isEstimateRequest && onDismissEstimate != null) ...[
                        const SizedBox(width: 10),
                        _secondaryBtn(l10n.commonDone, () {
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
          color: c.withValues(alpha: 0.12), borderRadius: AppRadius.br7),
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

  Widget _label(String s) =>
      Text(s.toUpperCase(), style: AppTypography.detailLabel);

  Widget _field(String k, String v) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _label(k),
          const SizedBox(height: 3),
          Text(v,
              style: const TextStyle(
                  fontSize: 12, color: AppColors.textBody, height: 1.3)),
        ],
      );

  Widget _primaryBtn(String label, VoidCallback onTap) => GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          alignment: Alignment.center,
          decoration: const BoxDecoration(
              color: AppColors.accent, borderRadius: AppRadius.br8),
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
          decoration: const BoxDecoration(
              color: AppColors.secondaryButtonBg,
              borderRadius: AppRadius.br8),
          child: Text(label, style: AppTypography.buttonLabelSecondary),
        ),
      );
}
