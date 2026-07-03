import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../state/app_state.dart';
import '../models/ticket.dart';
import '../theme/app_theme.dart';
import '../widgets/ticket_card.dart';
import '../widgets/ticket_detail_dialog.dart';

class DigestScreen extends StatelessWidget {
  const DigestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
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
            const Text('☀️ Good morning',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            const SizedBox(width: 6),
            Text('· ${DateFormat('EEE, MMM d').format(DateTime.now())}',
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
                  colors: [Color(0xFFFF9500), Color(0xFFFFB340)]),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                    color: const Color(0xFFFF9500).withOpacity(0.22),
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
                      Text('${aging.length} tickets are aging',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w700)),
                      const Text('Past your threshold · oldest first',
                          style:
                              TextStyle(color: Colors.white70, fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (aging.isNotEmpty) ...[
            _sectionHeader('Aging — needs attention', aging.length, AppColors.aging),
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
            _sectionHeader('New since yesterday', newTickets.length,
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
          const Center(
            child: Text('In Progress & Review never age — they’re being worked',
                style: TextStyle(fontSize: 10, color: AppColors.text3)),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title, int count, Color color) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(
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
              decoration: BoxDecoration(
                  color: color, borderRadius: BorderRadius.circular(9)),
              child: Text('$count',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      );

  void _detail(BuildContext context, AppState app, Ticket t) => showDialog(
        context: context,
        builder: (_) => TicketDetailDialog(
          ticket: t,
          onOpenInBrowser: () => app.openInBrowser(t.key),
        ),
      );
}
