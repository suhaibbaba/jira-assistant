import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../models/ticket.dart';
import '../theme/app_theme.dart';
import '../widgets/sidebar.dart';
import '../widgets/ticket_card.dart';
import '../widgets/ticket_detail_dialog.dart';
import 'settings_screen.dart';
import 'digest_screen.dart';
import 'jarvis_screen.dart';
import 'time_screen.dart';

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
        border: Border(bottom: BorderSide(color: AppColors.separator, width: 0.5)),
      ),
      child: Row(
        children: [
          const Text('Triage',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          const SizedBox(width: 6),
          Text('· ${app.settings.domain}',
              style: const TextStyle(fontSize: 12, color: AppColors.text2)),
          const Spacer(),
          _toolBtn(Icons.auto_awesome, 'Jarvis assistant', () {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => const JarvisScreen()));
          }),
          const SizedBox(width: 10),
          _toolBtn(Icons.timer_outlined, 'Time tracking', () {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => const TimeScreen()));
          }),
          const SizedBox(width: 10),
          _toolBtn(Icons.wb_sunny_outlined, 'Morning digest', () {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => const DigestScreen()));
          }),
          const SizedBox(width: 10),
          _toolBtn(Icons.add, 'Add ticket to watch',
              () => _showAddDialog(context)),
          const SizedBox(width: 10),
          _toolBtn(Icons.settings_outlined, 'Settings', () {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => const SettingsScreen()));
          }),
          const SizedBox(width: 14),
          _SyncButton(app: app),
        ],
      ),
    );
  }

  Widget _toolBtn(IconData icon, String tip, VoidCallback onTap) => Tooltip(
        message: tip,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(7),
          child: Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.05),
                borderRadius: BorderRadius.circular(7)),
            child: Icon(icon, size: 16, color: AppColors.text2),
          ),
        ),
      );

  void _showAddDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text('Add ticket to watch',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
                'Paste a ticket key (e.g. PAY-123). It joins your Estimate Requested lane.',
                style: TextStyle(fontSize: 12, color: AppColors.text2)),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'PAY-123',
                isDense: true,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () async {
              final key = controller.text.trim();
              Navigator.pop(ctx);
              if (key.isEmpty) return;
              final ok = await context.read<AppState>().addEstimateRequest(key);
              if (context.mounted && !ok) {
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Could not find ticket "$key".')));
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
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
                  : (app.statusMessage ?? 'Offline — showing last synced data.'),
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

    // Section order: New first, then the rest, Estimate Requested handled separately.
    final order = ['New', 'Blocked', 'Need Clarification', 'In Progress', 'Review'];
    final sections = <String>[
      ...order.where((s) => grouped.containsKey(s)),
      ...grouped.keys.where((s) => !order.contains(s) && s != 'Estimate Requested'),
    ];

    return ListView(
      padding: const EdgeInsets.fromLTRB(22, 18, 22, 24),
      children: [
        if (app.newTicketCount > 0) _newBanner(app.newTicketCount),
        if (grouped['Estimate Requested'] != null)
          _StatusSection(
            status: 'Estimate Requested',
            tickets: grouped['Estimate Requested']!,
            draggable: false,
          ),
        ...sections.map((s) => _StatusSection(status: s, tickets: grouped[s]!)),
        if (sections.isEmpty && grouped['Estimate Requested'] == null)
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

  Widget _newBanner(int count) => Container(
        margin: const EdgeInsets.only(bottom: 18),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
              colors: [Color(0xFFFF3B30), Color(0xFFFF6259)]),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
                color: const Color(0xFFFF3B30).withOpacity(0.25),
                blurRadius: 14,
                offset: const Offset(0, 4)),
          ],
        ),
        child: Row(
          children: [
            const Text('🆕', style: TextStyle(fontSize: 20)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('$count new tickets need triage',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w700)),
                  const Text('Highest priority first',
                      style: TextStyle(color: Colors.white70, fontSize: 12)),
                ],
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
          Row(
            children: [
              Container(
                  width: 9,
                  height: 9,
                  decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
              const SizedBox(width: 8),
              Text(status,
                  style:
                      const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 1),
                decoration: BoxDecoration(
                    color: color, borderRadius: BorderRadius.circular(9)),
                child: Text('${tickets.length}',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700)),
              ),
              const Spacer(),
              if (draggable)
                const Text('⇅ drag to reorder',
                    style: TextStyle(fontSize: 10, color: AppColors.text3)),
            ],
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
    return TicketCard(
      key: key,
      ticket: t,
      showDragHandle: draggable,
      onOpenInBrowser: () => app.openInBrowser(t.key),
      onTapDetail: () => showDialog(
        context: context,
        builder: (_) => TicketDetailDialog(
          ticket: t,
          onOpenInBrowser: () => app.openInBrowser(t.key),
          onDismissEstimate:
              t.isEstimateRequest ? () => app.dismissEstimateRequest(t.key) : null,
        ),
      ),
    );
  }
}
