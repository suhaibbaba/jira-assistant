import 'package:flutter/material.dart';
import '../models/ticket.dart';
import '../theme/app_theme.dart';

/// A single ticket card. The key text and the link icon both open the ticket
/// in the browser. Tapping elsewhere on the card opens the detail popup.
class TicketCard extends StatefulWidget {
  final Ticket ticket;
  final VoidCallback onOpenInBrowser;
  final VoidCallback onTapDetail;
  final bool showDragHandle;
  final bool showAgePill;
  final Widget? trailingExtra;

  const TicketCard({
    super.key,
    required this.ticket,
    required this.onOpenInBrowser,
    required this.onTapDetail,
    this.showDragHandle = true,
    this.showAgePill = false,
    this.trailingExtra,
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
        ? AppColors.status['Estimate Requested']!
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
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(10),
            border: Border(
              left: BorderSide(color: accentBorder, width: 3),
              top: const BorderSide(color: AppColors.separator, width: 0.5),
              right: const BorderSide(color: AppColors.separator, width: 0.5),
              bottom: const BorderSide(color: AppColors.separator, width: 0.5),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(_hover ? 0.10 : 0.04),
                blurRadius: _hover ? 10 : 2,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.showDragHandle)
                const Padding(
                  padding: EdgeInsets.only(right: 9, top: 2),
                  child: Text('⋮⋮',
                      style: TextStyle(color: Color(0xFFD1D1D6), fontSize: 13)),
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
                        style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            height: 1.35,
                            color: AppColors.text)),
                    const SizedBox(height: 6),
                    _metaRow(t),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _topRow(Ticket t) {
    return Row(
      children: [
        // Clickable ticket key → opens in browser
        _KeyChip(label: t.key, onTap: widget.onOpenInBrowser),
        const SizedBox(width: 4),
        // Link icon right after the key → also opens in browser
        InkWell(
          onTap: widget.onOpenInBrowser,
          borderRadius: BorderRadius.circular(4),
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
          _AgePill(label: '⏳ ${t.ageLabel} in ${t.status}')
        else
          Text(t.updatedLabel,
              style: const TextStyle(fontSize: 10, color: AppColors.text3)),
        if (widget.trailingExtra != null) ...[
          const SizedBox(width: 6),
          widget.trailingExtra!,
        ],
      ],
    );
  }

  Widget _metaRow(Ticket t) {
    return Row(
      children: [
        Flexible(
          child: Text(
            '📁 ${t.projectName}${t.issueType.isNotEmpty ? ' · ${t.issueType}' : ''}',
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
                color: AppColors.avatarColor(t.assigneeName!), shape: BoxShape.circle),
            child: Text(t.assigneeInitials,
                style: const TextStyle(
                    fontSize: 8, fontWeight: FontWeight.w600, color: Colors.white)),
          ),
      ],
    );
  }
}

class _KeyChip extends StatefulWidget {
  final String label;
  final VoidCallback onTap;
  const _KeyChip({required this.label, required this.onTap});

  @override
  State<_KeyChip> createState() => _KeyChipState();
}

class _KeyChipState extends State<_KeyChip> {
  bool _h = false;
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _h = true),
      onExit: (_) => setState(() => _h = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
          decoration: BoxDecoration(
            color: AppColors.accentSoft,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            widget.label,
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: AppColors.accent,
              decoration: _h ? TextDecoration.underline : TextDecoration.none,
              decorationColor: AppColors.accent,
            ),
          ),
        ),
      ),
    );
  }
}

class _AgePill extends StatelessWidget {
  final String label;
  const _AgePill({required this.label});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      decoration: BoxDecoration(
        color: AppColors.aging.withOpacity(0.14),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(label,
          style: const TextStyle(
              fontSize: 9, fontWeight: FontWeight.w700, color: AppColors.aging)),
    );
  }
}
