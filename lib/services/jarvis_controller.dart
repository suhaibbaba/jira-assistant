import 'package:flutter/foundation.dart';

import '../models/ticket.dart';
import '../models/personal_lists.dart';
import '../models/time_log.dart';
import '../models/settings.dart';
import 'command_parser.dart';
import 'daily_organizer.dart';
import 'ai_assistant.dart';
import 'voice_service.dart';

/// One line in the Jarvis chat transcript.
class ChatLine {
  final bool fromUser;
  final String text;
  ChatLine(this.fromUser, this.text);
}

/// The brain of Jarvis: takes text (typed or transcribed), tries to handle it
/// locally, and only calls the AI for genuinely open-ended questions.
class JarvisController extends ChangeNotifier {
  final CommandParser _parser = CommandParser();
  final VoiceService voice = VoiceService();

  final List<ChatLine> transcript = [];
  bool listening = false;
  String partialTranscript = '';

  // Injected accessors to live app data:
  final List<Ticket> Function() getTickets;
  final PersonalLists Function() getLists;
  final TimeTracker Function() getTracker;
  final AppSettings Function() getSettings;
  final String Function() getAiKey;
  final Future<void> Function() persistLists;

  JarvisController({
    required this.getTickets,
    required this.getLists,
    required this.getTracker,
    required this.getSettings,
    required this.getAiKey,
    required this.persistLists,
  });

  Future<void> init() => voice.init();

  // ─────────────────── voice control ───────────────────

  Future<void> toggleListening() async {
    if (listening) {
      await voice.stopListening();
      listening = false;
      if (partialTranscript.trim().isNotEmpty) {
        final text = partialTranscript.trim();
        partialTranscript = '';
        await handle(text);
      }
      notifyListeners();
      return;
    }
    listening = true;
    partialTranscript = '';
    notifyListeners();
    await voice.startListening((text, isFinal) {
      partialTranscript = text;
      notifyListeners();
      if (isFinal) {
        listening = false;
        partialTranscript = '';
        notifyListeners();
        handle(text);
      }
    });
  }

  // ─────────────────── command handling ───────────────────

  Future<void> handle(String input) async {
    if (input.trim().isEmpty) return;
    transcript.add(ChatLine(true, input));
    notifyListeners();

    final cmd = _parser.parse(input);
    final reply = await _execute(cmd);

    transcript.add(ChatLine(false, reply));
    notifyListeners();
    await voice.speak(reply);
  }

  Future<String> _execute(ParsedCommand cmd) async {
    final lists = getLists();
    switch (cmd.kind) {
      case CommandKind.addEstimate:
        lists.add(PersonalList.estimates, cmd.ticketKey!);
        await persistLists();
        return 'Added ${cmd.ticketKey} to Estimates Needed.';

      case CommandKind.dismiss:
        lists.add(PersonalList.dismissed, cmd.ticketKey!);
        await persistLists();
        return 'Dismissed ${cmd.ticketKey}.';

      case CommandKind.followUp:
        lists.add(PersonalList.followUp, cmd.ticketKey!);
        await persistLists();
        return 'Marked ${cmd.ticketKey} as Follow Up.';

      case CommandKind.priorityWatch:
        lists.add(PersonalList.priorityWatch, cmd.ticketKey!);
        await persistLists();
        return 'Added ${cmd.ticketKey} to your Priority Watch.';

      case CommandKind.showList:
        final list = cmd.list ?? PersonalList.followUp;
        final keys = lists.of(list);
        if (keys.isEmpty) return 'Your ${list.label} list is empty.';
        return '${list.label}: ${keys.join(', ')}.';

      case CommandKind.logTime:
        await getTracker().add(TimeLog(
          ticketKey: cmd.ticketKey!,
          hours: cmd.hours ?? 1,
          type: cmd.workType ?? WorkType.other,
          loggedAt: DateTime.now(),
        ));
        return 'Logged ${_fmt(cmd.hours ?? 1)} hours on ${cmd.ticketKey} '
            'for ${(cmd.workType ?? WorkType.other).label}.';

      case CommandKind.todaySummary:
        final tracker = getTracker();
        final today = tracker.today;
        if (today.isEmpty) return "You haven't logged any time today yet.";
        return 'Today you logged ${_fmt(tracker.totalHours(today))} hours across '
            '${today.map((l) => l.ticketKey).toSet().length} tickets.';

      case CommandKind.organizeDay:
        return _organize();

      case CommandKind.unknown:
        return _askAi(cmd.original);
    }
  }

  String _organize() {
    final lists = getLists();
    final organizer = DailyOrganizer(
      settings: getSettings(),
      followUpKeys: lists.of(PersonalList.followUp),
      priorityWatchKeys: lists.of(PersonalList.priorityWatch),
      estimateKeys: lists.of(PersonalList.estimates),
    );
    // Exclude dismissed tickets from planning.
    final tickets = getTickets()
        .where((t) => !lists.contains(PersonalList.dismissed, t.key))
        .toList();
    final plan = organizer.build(tickets);
    return organizer.spokenSummary(plan);
  }

  Future<String> _askAi(String question) async {
    final ai = AiAssistant(getAiKey());
    if (!ai.enabled) {
      return "I didn't quite get that. You can say things like "
          "“organize my day”, “add XSD-1 for estimates”, or "
          "“log 2 hours on XSD-1 for development”.";
    }
    return ai.ask(question, getTickets());
  }

  void typeCommand(String text) => handle(text);

  @override
  void dispose() {
    voice.stopListening();
    voice.shutUp();
    super.dispose();
  }

  String _fmt(double h) =>
      h == h.roundToDouble() ? h.toStringAsFixed(0) : h.toStringAsFixed(1);
}
