import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/ticket.dart';

/// Optional AI fallback for open-ended questions the local parser can't handle.
/// Designed to be token-light: it sends only compact one-line ticket summaries
/// (key, priority, status, days-in-status, project) — never full descriptions.
///
/// The user supplies their own Anthropic API key in settings. If absent, the
/// app simply tells the user it didn't understand, and nothing is sent anywhere.
class AiAssistant {
  final String apiKey;
  AiAssistant(this.apiKey);

  bool get enabled => apiKey.trim().isNotEmpty;

  /// Build a tiny context string — one short line per ticket.
  static String _compactContext(List<Ticket> tickets) {
    final lines = tickets.take(60).map((t) {
      final age = t.timeInStatus?.inDays ?? 0;
      return '${t.key} | ${t.priority} | ${t.status} | ${age}d | ${t.projectKey}';
    });
    return lines.join('\n');
  }

  /// Ask a free-form question. Returns the assistant's text answer, or an error
  /// message string. Keeps max_tokens small to control cost.
  Future<String> ask(String question, List<Ticket> tickets) async {
    if (!enabled) {
      return "I didn't catch that. Try a command like “add XSD-1 for estimates”, "
          "or turn on AI answers in Settings for open questions.";
    }

    final context = _compactContext(tickets);
    final system =
        'You are Jarvis, a concise Jira triage assistant. You are given a compact '
        'table of the user\'s tickets: KEY | PRIORITY | STATUS | DAYS_IN_STATUS | PROJECT. '
        'Answer briefly and practically. Refer to tickets by key. Do not invent tickets.';

    final body = jsonEncode({
      'model': 'claude-haiku-4-5-20251001', // cheapest, fast — good for short Q&A
      'max_tokens': 350,
      'system': system,
      'messages': [
        {
          'role': 'user',
          'content': 'Tickets:\n$context\n\nQuestion: $question',
        }
      ],
    });

    try {
      final res = await http
          .post(
            Uri.parse('https://api.anthropic.com/v1/messages'),
            headers: {
              'content-type': 'application/json',
              'x-api-key': apiKey,
              'anthropic-version': '2023-06-01',
            },
            body: body,
          )
          .timeout(const Duration(seconds: 25));

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        final content = (data['content'] as List?) ?? [];
        final text = content
            .where((b) => b['type'] == 'text')
            .map((b) => b['text'] as String)
            .join('\n')
            .trim();
        return text.isEmpty ? "I'm not sure how to answer that." : text;
      }
      if (res.statusCode == 401) {
        return 'Your AI key was rejected. Check it in Settings.';
      }
      return 'AI service error (${res.statusCode}). Try again later.';
    } catch (_) {
      return "I couldn't reach the AI service. Check your connection.";
    }
  }
}
