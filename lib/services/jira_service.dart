import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:triage/models/ticket.dart';
import 'package:triage/models/settings.dart';

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
    };
  }

  /// Fetch issues for a given JQL using the current /search/jql endpoint
  /// (the old /rest/api/3/search was retired by Atlassian).
  /// Returns a typed result instead of throwing, so the UI can keep showing
  /// cached data on failure — and includes the real status code + body snippet
  /// in the message so errors are diagnosable.
  Future<SyncResult> search(String jql, {int maxResults = 100}) async {
    if (creds.email.trim().isEmpty || creds.token.trim().isEmpty) {
      return const SyncResult([],
          error: SyncErrorKind.auth,
          message: 'Missing email or token — reconnect.');
    }

    final uri = Uri.https(creds.cleanDomain, '/rest/api/3/search/jql', {
      'jql': jql,
      'maxResults': '$maxResults',
      'fields': _fields,
    });

    debugPrint('[Jira] GET $uri');

    try {
      final res =
          await http.get(uri, headers: _headers).timeout(const Duration(seconds: 20));

      debugPrint('[Jira] status ${res.statusCode}');

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        final issues = (data['issues'] as List? ?? [])
            .map((e) => Ticket.fromJson(e as Map<String, dynamic>))
            .toList();
        return SyncResult(issues);
      }
      if (res.statusCode == 401) {
        return const SyncResult([],
            error: SyncErrorKind.auth,
            message: '401 Unauthorized — check email + API token.');
      }
      if (res.statusCode == 403) {
        return const SyncResult([],
            error: SyncErrorKind.auth,
            message: '403 Forbidden — the token is missing a required scope.');
      }
      // Any other status: include a snippet of the body so it's diagnosable.
      final snippet =
          res.body.length > 200 ? '${res.body.substring(0, 200)}…' : res.body;
      return SyncResult(const [],
          error: SyncErrorKind.server,
          message: 'Jira returned ${res.statusCode}: $snippet');
    } catch (e) {
      debugPrint('[Jira] exception: $e');
      return SyncResult(const [],
          error: SyncErrorKind.network,
          message: 'Could not reach Jira: ${e.runtimeType}');
    }
  }

  /// Fetch a single ticket by key (used by "add by key" / estimate lane).
  Future<Ticket?> fetchOne(String key, {bool asEstimate = false}) async {
    final uri =
        Uri.https(creds.cleanDomain, '/rest/api/3/issue/$key', {'fields': _fields});
    try {
      final res =
          await http.get(uri, headers: _headers).timeout(const Duration(seconds: 15));
      if (res.statusCode == 200) {
        return Ticket.fromJson(jsonDecode(res.body) as Map<String, dynamic>,
            isEstimateRequest: asEstimate);
      }
    } catch (_) {}
    return null;
  }

  /// JQL for the "My tickets" scope: tickets ASSIGNED to you and still open.
  static String myJql(String customJql) {
    if (customJql.trim().isNotEmpty) return customJql.trim();
    return 'assignee = currentUser() AND resolution = EMPTY ORDER BY updated DESC';
  }

  /// JQL for the "Team" scope from a list of member emails.
  static String teamJql(List<TeamMember> team) {
    final emails = team.map((m) => '"${m.email}"').join(', ');
    if (emails.isEmpty) {
      return 'assignee = currentUser() AND resolution = EMPTY ORDER BY updated DESC';
    }
    return 'assignee in ($emails) AND resolution = EMPTY ORDER BY updated DESC';
  }
}
