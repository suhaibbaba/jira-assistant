import 'package:flutter/material.dart';
import 'package:triage/l10n/gen/app_localizations.dart';
import 'package:triage/models/ticket.dart';
import 'package:triage/models/attention_item.dart';
import 'package:triage/theme/app_theme.dart';
import 'package:triage/widgets/ui/ui.dart';

class TicketCard extends StatefulWidget {
  final Ticket ticket;
  final VoidCallback onOpenInBrowser;
  final VoidCallback onTapDetail;
  final bool showDragHandle;
  final bool showAgePill;
  final AttentionMeta? attentionMeta;
  final VoidCallback? onMarkDone;

  const TicketCard({
    super.key,
    required this.ticket,
    required this.onOpenInBrowser,
    required this.onTapDetail,
    this.showDragHandle = true,
    this.showAgePill = false,
    this.attentionMeta,
    this.onMarkDone,
  });

  @override
  State<TicketCard> createState() => _TicketCardState();
}

class _TicketCardState extends State<TicketCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final t = widget.ticket;
    final accentBorder = t.isEstimateRequest
        ? AppColors.status['Needs Attention']!
        : AppColors.priorityColor(t.priority);

    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTapDetail,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: AppRadius.br10,
            border: Border.all(color: AppColors.separator, width: 0.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: _hover ? 0.10 : 0.04),
                blurRadius: _hover ? 10 : 2,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: AppRadius.br10,
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(width: 3, color: accentBorder),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(9, 10, 12, 10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (widget.showDragHandle)
                            const Padding(
                              padding: EdgeInsets.only(right: 9, top: 2),
                              child: Text('⋮⋮',
                                  style: TextStyle(
                                      color: AppColors.dragHandle,
                                      fontSize: 13)),
                            ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _topRow(t),
                                const SizedBox(height: 4),
                                Text(t.summary,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTypography.cardSummary),
                                const SizedBox(height: 6),
                                _metaRow(t),
                                if (widget.attentionMeta != null) ...[
                                  const SizedBox(height: 8),
                                  _attentionRow(widget.attentionMeta!),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _topRow(Ticket t) {
    return Row(
      children: [
        KeyChip(label: t.key, onTap: widget.onOpenInBrowser),
        const SizedBox(width: 4),
        InkWell(
          onTap: widget.onOpenInBrowser,
          borderRadius: AppRadius.br4,
          child: const Padding(
            padding: EdgeInsets.all(2),
            child: Icon(Icons.open_in_new, size: 13, color: AppColors.accent),
          ),
        ),
        const SizedBox(width: 7),
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
              color: AppColors.priorityColor(t.priority), shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(t.priority,
            style: const TextStyle(
                fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.text2)),
        const Spacer(),
        if (widget.showAgePill && t.timeInStatus != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
            decoration: BoxDecoration(
              color: AppColors.aging.withValues(alpha: 0.14),
              borderRadius: AppRadius.br4,
            ),
            child: Text(
                AppLocalizations.of(context).cardAgePill(t.ageLabel, t.status),
                style: const TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: AppColors.aging)),
          )
        else
          Text(t.updatedLabel,
              style: const TextStyle(fontSize: 10, color: AppColors.text3)),
      ],
    );
  }

  Widget _metaRow(Ticket t) {
    final l10n = AppLocalizations.of(context);
    return Row(
      children: [
        Flexible(
          child: Text(
            t.issueType.isNotEmpty
                ? l10n.cardProjectWithType(t.projectName, t.issueType)
                : l10n.cardProjectOnly(t.projectName),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 10, color: AppColors.text2),
          ),
        ),
        const Spacer(),
        if (t.assigneeName != null)
          Container(
            width: 18,
            height: 18,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                color: AppColors.avatarColor(t.assigneeName!),
                shape: BoxShape.circle),
            child: Text(t.assigneeInitials,
                style: const TextStyle(
                    fontSize: 8, fontWeight: FontWeight.w600, color: Colors.white)),
          ),
      ],
    );
  }

  Widget _attentionRow(AttentionMeta meta) {
    final l10n = AppLocalizations.of(context);
    const c = AppColors.statusNeedsAttention;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.08),
        borderRadius: AppRadius.br7,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              l10n.cardAttentionFrom(meta.requestedBy, meta.agoLabel),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontSize: 11, fontWeight: FontWeight.w600, color: c),
            ),
          ),
          if (widget.onMarkDone != null)
            InkWell(
              onTap: widget.onMarkDone,
              borderRadius: AppRadius.br6,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: const BoxDecoration(
                  color: AppColors.success,
                  borderRadius: AppRadius.br6,
                ),
                child: Text(l10n.cardMarkDone,
                    style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Colors.white)),
              ),
            ),
        ],
      ),
    );
  }
}
