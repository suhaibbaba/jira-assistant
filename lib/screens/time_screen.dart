import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import 'package:triage/l10n/gen/app_localizations.dart';
import 'package:triage/state/app_state.dart';
import 'package:triage/models/time_log.dart';
import 'package:triage/theme/app_theme.dart';
import 'package:triage/widgets/ui/ui.dart';

class TimeScreen extends StatefulWidget {
  const TimeScreen({super.key});
  @override
  State<TimeScreen> createState() => _TimeScreenState();
}

class _TimeScreenState extends State<TimeScreen> {
  static const _noteOption = '__note__';

  String? _ticketKey = _noteOption;
  final _hours = TextEditingController();
  final _note = TextEditingController();
  WorkType _type = WorkType.development;

  bool get _isNoteMode => _ticketKey == _noteOption;

  @override
  void dispose() {
    _hours.dispose();
    _note.dispose();
    super.dispose();
  }

  String _workTypeLabel(AppLocalizations l10n, WorkType w) => switch (w) {
        WorkType.meeting => l10n.workTypeMeeting,
        WorkType.development => l10n.workTypeDevelopment,
        WorkType.codeReview => l10n.workTypeCodeReview,
        WorkType.bugFix => l10n.workTypeBugFix,
        WorkType.documentation => l10n.workTypeDocumentation,
        WorkType.other => l10n.workTypeOther,
      };

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final l10n = AppLocalizations.of(context);
    final today = app.tracker.today;
    final total = app.tracker.totalHours(today);
    final ticketKeys = app.allTickets.map((t) => t.key).toList()..sort();

    return Scaffold(
      backgroundColor: AppColors.bgContent,
      appBar: AppBar(
        backgroundColor: AppColors.bgSidebar,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(l10n.timeTitle,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        shape: const Border(
            bottom: BorderSide(color: AppColors.separator, width: 0.5)),
        actions: [
          TextButton.icon(
            onPressed: () => _exportSummary(context, app),
            icon: const Icon(Icons.ios_share, size: 16),
            label: Text(l10n.timeExport, style: const TextStyle(fontSize: 12)),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
        children: [
          _label(l10n.timeSectionLog),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: AppRadius.br10,
              border: Border.all(color: AppColors.separator, width: 0.5),
            ),
            child: Column(
              children: [
                Row(children: [
                  Expanded(
                    flex: 3,
                    child: DropdownButtonFormField<String>(
                      value: _ticketKey,
                      isExpanded: true,
                      decoration: appInputDecoration(label: l10n.timeTicketLabel),
                      items: [
                        DropdownMenuItem(
                            value: _noteOption,
                            child: Text(l10n.timeNoTicketOption,
                                style: const TextStyle(fontSize: 13))),
                        for (final k in ticketKeys)
                          DropdownMenuItem(
                              value: k,
                              child: Text(k,
                                  style: const TextStyle(fontSize: 13))),
                      ],
                      onChanged: (v) => setState(() => _ticketKey = v),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _hours,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      style: const TextStyle(fontSize: 13),
                      decoration: appInputDecoration(label: l10n.timeHoursLabel),
                    ),
                  ),
                ]),
                const SizedBox(height: 10),
                if (_isNoteMode) ...[
                  AppTextField(
                    controller: _note,
                    label: l10n.timeNoteLabel,
                    hint: l10n.timeNoteHint,
                  ),
                  const SizedBox(height: 10),
                ],
                DropdownButtonFormField<WorkType>(
                  value: _type,
                  isExpanded: true,
                  decoration: appInputDecoration(label: l10n.timeWorkTypeLabel),
                  items: [
                    for (final w in WorkType.values)
                      DropdownMenuItem(
                          value: w,
                          child: Text(_workTypeLabel(l10n, w),
                              style: const TextStyle(fontSize: 13))),
                  ],
                  onChanged: (v) => setState(() => _type = v ?? WorkType.other),
                ),
                const SizedBox(height: 12),
                AppButton(label: l10n.timeAddEntry, onTap: () => _addLog(app)),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _label(l10n.timeTodayLabel(
                  DateFormat('EEE, MMM d').format(DateTime.now()))),
              const Spacer(),
              Text(l10n.timeTotalHours(_fmt(total)),
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.accent)),
            ],
          ),
          const SizedBox(height: 6),
          if (today.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 30),
              child: Center(
                child: Text(l10n.timeNothingLogged,
                    style:
                        const TextStyle(color: AppColors.text3, fontSize: 13)),
              ),
            )
          else
            ...today.map((l) => _logRow(app, l10n, l)),
        ],
      ),
    );
  }

  Widget _logRow(AppState app, AppLocalizations l10n, TimeLog l) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.br9,
        border: Border.all(color: AppColors.separator, width: 0.5),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
            constraints: const BoxConstraints(maxWidth: 220),
            decoration: BoxDecoration(
                color: l.isNoteOnly
                    ? AppColors.noteChipBg
                    : AppColors.accentSoft,
                borderRadius: AppRadius.br4),
            child: Text(
                l.isNoteOnly ? l10n.timeNotePrefix(l.displayLabel) : l.ticketKey,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontFamily: l.isNoteOnly ? null : 'monospace',
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: l.isNoteOnly
                        ? AppColors.offlineBannerText
                        : AppColors.accent)),
          ),
          const SizedBox(width: 10),
          Text(_workTypeLabel(l10n, l.type),
              style: const TextStyle(fontSize: 12, color: AppColors.text2)),
          const Spacer(),
          Text(l10n.timeHoursShort(_fmt(l.hours)),
              style:
                  const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          IconButton(
            icon: const Icon(Icons.close, size: 15, color: AppColors.text3),
            onPressed: () => app.tracker.remove(l).then((_) => setState(() {})),
          ),
        ],
      ),
    );
  }

  void _addLog(AppState app) {
    final l10n = AppLocalizations.of(context);
    final h = double.tryParse(_hours.text.trim());
    if (h == null || h <= 0) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.timeErrInvalidHours)));
      return;
    }
    if (_isNoteMode && _note.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.timeErrNoteRequired)));
      return;
    }
    if (!_isNoteMode && _ticketKey == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.timeErrPickTicket)));
      return;
    }
    app.tracker
        .add(TimeLog(
      ticketKey: _isNoteMode ? '' : _ticketKey!,
      note: _isNoteMode ? _note.text.trim() : '',
      hours: h,
      type: _type,
      loggedAt: DateTime.now(),
    ))
        .then((_) {
      _hours.clear();
      _note.clear();
      setState(() {});
    });
  }

  void _exportSummary(BuildContext context, AppState app) {
    final l10n = AppLocalizations.of(context);
    final text = app.tracker.endOfDaySummary();
    Clipboard.setData(ClipboardData(text: text));
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.br14),
        title: Text(l10n.timeSummaryTitle,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
        content: SingleChildScrollView(
          child: SelectableText(text,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 12)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.timeCopied),
          ),
        ],
      ),
    );
  }

  Widget _label(String s) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(s.toUpperCase(), style: AppTypography.overline),
      );

  String _fmt(double h) =>
      h == h.roundToDouble() ? h.toStringAsFixed(0) : h.toStringAsFixed(1);
}
