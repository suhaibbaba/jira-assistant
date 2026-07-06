import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:triage/l10n/gen/app_localizations.dart';
import 'package:triage/state/app_state.dart';
import 'package:triage/models/ticket.dart';
import 'package:triage/theme/app_theme.dart';
import 'package:triage/widgets/ticket_card.dart';
import 'package:triage/widgets/ui/ui.dart';
import 'package:triage/widgets/ticket_detail_dialog.dart';

class DigestScreen extends StatelessWidget {
  const DigestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final l10n = AppLocalizations.of(context);
    final aging = app.agingTickets;
    final newTickets = app.groupedByStatus['New'] ?? [];

    return Scaffold(
      backgroundColor: AppColors.bgContent,
      appBar: AppBar(
        backgroundColor: AppColors.bgSidebar,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Row(
          children: [
            Text(l10n.digestTitle,
                style:
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            const SizedBox(width: 6),
            Text(
                l10n.digestDateSeparator(
                    DateFormat('EEE, MMM d').format(DateTime.now())),
                style: const TextStyle(fontSize: 12, color: AppColors.text2)),
          ],
        ),
        shape: const Border(
            bottom: BorderSide(color: AppColors.separator, width: 0.5)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(22, 18, 22, 24),
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 18),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                  colors: [AppColors.warning, AppColors.warningGradientEnd]),
              borderRadius: AppRadius.br12,
              boxShadow: [
                BoxShadow(
                    color: AppColors.warning.withValues(alpha: 0.22),
                    blurRadius: 14,
                    offset: const Offset(0, 4)),
              ],
            ),
            child: Row(
              children: [
                const Text('⏳', style: TextStyle(fontSize: 20)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.digestAgingBanner(aging.length),
                          style: AppTypography.bannerTitle),
                      Text(l10n.digestAgingSubtitle,
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (aging.isNotEmpty) ...[
            _sectionHeader(l10n.digestSectionAging, aging.length,
                AppColors.aging),
            for (final t in aging)
              TicketCard(
                ticket: t,
                showDragHandle: false,
                showAgePill: true,
                onOpenInBrowser: () => app.openInBrowser(t.key),
                onTapDetail: () => _detail(context, app, t),
              ),
            const SizedBox(height: 18),
          ],
          if (newTickets.isNotEmpty) ...[
            _sectionHeader(l10n.digestSectionNew, newTickets.length,
                AppColors.statusColor('New')),
            for (final t in newTickets)
              TicketCard(
                ticket: t,
                showDragHandle: false,
                onOpenInBrowser: () => app.openInBrowser(t.key),
                onTapDetail: () => _detail(context, app, t),
              ),
          ],
          const SizedBox(height: 12),
          Center(
            child: Text(l10n.digestFooter, style: AppTypography.caption),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title, int count, Color color) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: SectionHeader(title: title, count: count, color: color),
      );

  void _detail(BuildContext context, AppState app, Ticket t) => showDialog(
        context: context,
        builder: (_) => TicketDetailDialog(
          ticket: t,
          onOpenInBrowser: () => app.openInBrowser(t.key),
        ),
      );
}
