import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/ticket.dart';
import '../models/settings.dart';

/// Typed outcome of a sync so the UI can react differently to auth vs network errors.
enum SyncErrorKind { none, network, auth, server, unknown }

class SyncResult {
  final List<Ticket> tickets;
  final SyncErrorKind error;
  final String? message;
  const SyncResult(this.tickets, {this.error = SyncErrorKind.none, this.message});

  bool get ok => error == SyncErrorKind.none;
}

class JiraService {
  final JiraCredentials creds;
  JiraService(this.creds);

  static const _fields =
      'summary,priority,status,assignee,project,created,updated,issuetype,description,statuscategorychangedate';

  Map<String, String> get _headers {
    final basic = base64Encode(utf8.encode('${creds.email}:${creds.token}'));
    return {
      'Authorization': 'Basic $basic',
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };
  }

  /// Fetch issues for a given JQL. Returns a typed result instead of throwing,
  /// so the UI can keep showing cached data on failure.
  Future<SyncResult> search(String jql, {int maxResults = 100}) async {
    final uri = Uri.https(creds.cleanDomain, '/rest/api/3/search/jql', {
      'jql': jql,
      'maxResults': '$maxResults',
      'fields': _fields,
    });

    try {
      final res = await http.get(uri, headers: _headers).timeout(const Duration(seconds: 20));

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        final issues = (data['issues'] as List? ?? [])
            .map((e) => Ticket.fromJson(e as Map<String, dynamic>))
            .toList();
        return SyncResult(issues);
      }
      if (res.statusCode == 401 || res.statusCode == 403) {
        return const SyncResult([],
            error: SyncErrorKind.auth, message: 'Your Jira token expired or is invalid.');
      }
      return SyncResult(const [],
          error: SyncErrorKind.server, message: 'Jira returned ${res.statusCode}.');
    } catch (e) {
      return SyncResult(const [],
          error: SyncErrorKind.network, message: 'Could not reach Jira. Check your connection.');
    }
  }

  /// Fetch a single ticket by key (used by "open / add by key").
  Future<Ticket?> fetchOne(String key, {bool asEstimate = false}) async {
    final uri = Uri.https(creds.cleanDomain, '/rest/api/3/issue/$key',
        {'fields': _fields});
    try {
      final res = await http.get(uri, headers: _headers).timeout(const Duration(seconds: 15));
      if (res.statusCode == 200) {
        return Ticket.fromJson(jsonDecode(res.body) as Map<String, dynamic>,
            isEstimateRequest: asEstimate);
      }
    } catch (_) {}
    return null;
  }

  /// Build the JQL for the "My tickets" scope.
  static String myJql(String customJql) {
    if (customJql.trim().isNotEmpty) return customJql.trim();
    return 'assignee = currentUser() OR reporter = currentUser() ORDER BY updated DESC';
  }

  /// Build the JQL for the "Team" scope from a list of member emails.
  static String teamJql(List<TeamMember> team) {
    final emails = team.map((m) => '"${m.email}"').join(', ');
    if (emails.isEmpty) {
      return 'assignee = currentUser() ORDER BY updated DESC';
    }
    return 'assignee in ($emails) ORDER BY updated DESC';
  }
}
