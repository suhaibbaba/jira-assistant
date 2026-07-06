import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:triage/state/app_state.dart';
import 'package:triage/models/ticket.dart';
import 'package:triage/models/attention_item.dart';
import 'package:triage/theme/app_theme.dart';
import 'package:triage/widgets/sidebar.dart';
import 'package:triage/widgets/ticket_card.dart';
import 'package:triage/widgets/ui/ui.dart';
import 'package:triage/widgets/ticket_detail_dialog.dart';
import 'package:triage/screens/settings_screen.dart';
import 'package:triage/screens/digest_screen.dart';
import 'package:triage/screens/time_screen.dart';

class BoardScreen extends StatelessWidget {
  const BoardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgContent,
      body: Column(
        children: [
          const _Toolbar(),
          const _ConnectionBar(),
          Expanded(
            child: Row(
              children: const [
                Sidebar(),
                Expanded(child: _Board()),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Toolbar extends StatelessWidget {
  const _Toolbar();

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        color: AppColors.bgSidebar,
        border:
            Border(bottom: BorderSide(color: AppColors.separator, width: 0.5)),
      ),
      child: Row(
        children: [
          const Text('Xngage — Jira Assistance',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          const SizedBox(width: 6),
          Text('· ${app.settings.domain}',
              style: const TextStyle(fontSize: 12, color: AppColors.text2)),
          const Spacer(),
          AppIconButton(
              icon: Icons.timer_outlined,
              tooltip: 'Time tracking',
              onTap: () {
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const TimeScreen()));
              }),
          const SizedBox(width: 10),
          AppIconButton(
              icon: Icons.wb_sunny_outlined,
              tooltip: 'Morning digest',
              onTap: () {
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const DigestScreen()));
              }),
          const SizedBox(width: 10),
          AppIconButton(
              icon: Icons.add,
              tooltip: 'Add ticket that needs attention',
              onTap: () => _showAddDialog(context)),
          const SizedBox(width: 10),
          AppIconButton(
              icon: Icons.settings_outlined,
              tooltip: 'Settings',
              onTap: () {
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const SettingsScreen()));
              }),
          const SizedBox(width: 14),
          _SyncButton(app: app),
        ],
      ),
    );
  }

  void _showAddDialog(BuildContext context) {
    final keyController = TextEditingController();
    final byController = TextEditingController();
    showAppDialog(
      context: context,
      title: 'Needs attention',
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const DialogHint(
              'Add a ticket someone sent you (e.g. for an estimate). '
              'The time is recorded automatically.'),
          const SizedBox(height: 12),
          AppTextField(
            controller: keyController,
            label: 'Ticket key',
            hint: 'PAY-123',
            autofocus: true,
            textCapitalization: TextCapitalization.characters,
          ),
          const SizedBox(height: 10),
          AppTextField(
            controller: byController,
            label: 'Sent by',
            hint: 'e.g. Product Owner, Sarah…',
          ),
        ],
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
            child: const Text('Cancel')),
        FilledButton(
          onPressed: () async {
            final key = keyController.text.trim();
            final by = byController.text.trim();
            Navigator.of(context, rootNavigator: true).pop();
            if (key.isEmpty) return;
            final ok = await context
                .read<AppState>()
                .addAttention(key, by.isEmpty ? 'Unknown' : by);
            if (context.mounted && !ok) {
              ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Could not find ticket "$key".')));
            }
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}

class _SyncButton extends StatelessWidget {
  final AppState app;
  const _SyncButton({required this.app});

  @override
  Widget build(BuildContext context) {
    String when() {
      final t = app.lastSyncedAt;
      if (t == null) return 'never';
      final d = DateTime.now().difference(t);
      if (d.inMinutes < 1) return 'just now';
      if (d.inMinutes < 60) return '${d.inMinutes}m ago';
      return '${d.inHours}h ago';
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        InkWell(
          onTap: app.isSyncing ? null : () => app.sync(),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
                color: AppColors.accent,
                borderRadius: BorderRadius.circular(8)),
            child: app.isSyncing
                ? const Padding(
                    padding: EdgeInsets.all(8),
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white))
                : const Icon(Icons.sync, size: 16, color: Colors.white),
          ),
        ),
        const SizedBox(height: 1),
        Text('Synced ${when()}',
            style: const TextStyle(fontSize: 9, color: AppColors.text3)),
      ],
    );
  }
}

class _ConnectionBar extends StatelessWidget {
  const _ConnectionBar();

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    if (app.conn == ConnState.ok || app.conn == ConnState.unconfigured) {
      return const SizedBox.shrink();
    }
    final isAuth = app.conn == ConnState.authError;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
      color: isAuth ? const Color(0xFFFDE7E9) : const Color(0xFFFFF4E5),
      child: Row(
        children: [
          Text(isAuth ? '🔒 ' : '⚠️ '),
          Expanded(
            child: Text(
              isAuth
                  ? 'Your Jira token expired — reconnect to continue.'
                  : (app.statusMessage ??
                      'Offline — showing last synced data.'),
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isAuth
                      ? const Color(0xFFC0263A)
                      : const Color(0xFFB25E00)),
            ),
          ),
          if (isAuth)
            TextButton(
              onPressed: () => app.signOut(),
              child: const Text('Reconnect', style: TextStyle(fontSize: 12)),
            ),
        ],
      ),
    );
  }
}

class _Board extends StatelessWidget {
  const _Board();

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final grouped = app.groupedByStatus;

    // Section order: Needs Attention pinned first, then New, then the rest.
    final order = [
      'New',
      'Blocked',
      'Need Clarification',
      'In Progress',
      'Review'
    ];
    final sections = <String>[
      ...order.where((s) => grouped.containsKey(s)),
      ...grouped.keys
          .where((s) => !order.contains(s) && s != 'Needs Attention'),
    ];

    return ListView(
      padding: const EdgeInsets.fromLTRB(22, 18, 22, 24),
      children: [
        if (app.newTicketCount > 0 && !app.newBannerDismissed)
          _newBanner(app, app.newTicketCount),
        if (grouped['Needs Attention'] != null)
          _StatusSection(
            status: 'Needs Attention',
            tickets: grouped['Needs Attention']!,
            draggable: false,
          ),
        ...sections.map((s) => _StatusSection(status: s, tickets: grouped[s]!)),
        if (sections.isEmpty && grouped['Needs Attention'] == null)
          const Padding(
            padding: EdgeInsets.only(top: 60),
            child: Center(
              child: Text('No tickets match your current filters.',
                  style: TextStyle(color: AppColors.text3, fontSize: 14)),
            ),
          ),
      ],
    );
  }

  Widget _newBanner(AppState app, int count) => Container(
        margin: const EdgeInsets.only(bottom: 18),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
              colors: [Color(0xFFFF3B30), Color(0xFFFF6259)]),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
                color: const Color(0xFFFF3B30).withValues(alpha: 0.25),
                blurRadius: 14,
                offset: const Offset(0, 4)),
          ],
        ),
        child: Row(
          children: [
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('$count new tickets need attention',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w700)),
                ],
              ),
            ),
            // ── Close button ──
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: app.dismissNewBanner,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, size: 14, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      );
}

/// One status section, with drag-to-reorder for the tickets inside.
class _StatusSection extends StatelessWidget {
  final String status;
  final List<Ticket> tickets;
  final bool draggable;

  const _StatusSection({
    required this.status,
    required this.tickets,
    this.draggable = true,
  });

  @override
  Widget build(BuildContext context) {
    final app = context.read<AppState>();
    final color = AppColors.statusColor(status);

    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: status,
            count: tickets.length,
            color: color,
            trailing: draggable ? '⇅ drag to reorder' : null,
          ),
          const SizedBox(height: 10),
          if (draggable)
            ReorderableListView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              buildDefaultDragHandles: true,
              onReorder: (oldIndex, newIndex) {
                final list = [...tickets];
                if (newIndex > oldIndex) newIndex--;
                final item = list.removeAt(oldIndex);
                list.insert(newIndex, item);
                app.reorderWithin(status, list);
              },
              children: [
                for (final t in tickets)
                  _cardFor(context, app, t, key: ValueKey(t.key)),
              ],
            )
          else
            Column(
              children: [for (final t in tickets) _cardFor(context, app, t)],
            ),
        ],
      ),
    );
  }

  Widget _cardFor(BuildContext context, AppState app, Ticket t, {Key? key}) {
    final AttentionMeta? meta =
        t.isEstimateRequest ? app.attention.metaFor(t.key) : null;
    return TicketCard(
      key: key,
      ticket: t,
      showDragHandle: draggable,
      attentionMeta: meta,
      onMarkDone:
          t.isEstimateRequest ? () => app.markAttentionDone(t.key) : null,
      onOpenInBrowser: () => app.openInBrowser(t.key),
      onTapDetail: () => showDialog(
        context: context,
        builder: (_) => TicketDetailDialog(
          ticket: t,
          onOpenInBrowser: () => app.openInBrowser(t.key),
          onDismissEstimate:
              t.isEstimateRequest ? () => app.markAttentionDone(t.key) : null,
        ),
      ),
    );
  }
}
