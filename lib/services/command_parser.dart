import '../models/personal_lists.dart';
import '../models/time_log.dart';

/// What the parser understood from a spoken/typed command.
enum CommandKind {
  addEstimate,
  dismiss,
  followUp,
  priorityWatch,
  showList,
  logTime,
  todaySummary,
  organizeDay,
  unknown, // fall through to AI
}

class ParsedCommand {
  final CommandKind kind;
  final String? ticketKey;
  final double? hours;
  final WorkType? workType;
  final PersonalList? list;
  final String original;

  ParsedCommand(this.kind,
      {this.ticketKey, this.hours, this.workType, this.list, required this.original});
}

/// Parses commands locally using keywords + a ticket-key regex.
/// Only genuinely open-ended input returns `unknown` (then the app may ask AI).
class CommandParser {
  // Matches ABC-123 style keys (also tolerates spoken "ABC 123").
  static final _keyRegex = RegExp(r'\b([A-Z][A-Z0-9]+)[\s-]?(\d+)\b', caseSensitive: false);
  static final _hoursRegex =
      RegExp(r'(\d+(?:\.\d+)?)\s*(?:hours?|hrs?|h)\b', caseSensitive: false);

  ParsedCommand parse(String input) {
    final raw = input.trim();
    final lower = raw.toLowerCase();
    final key = _extractKey(raw);

    // ── Time logging: "log 2 hours on XSD-1 for development" ──
    final hoursMatch = _hoursRegex.firstMatch(lower);
    if ((lower.contains('log') || lower.contains('سجل') || hoursMatch != null) &&
        key != null &&
        hoursMatch != null) {
      return ParsedCommand(
        CommandKind.logTime,
        ticketKey: key,
        hours: double.tryParse(hoursMatch.group(1)!),
        workType: WorkTypeLabel.parse(lower),
        original: raw,
      );
    }

    // ── Today's logged time / EOD summary ──
    if (_has(lower, ['what have i logged', 'logged today', 'end of day', 'سجلت اليوم', 'ملخص']) &&
        key == null) {
      if (_has(lower, ['end of day', 'summary', 'ملخص'])) {
        return ParsedCommand(CommandKind.todaySummary, original: raw);
      }
      return ParsedCommand(CommandKind.todaySummary, original: raw);
    }

    // ── Organize my day / what did I forget ──
    if (_has(lower, [
      'organize',
      'organise',
      'plan my day',
      'what am i missing',
      'what did i forget',
      'forgot',
      'focus',
      'رتب',
      'نسيت',
      'ركز',
      'يومي'
    ])) {
      return ParsedCommand(CommandKind.organizeDay, original: raw);
    }

    // ── Personal list commands (need a ticket key) ──
    if (key != null) {
      if (_has(lower, ['estimate', 'تقدير'])) {
        return ParsedCommand(CommandKind.addEstimate,
            ticketKey: key, list: PersonalList.estimates, original: raw);
      }
      if (_has(lower, ['dismiss', 'hide', 'اخفي', 'احذف'])) {
        return ParsedCommand(CommandKind.dismiss,
            ticketKey: key, list: PersonalList.dismissed, original: raw);
      }
      if (_has(lower, ['follow', 'watch later', 'متابعة'])) {
        return ParsedCommand(CommandKind.followUp,
            ticketKey: key, list: PersonalList.followUp, original: raw);
      }
      if (_has(lower, ['priority', 'vip', 'star', 'مهم'])) {
        return ParsedCommand(CommandKind.priorityWatch,
            ticketKey: key, list: PersonalList.priorityWatch, original: raw);
      }
    }

    // ── Show a list ──
    if (_has(lower, ['show', 'list', 'my list', 'اعرض', 'قائمتي'])) {
      PersonalList? which;
      if (lower.contains('estimate')) which = PersonalList.estimates;
      if (lower.contains('follow')) which = PersonalList.followUp;
      if (lower.contains('dismiss')) which = PersonalList.dismissed;
      if (lower.contains('priority') || lower.contains('watch')) {
        which = PersonalList.priorityWatch;
      }
      return ParsedCommand(CommandKind.showList, list: which, original: raw);
    }

    // Genuinely open-ended → let the caller decide whether to ask the AI.
    return ParsedCommand(CommandKind.unknown, original: raw);
  }

  String? _extractKey(String raw) {
    final m = _keyRegex.firstMatch(raw);
    if (m == null) return null;
    final proj = m.group(1)!.toUpperCase();
    final num = m.group(2)!;
    // Avoid matching things like "2 hours" — project part must be letters.
    if (!RegExp(r'^[A-Z]').hasMatch(proj)) return null;
    return '$proj-$num';
  }

  bool _has(String text, List<String> needles) =>
      needles.any((n) => text.contains(n));
}
