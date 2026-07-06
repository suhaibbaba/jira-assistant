import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

enum WorkType { meeting, development, codeReview, bugFix, documentation, other }

extension WorkTypeLabel on WorkType {
  String get label => switch (this) {
        WorkType.meeting => 'Meeting',
        WorkType.development => 'Development',
        WorkType.codeReview => 'Code Review',
        WorkType.bugFix => 'Bug Fix',
        WorkType.documentation => 'Documentation',
        WorkType.other => 'Other',
      };

  static WorkType parse(String s) {
    final t = s.toLowerCase();
    if (t.contains('meet')) return WorkType.meeting;
    if (t.contains('review')) return WorkType.codeReview;
    if (t.contains('bug') || t.contains('fix')) return WorkType.bugFix;
    if (t.contains('doc')) return WorkType.documentation;
    if (t.contains('dev')) return WorkType.development;
    return WorkType.other;
  }
}

class TimeLog {
  final String ticketKey;
  final String note;
  final double hours;
  final WorkType type;
  final DateTime loggedAt;

  TimeLog({
    required this.ticketKey,
    this.note = '',
    required this.hours,
    required this.type,
    required this.loggedAt,
  });

  bool get isNoteOnly => ticketKey.isEmpty;

  /// What to show as the entry's title: the key, or the note.
  String get displayLabel => isNoteOnly ? (note.isEmpty ? 'Note' : note) : ticketKey;

  Map<String, dynamic> toJson() => {
        'key': ticketKey,
        'note': note,
        'hours': hours,
        'type': type.name,
        'at': loggedAt.toIso8601String(),
      };

  factory TimeLog.fromJson(Map<String, dynamic> j) => TimeLog(
        ticketKey: j['key'] ?? '',
        note: j['note'] ?? '',
        hours: (j['hours'] as num).toDouble(),
        type: WorkType.values.firstWhere((w) => w.name == j['type'],
            orElse: () => WorkType.other),
        loggedAt: DateTime.parse(j['at']),
      );
}

/// Stores time logs locally and auto-deletes anything older than 30 days.
class TimeTracker {
  static const _key = 'time_logs';
  List<TimeLog> _logs = [];

  List<TimeLog> get all => List.unmodifiable(_logs);

  List<TimeLog> forDay(DateTime day) {
    return _logs
        .where((l) =>
            l.loggedAt.year == day.year &&
            l.loggedAt.month == day.month &&
            l.loggedAt.day == day.day)
        .toList();
  }

  List<TimeLog> get today => forDay(DateTime.now());

  double totalHours(List<TimeLog> logs) =>
      logs.fold(0.0, (sum, l) => sum + l.hours);

  Future<void> add(TimeLog log) async {
    _logs.add(log);
    await save();
  }

  Future<void> remove(TimeLog log) async {
    _logs.remove(log);
    await save();
  }

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw != null) {
      _logs = (jsonDecode(raw) as List)
          .map((e) => TimeLog.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    _autoCleanup(); // silently drop logs older than 30 days
    await save();
  }

  void _autoCleanup() {
    final cutoff = DateTime.now().subtract(const Duration(days: 30));
    _logs.removeWhere((l) => l.loggedAt.isBefore(cutoff));
  }

  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(_logs.map((l) => l.toJson()).toList()));
  }

  /// Plain-text end-of-day summary for export / sharing.
  String endOfDaySummary([DateTime? day]) {
    final d = day ?? DateTime.now();
    final logs = forDay(d);
    final buf = StringBuffer();
    buf.writeln('End of Day — ${DateFormat('EEE, MMM d, yyyy').format(d)}');
    buf.writeln('=' * 36);
    if (logs.isEmpty) {
      buf.writeln('No time logged.');
      return buf.toString();
    }

    // Group by ticket key, or by the note text for note-only entries.
    final byTicket = <String, List<TimeLog>>{};
    for (final l in logs) {
      byTicket.putIfAbsent(l.displayLabel, () => []).add(l);
    }
    byTicket.forEach((key, entries) {
      final h = totalHours(entries);
      final types = entries.map((e) => e.type.label).toSet().join(', ');
      buf.writeln('• $key — ${_fmt(h)}h  ($types)');
    });
    buf.writeln('-' * 36);
    buf.writeln('Total: ${_fmt(totalHours(logs))}h');
    return buf.toString();
  }

  String _fmt(double h) =>
      h == h.roundToDouble() ? h.toStringAsFixed(0) : h.toStringAsFixed(1);
}
