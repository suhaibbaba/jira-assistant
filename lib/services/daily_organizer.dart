import '../models/ticket.dart';
import '../models/settings.dart';

/// A single suggested focus item with a human-readable reason.
class FocusItem {
  final Ticket ticket;
  final String reason; // e.g. "Highest priority, new for 3 days"
  final int score; // higher = more urgent
  FocusItem(this.ticket, this.reason, this.score);
}

class DailyPlan {
  final List<FocusItem> focus; // top things to act on today
  final List<FocusItem> forgotten; // aged / no-estimate items slipping through
  DailyPlan(this.focus, this.forgotten);

  bool get isEmpty => focus.isEmpty && forgotten.isEmpty;
}

/// Builds a prioritized daily plan from tickets using transparent rules.
/// No network, no AI — fully local and free.
class DailyOrganizer {
  final AppSettings settings;
  final Set<String> followUpKeys;
  final Set<String> priorityWatchKeys;
  final Set<String> estimateKeys;

  DailyOrganizer({
    required this.settings,
    this.followUpKeys = const {},
    this.priorityWatchKeys = const {},
    this.estimateKeys = const {},
  });

  DailyPlan build(List<Ticket> tickets) {
    final scored = <FocusItem>[];
    final forgotten = <FocusItem>[];

    for (final t in tickets) {
      final reasons = <String>[];
      var score = 0;

      // Priority weight (Highest=50 ... Lowest=10)
      score += (5 - t.priorityRank).clamp(0, 5) * 10;

      // Personal VIP watch
      if (priorityWatchKeys.contains(t.key)) {
        score += 40;
        reasons.add('on your Priority Watch');
      }

      // Follow-up list
      if (followUpKeys.contains(t.key)) {
        score += 25;
        reasons.add('marked Follow Up');
      }

      // Aging in current status (per-status threshold)
      final rule = settings.agingRules
          .where((r) => r.status == t.status && r.alertEnabled)
          .firstOrNull;
      final days = settings.agingUsesBusinessDays
          ? t.businessDaysInStatus
          : t.calendarDaysInStatus;
      if (rule != null && days >= rule.thresholdDays) {
        score += 30 + days * 2;
        reasons.add('${t.status} for $days day${days == 1 ? '' : 's'}');
        forgotten.add(FocusItem(t, _capitalize(reasons.last), score));
      }

      // Missing estimate (in the estimates-needed list)
      if (estimateKeys.contains(t.key)) {
        score += 20;
        reasons.add('no estimate yet');
        forgotten.add(FocusItem(t, 'No estimate yet', score));
      }

      // New & untriaged is inherently urgent
      if (t.status == 'New') {
        score += 15;
        if (!reasons.any((r) => r.startsWith('New'))) {
          reasons.add('new, needs triage');
        }
      }

      if (reasons.isNotEmpty || t.priorityRank <= 1) {
        final reason = reasons.isEmpty
            ? '${t.priority} priority'
            : _capitalize(reasons.join(' · '));
        scored.add(FocusItem(t, reason, score));
      }
    }

    scored.sort((a, b) => b.score.compareTo(a.score));
    forgotten.sort((a, b) => b.score.compareTo(a.score));

    // Top 5 focus items, de-duplicated forgotten list.
    final focus = scored.take(5).toList();
    final seenForgotten = <String>{};
    final uniqueForgotten = <FocusItem>[];
    for (final f in forgotten) {
      if (seenForgotten.add(f.ticket.key)) uniqueForgotten.add(f);
    }

    return DailyPlan(focus, uniqueForgotten);
  }

  /// A spoken/printed natural-language version of the plan (for Jarvis TTS).
  String spokenSummary(DailyPlan plan) {
    if (plan.isEmpty) {
      return "You're all clear. Nothing urgent is waiting on you right now.";
    }
    final b = StringBuffer();
    if (plan.focus.isNotEmpty) {
      b.write("Here's your focus for today. ");
      for (var i = 0; i < plan.focus.length; i++) {
        final f = plan.focus[i];
        b.write("${i + 1}. ${f.ticket.key}, ${f.reason}. ");
      }
    }
    if (plan.forgotten.isNotEmpty) {
      b.write("You may have forgotten ");
      b.write(plan.forgotten.take(3).map((f) => f.ticket.key).join(', '));
      b.write(". ");
    }
    return b.toString();
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}

extension _FirstOrNull<E> on Iterable<E> {
  E? get firstOrNull => isEmpty ? null : first;
}
