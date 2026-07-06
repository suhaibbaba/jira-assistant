import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

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
  /// Sentinel dropdown value for "no ticket — note only".
  static const _noteOption = '__note__';

  String? _ticketKey = _noteOption; // note option is first AND the default
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

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final today = app.tracker.today;
    final total = app.tracker.totalHours(today);
    final ticketKeys = app.allTickets.map((t) => t.key).toList()..sort();

    return Scaffold(
      backgroundColor: AppColors.bgContent,
      appBar: AppBar(
        backgroundColor: AppColors.bgSidebar,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text('⏱️ Time Tracking',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        shape: const Border(
            bottom: BorderSide(color: AppColors.separator, width: 0.5)),
        actions: [
          TextButton.icon(
            onPressed: () => _exportSummary(context, app),
            icon: const Icon(Icons.ios_share, size: 16),
            label: const Text('Export', style: TextStyle(fontSize: 12)),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
        children: [
          _label('Log time'),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
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
                      decoration: appInputDecoration(label: 'Ticket'),
                      items: [
                        // First option: work without a Jira ticket.
                        const DropdownMenuItem(
                            value: _noteOption,
                            child: Text('📝 No ticket — add note',
                                style: TextStyle(fontSize: 13))),
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
                      decoration: appInputDecoration(label: 'Hours'),
                    ),
                  ),
                ]),
                const SizedBox(height: 10),
                if (_isNoteMode) ...[
                  AppTextField(
                    controller: _note,
                    label: 'What did you work on?',
                    hint: 'e.g. Sprint planning, interview, helping QA…',
                  ),
                  const SizedBox(height: 10),
                ],
                DropdownButtonFormField<WorkType>(
                  value: _type,
                  isExpanded: true,
                  decoration: appInputDecoration(label: 'Work type'),
                  items: [
                    for (final w in WorkType.values)
                      DropdownMenuItem(
                          value: w,
                          child: Text(w.label,
                              style: const TextStyle(fontSize: 13))),
                  ],
                  onChanged: (v) => setState(() => _type = v ?? WorkType.other),
                ),
                const SizedBox(height: 12),
                AppButton(label: 'Add entry', onTap: () => _addLog(app)),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _label(
                  "Today — ${DateFormat('EEE, MMM d').format(DateTime.now())}"),
              const Spacer(),
              Text('${_fmt(total)}h total',
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.accent)),
            ],
          ),
          const SizedBox(height: 6),
          if (today.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 30),
              child: Center(
                child: Text('Nothing logged yet today.',
                    style: TextStyle(color: AppColors.text3, fontSize: 13)),
              ),
            )
          else
            ...today.map((l) => _logRow(app, l)),
        ],
      ),
    );
  }

  Widget _logRow(AppState app, TimeLog l) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: AppColors.separator, width: 0.5),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
            constraints: const BoxConstraints(maxWidth: 220),
            decoration: BoxDecoration(
                color: l.isNoteOnly
                    ? const Color(0x22FF9F0A)
                    : AppColors.accentSoft,
                borderRadius: BorderRadius.circular(4)),
            child: Text(l.isNoteOnly ? '📝 ${l.displayLabel}' : l.ticketKey,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontFamily: l.isNoteOnly ? null : 'monospace',
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: l.isNoteOnly
                        ? const Color(0xFFB25E00)
                        : AppColors.accent)),
          ),
          const SizedBox(width: 10),
          Text(l.type.label,
              style: const TextStyle(fontSize: 12, color: AppColors.text2)),
          const Spacer(),
          Text('${_fmt(l.hours)}h',
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
    final h = double.tryParse(_hours.text.trim());
    if (h == null || h <= 0) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Enter valid hours.')));
      return;
    }
    if (_isNoteMode && _note.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Write a short note about the work.')));
      return;
    }
    if (!_isNoteMode && _ticketKey == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Pick a ticket, or choose the note option.')));
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
    final text = app.tracker.endOfDaySummary();
    Clipboard.setData(ClipboardData(text: text));
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text('End of Day Summary',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
        content: SingleChildScrollView(
          child: SelectableText(text,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 12)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Copied to clipboard ✓'),
          ),
        ],
      ),
    );
  }

  Widget _label(String s) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(s.toUpperCase(),
            style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.4,
                color: AppColors.text3)),
      );

  String _fmt(double h) =>
      h == h.roundToDouble() ? h.toStringAsFixed(0) : h.toStringAsFixed(1);
}
