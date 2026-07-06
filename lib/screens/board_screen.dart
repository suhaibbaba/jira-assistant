import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:triage/config/app_info.dart';
import 'package:triage/l10n/gen/app_localizations.dart';
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
        children: const [
          _Toolbar(),
          _UpdateBar(),
          _ConnectionBar(),
          Expanded(
            child: Row(
              children: [
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
    final l10n = AppLocalizations.of(context);
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
          const Text(AppInfo.appNameFull, style: AppTypography.toolbarTitle),
          const SizedBox(width: 6),
          Text(l10n.boardToolbarDomain(app.settings.domain),
              style: AppTypography.bodySecondary),
          const Spacer(),
          AppIconButton(
              icon: Icons.timer_outlined,
              tooltip: l10n.boardTooltipTimeTracking,
              onTap: () {
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const TimeScreen()));
              }),
          const SizedBox(width: 10),
          AppIconButton(
              icon: Icons.wb_sunny_outlined,
              tooltip: l10n.boardTooltipMorningDigest,
              onTap: () {
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const DigestScreen()));
              }),
          const SizedBox(width: 10),
          AppIconButton(
              icon: Icons.add,
              tooltip: l10n.boardTooltipAddAttention,
              onTap: () => _showAddDialog(context)),
          const SizedBox(width: 10),
          AppIconButton(
              icon: Icons.settings_outlined,
              tooltip: l10n.boardTooltipSettings,
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
    final l10n = AppLocalizations.of(context);
    final keyController = TextEditingController();
    final byController = TextEditingController();
    showAppDialog(
      context: context,
      title: l10n.boardAddDialogTitle,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DialogHint(l10n.boardAddDialogHint),
          const SizedBox(height: 12),
          AppTextField(
            controller: keyController,
            label: l10n.boardAddTicketKeyLabel,
            hint: l10n.boardAddTicketKeyHint,
            autofocus: true,
            textCapitalization: TextCapitalization.characters,
          ),
          const SizedBox(height: 10),
          AppTextField(
            controller: byController,
            label: l10n.boardAddSentByLabel,
            hint: l10n.boardAddSentByHint,
          ),
        ],
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
            child: Text(l10n.commonCancel)),
        FilledButton(
          onPressed: () async {
            final key = keyController.text.trim();
            final by = byController.text.trim();
            Navigator.of(context, rootNavigator: true).pop();
            if (key.isEmpty) return;
            final ok = await context
                .read<AppState>()
                .addAttention(key, by.isEmpty ? l10n.boardAddUnknownSender : by);
            if (context.mounted && !ok) {
              ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.boardTicketNotFound(key))));
            }
          },
          child: Text(l10n.commonAdd),
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
    final l10n = AppLocalizations.of(context);
    String when() {
      final t = app.lastSyncedAt;
      if (t == null) return l10n.boardSyncedNever;
      final d = DateTime.now().difference(t);
      if (d.inMinutes < 1) return l10n.boardSyncedJustNow;
      if (d.inMinutes < 60) return l10n.boardSyncedMinutesAgo(d.inMinutes);
      return l10n.boardSyncedHoursAgo(d.inHours);
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        InkWell(
          onTap: app.isSyncing ? null : () => app.sync(),
          borderRadius: AppRadius.br8,
          child: Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
                color: AppColors.accent, borderRadius: AppRadius.br8),
            child: app.isSyncing
                ? const Padding(
                    padding: EdgeInsets.all(8),
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white))
                : const Icon(Icons.sync, size: 16, color: Colors.white),
          ),
        ),
        const SizedBox(height: 1),
        Text(l10n.boardSyncedLabel(when()),
            style: const TextStyle(fontSize: 9, color: AppColors.text3)),
      ],
    );
  }
}

class _UpdateBar extends StatelessWidget {
  const _UpdateBar();

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final l10n = AppLocalizations.of(context);
    final update = app.availableUpdate;
    if (update == null) return const SizedBox.shrink();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: const BoxDecoration(
        color: AppColors.accentSoft,
        border:
            Border(bottom: BorderSide(color: AppColors.separator, width: 0.5)),
      ),
      child: Row(
        children: [
          Expanded(
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () => app.openUpdatePage(),
                child: Text(l10n.updateBanner(update.version),
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.accent)),
              ),
            ),
          ),
          Tooltip(
            message: l10n.updateDismissTooltip,
            child: InkWell(
              onTap: () => app.dismissUpdate(),
              borderRadius: BorderRadius.circular(4),
              child: const Padding(
                padding: EdgeInsets.all(2),
                child: Icon(Icons.close, size: 14, color: AppColors.text2),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ConnectionBar extends StatelessWidget {
  const _ConnectionBar();

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final l10n = AppLocalizations.of(context);
    if (app.conn == ConnState.ok || app.conn == ConnState.unconfigured) {
      return const SizedBox.shrink();
    }
    final isAuth = app.conn == ConnState.authError;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
      color: isAuth ? AppColors.authBannerBg : AppColors.offlineBannerBg,
      child: Row(
        children: [
          Text(isAuth ? '🔒 ' : '⚠️ '),
          Expanded(
            child: Text(
              isAuth
                  ? l10n.boardConnAuthExpired
                  : (app.statusMessage ?? l10n.boardConnOffline),
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isAuth
                      ? AppColors.authBannerText
                      : AppColors.offlineBannerText),
            ),
          ),
          if (isAuth)
            TextButton(
              onPressed: () => app.signOut(),
              child: Text(l10n.boardConnReconnect,
                  style: const TextStyle(fontSize: 12)),
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
    final l10n = AppLocalizations.of(context);
    final grouped = app.groupedByStatus;

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
          _newBanner(app, l10n, app.newTicketCount),
        if (grouped['Needs Attention'] != null)
          _StatusSection(
            status: 'Needs Attention',
            tickets: grouped['Needs Attention']!,
            draggable: false,
          ),
        ...sections.map((s) => _StatusSection(status: s, tickets: grouped[s]!)),
        if (sections.isEmpty && grouped['Needs Attention'] == null)
          Padding(
            padding: const EdgeInsets.only(top: 60),
            child: Center(
              child: Text(l10n.boardNoTicketsMatch,
                  style: const TextStyle(color: AppColors.text3, fontSize: 14)),
            ),
          ),
      ],
    );
  }

  Widget _newBanner(AppState app, AppLocalizations l10n, int count) =>
      Container(
        margin: const EdgeInsets.only(bottom: 18),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
              colors: [AppColors.danger, AppColors.dangerGradientEnd]),
          borderRadius: AppRadius.br12,
          boxShadow: [
            BoxShadow(
                color: AppColors.danger.withValues(alpha: 0.25),
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
                  Text(l10n.boardNewTicketsBanner(count),
                      style: AppTypography.bannerTitle),
                ],
              ),
            ),
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
    final l10n = AppLocalizations.of(context);
    final color = AppColors.statusColor(status);

    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title:
                status == 'Needs Attention' ? l10n.statusNeedsAttention : status,
            count: tickets.length,
            color: color,
            trailing: draggable ? l10n.boardDragToReorder : null,
          ),
          const SizedBox(height: 10),
          if (draggable)
            ReorderableListView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              buildDefaultDragHandles: true,
              onReorderItem: (oldIndex, newIndex) {
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
