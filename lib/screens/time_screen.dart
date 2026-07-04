import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../state/app_state.dart';
import '../models/time_log.dart';
import '../theme/app_theme.dart';

class TimeScreen extends StatefulWidget {
  const TimeScreen({super.key});
  @override
  State<TimeScreen> createState() => _TimeScreenState();
}

class _TimeScreenState extends State<TimeScreen> {
  String? _ticketKey;
  final _hours = TextEditingController();
  WorkType _type = WorkType.development;

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
                      hint:
                          const Text('Ticket', style: TextStyle(fontSize: 13)),
                      decoration: _fieldDecoration('Ticket'),
                      items: [
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
                      decoration: _fieldDecoration('Hours'),
                    ),
                  ),
                ]),
                const SizedBox(height: 10),
                DropdownButtonFormField<WorkType>(
                  value: _type,
                  isExpanded: true,
                  decoration: _fieldDecoration('Work type'),
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
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => _addLog(app),
                    child: const Text('Add entry'),
                  ),
                ),
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
            decoration: BoxDecoration(
                color: AppColors.accentSoft,
                borderRadius: BorderRadius.circular(4)),
            child: Text(l.ticketKey,
                style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.accent)),
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
    final key = _ticketKey;
    final h = double.tryParse(_hours.text.trim());
    if (key == null || h == null || h <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Pick a ticket and enter valid hours.')));
      return;
    }
    app.tracker
        .add(TimeLog(
            ticketKey: key, hours: h, type: _type, loggedAt: DateTime.now()))
        .then((_) {
      _hours.clear();
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

  InputDecoration _fieldDecoration(String hint) => InputDecoration(
        labelText: hint,
        labelStyle: const TextStyle(fontSize: 12, color: AppColors.text2),
        hintStyle: const TextStyle(fontSize: 12, color: AppColors.text3),
        isDense: true,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      );

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
