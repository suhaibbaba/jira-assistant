import 'package:intl/intl.dart';

/// A single Jira issue, plus app-local fields (manual order, local "estimate" flag).
class Ticket {
  final String key; // e.g. PAY-412
  final String summary;
  final String description;
  final String status; // New, Blocked, In Progress, ...
  final String priority; // Highest, High, Medium, Low, Lowest, None
  final String issueType; // Bug, Task, Story...
  final String projectKey;
  final String projectName;
  final String? assigneeName;
  final String? assigneeEmail;
  final DateTime? updated;
  final DateTime? statusChangedAt; // when it last entered the current status

  // App-local only (never written back to Jira):
  final bool isEstimateRequest; // manually added "estimate requested" lane
  int manualOrder; // personal rank within its status+priority bucket

  Ticket({
    required this.key,
    required this.summary,
    required this.description,
    required this.status,
    required this.priority,
    required this.issueType,
    required this.projectKey,
    required this.projectName,
    this.assigneeName,
    this.assigneeEmail,
    this.updated,
    this.statusChangedAt,
    this.isEstimateRequest = false,
    this.manualOrder = 0,
  });

  /// Build a Ticket from a Jira REST API v3 issue JSON object.
  factory Ticket.fromJson(Map<String, dynamic> json, {bool isEstimateRequest = false}) {
    final fields = (json['fields'] ?? {}) as Map<String, dynamic>;

    String text(dynamic node) {
      // Jira v3 descriptions are Atlassian Document Format (ADF). Extract plain text.
      if (node == null) return '';
      if (node is String) return node;
      final buffer = StringBuffer();
      void walk(dynamic n) {
        if (n is Map) {
          if (n['text'] is String) buffer.write(n['text']);
          if (n['content'] is List) {
            for (final c in n['content']) {
              walk(c);
            }
            if (n['type'] == 'paragraph') buffer.write('\n');
          }
        } else if (n is List) {
          for (final c in n) {
            walk(c);
          }
        }
      }
      walk(node);
      return buffer.toString().trim();
    }

    DateTime? parse(dynamic s) =>
        (s is String && s.isNotEmpty) ? DateTime.tryParse(s)?.toLocal() : null;

    // Time-in-status: prefer statuscategorychangedate, fall back to updated.
    final statusChanged =
        parse(fields['statuscategorychangedate']) ?? parse(fields['updated']);

    final project = (fields['project'] ?? {}) as Map<String, dynamic>;
    final assignee = fields['assignee'] as Map<String, dynamic>?;

    return Ticket(
      key: json['key'] ?? '',
      summary: fields['summary'] ?? '(no summary)',
      description: text(fields['description']),
      status: (fields['status']?['name'] ?? 'Unknown').toString(),
      priority: (fields['priority']?['name'] ?? 'None').toString(),
      issueType: (fields['issuetype']?['name'] ?? '').toString(),
      projectKey: (project['key'] ?? '').toString(),
      projectName: (project['name'] ?? '').toString(),
      assigneeName: assignee?['displayName']?.toString(),
      assigneeEmail: assignee?['emailAddress']?.toString(),
      updated: parse(fields['updated']),
      statusChangedAt: statusChanged,
      isEstimateRequest: isEstimateRequest,
    );
  }

  /// Rank used to sort within a status section (lower = higher priority).
  static const _priorityRank = {
    'Highest': 0,
    'High': 1,
    'Medium': 2,
    'Low': 3,
    'Lowest': 4,
    'None': 5,
  };

  int get priorityRank => _priorityRank[priority] ?? 5;

  /// How long the ticket has been sitting in its current status.
  Duration? get timeInStatus =>
      statusChangedAt == null ? null : DateTime.now().difference(statusChangedAt!);

  /// Whole calendar days in the current status.
  int get calendarDaysInStatus => timeInStatus == null ? 0 : timeInStatus!.inHours ~/ 24;

  /// Business days (Mon–Fri) elapsed since entering the current status.
  int get businessDaysInStatus {
    if (statusChangedAt == null) return 0;
    var count = 0;
    var d = DateTime(statusChangedAt!.year, statusChangedAt!.month, statusChangedAt!.day);
    final today = DateTime.now();
    final end = DateTime(today.year, today.month, today.day);
    while (d.isBefore(end)) {
      if (d.weekday != DateTime.saturday && d.weekday != DateTime.sunday) count++;
      d = d.add(const Duration(days: 1));
    }
    return count;
  }

  /// Short label like "3d" or "5h" for the time-in-status pill.
  String get ageLabel {
    final t = timeInStatus;
    if (t == null) return '';
    if (t.inDays >= 1) return '${t.inDays}d';
    if (t.inHours >= 1) return '${t.inHours}h';
    return '${t.inMinutes}m';
  }

  String get updatedLabel {
    if (updated == null) return '';
    final diff = DateTime.now().difference(updated!);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    if (diff.inDays < 7) return '${diff.inDays}d';
    return DateFormat('MMM d').format(updated!);
  }

  String get assigneeInitials {
    final name = assigneeName;
    if (name == null || name.isEmpty) return '?';
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1)).toUpperCase();
  }
}
