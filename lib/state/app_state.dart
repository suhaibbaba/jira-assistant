import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/ticket.dart';
import '../models/settings.dart';
import '../models/attention_item.dart';
import '../models/time_log.dart';
import '../services/jira_service.dart';
import '../services/storage_service.dart';
import '../services/notification_service.dart';

enum ViewScope { mine, team }

enum ConnState { unconfigured, ok, offline, authError }

/// The single source of truth for the UI. Provided via ChangeNotifierProvider.
class AppState extends ChangeNotifier {
  final StorageService _storage = StorageService();

  AppSettings settings = AppSettings();
  JiraCredentials? _creds;
  JiraService? _jira;

  List<Ticket> _tickets = [];
  Map<String, int> _manualOrder = {};
  Set<String> _seenKeys = {};

  // Local-only data:
  final AttentionStore attention = AttentionStore();
  final TimeTracker tracker = TimeTracker();

  ViewScope scope = ViewScope.mine;
  ConnState conn = ConnState.unconfigured;
  String? statusMessage;
  DateTime? lastSyncedAt;
  bool isSyncing = false;

  Timer? _pollTimer;
  Timer? _retryTimer;
  int _retryAttempt = 0;

  bool get isConfigured => _creds != null;

  // ─────────────────────────── lifecycle ───────────────────────────

  Future<void> bootstrap() async {
    settings = await _storage.loadSettings();
    _manualOrder = await _storage.loadManualOrder();
    _seenKeys = await _storage.loadSeenKeys();
    _tickets = await _storage.loadCache();
    await attention.load();
    await tracker.load();

    final token = await _storage.readToken();
    if (settings.domain.isNotEmpty && settings.email.isNotEmpty && token != null) {
      _setCreds(JiraCredentials(
          domain: settings.domain, email: settings.email, token: token));
      conn = _tickets.isEmpty ? ConnState.unconfigured : ConnState.ok;
      _startPolling();
      // ignore: unawaited_futures
      sync();
    } else {
      conn = ConnState.unconfigured;
    }
    notifyListeners();
  }

  void _setCreds(JiraCredentials c) {
    _creds = c;
    _jira = JiraService(c);
  }

  JiraCredentials? get creds => _creds;

  Future<void> connect(String domain, String email, String token) async {
    settings.domain = domain;
    settings.email = email;
    await _storage.saveToken(token);
    await _storage.saveSettings(settings);
    _setCreds(JiraCredentials(domain: domain, email: email, token: token));
    _startPolling();
    await sync();
  }

  /// Full disconnect: wipes the token AND all stored data — email, domain,
  /// settings, cached tickets, personal lists, time logs, manual order.
  Future<void> signOut() async {
    await _storage.clearToken();
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // settings, cache, lists, time logs, seen keys, order
    settings = AppSettings();
    await attention.clearAll();
    _creds = null;
    _jira = null;
    _tickets = [];
    _manualOrder = {};
    _seenKeys = {};
    conn = ConnState.unconfigured;
    statusMessage = null;
    lastSyncedAt = null;
    _pollTimer?.cancel();
    _retryTimer?.cancel();
    notifyListeners();
  }

  // ─────────────────────────── syncing ───────────────────────────

  void _startPolling() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(
      Duration(minutes: settings.syncIntervalMinutes),
      (_) => sync(),
    );
  }

  void restartPolling() => _startPolling();

  Future<void> sync() async {
    if (_jira == null || isSyncing) return;
    isSyncing = true;
    notifyListeners();

    final jql = scope == ViewScope.mine
        ? JiraService.myJql(settings.jql)
        : JiraService.teamJql(settings.team);

    final result = await _jira!.search(jql);

    isSyncing = false;

    if (result.ok) {
      _onSyncSuccess(result.tickets);
    } else {
      _onSyncFailure(result);
    }
    notifyListeners();
  }

  void _onSyncSuccess(List<Ticket> fresh) {
    _retryTimer?.cancel();
    _retryAttempt = 0;

    // Preserve locally-added estimate-request tickets across syncs.
    final estimates = _tickets.where((t) => t.isEstimateRequest).toList();
    final byKey = {for (final t in fresh) t.key: t};

    // Detect new high-priority tickets for notifications.
    final newHighPriority = fresh.where((t) =>
        !_seenKeys.contains(t.key) &&
        settings.notifyPriorities.contains(t.priority));
    for (final t in newHighPriority) {
      // ignore: unawaited_futures
      NotificationService.newTicket(t.key, t.summary);
    }

    // Merge: fresh tickets + any estimates not already present.
    final merged = [...fresh];
    for (final e in estimates) {
      if (!byKey.containsKey(e.key)) merged.add(e);
    }

    _applyManualOrder(merged);
    _tickets = merged;
    _seenKeys = fresh.map((t) => t.key).toSet()..addAll(estimates.map((e) => e.key));

    conn = ConnState.ok;
    statusMessage = null;
    lastSyncedAt = DateTime.now();

    // ignore: unawaited_futures
    _storage.saveCache(_tickets);
    // ignore: unawaited_futures
    _storage.saveSeenKeys(_seenKeys);
  }

  void _onSyncFailure(SyncResult result) {
    statusMessage = result.message;
    if (result.error == SyncErrorKind.auth) {
      conn = ConnState.authError;
      _retryTimer?.cancel(); // no point retrying a bad token
    } else {
      conn = ConnState.offline;
      _scheduleRetry(); // exponential backoff
    }
  }

  void _scheduleRetry() {
    _retryTimer?.cancel();
    const schedule = [30, 60, 120, 300]; // seconds: 30s, 1m, 2m, 5m
    final secs = schedule[_retryAttempt.clamp(0, schedule.length - 1)];
    _retryAttempt++;
    _retryTimer = Timer(Duration(seconds: secs), sync);
  }

  // ─────────────────────────── manual order ───────────────────────────

  void _applyManualOrder(List<Ticket> tickets) {
    for (final t in tickets) {
      t.manualOrder = _manualOrder[t.key] ?? 1 << 20; // unranked → bottom
    }
  }

  /// Persist a new ordering for one status section after a drag.
  Future<void> reorderWithin(String status, List<Ticket> ordered) async {
    for (var i = 0; i < ordered.length; i++) {
      ordered[i].manualOrder = i;
      _manualOrder[ordered[i].key] = i;
    }
    await _storage.saveManualOrder(_manualOrder);
    notifyListeners();
  }

  // ─────────────────────────── derived views ───────────────────────────

  /// Tickets after applying project-hide, status-filter, and team-visibility.
  List<Ticket> get _visibleTickets {
    return _tickets.where((t) {
      if (settings.hiddenProjectKeys.contains(t.projectKey)) return false;
      if (scope == ViewScope.team) {
        // only show visible teammates' tickets (by email match)
        final visibleEmails = settings.team
            .where((m) => m.visible)
            .map((m) => m.email.toLowerCase())
            .toSet();
        if (t.assigneeEmail != null &&
            !visibleEmails.contains(t.assigneeEmail!.toLowerCase()) &&
            !t.isEstimateRequest) {
          return false;
        }
      }
      return true;
    }).toList();
  }

  /// Status → tickets, only for statuses currently ticked, each sorted by
  /// priority then manual order. Estimate-requested tickets get their own bucket.
  Map<String, List<Ticket>> get groupedByStatus {
    final map = <String, List<Ticket>>{};
    for (final t in _visibleTickets) {
      final bucket = t.isEstimateRequest ? 'Needs Attention' : t.status;
      if (!t.isEstimateRequest && !settings.visibleStatuses.contains(t.status)) {
        continue;
      }
      map.putIfAbsent(bucket, () => []).add(t);
    }
    for (final list in map.values) {
      list.sort((a, b) {
        final p = a.priorityRank.compareTo(b.priorityRank);
        if (p != 0) return p;
        return a.manualOrder.compareTo(b.manualOrder);
      });
    }
    return map;
  }

  /// Tickets that have aged past their per-status threshold.
  List<Ticket> get agingTickets {
    final rules = {for (final r in settings.agingRules) r.status: r};
    final result = _visibleTickets.where((t) {
      final rule = rules[t.status];
      if (rule == null || !rule.alertEnabled) return false;
      final days = settings.agingUsesBusinessDays
          ? t.businessDaysInStatus
          : t.calendarDaysInStatus;
      return days >= rule.thresholdDays;
    }).toList();
    result.sort((a, b) {
      final byTime = (b.timeInStatus ?? Duration.zero)
          .compareTo(a.timeInStatus ?? Duration.zero);
      if (byTime != 0) return byTime;
      return a.priorityRank.compareTo(b.priorityRank);
    });
    return result;
  }

  /// Projects the user actually has tickets on (for the hide-list).
  Map<String, ({String name, int count})> get projectsWithCounts {
    final map = <String, ({String name, int count})>{};
    for (final t in _tickets) {
      if (t.projectKey.isEmpty) continue;
      final existing = map[t.projectKey];
      map[t.projectKey] =
          (name: t.projectName, count: (existing?.count ?? 0) + 1);
    }
    return map;
  }

  int get newTicketCount =>
      groupedByStatus['New']?.length ?? 0;

  // ─────────────────────────── actions ───────────────────────────

  void setScope(ViewScope s) {
    scope = s;
    notifyListeners();
    sync();
  }

  void toggleStatusVisible(String status) {
    if (settings.visibleStatuses.contains(status)) {
      settings.visibleStatuses.remove(status);
    } else {
      settings.visibleStatuses.add(status);
    }
    _storage.saveSettings(settings);
    notifyListeners();
  }

  void toggleProjectHidden(String projectKey) {
    if (settings.hiddenProjectKeys.contains(projectKey)) {
      settings.hiddenProjectKeys.remove(projectKey);
    } else {
      settings.hiddenProjectKeys.add(projectKey);
    }
    _storage.saveSettings(settings);
    notifyListeners();
  }

  void toggleTeamMemberVisible(TeamMember m) {
    m.visible = !m.visible;
    _storage.saveSettings(settings);
    notifyListeners();
  }

  Future<void> addTeamMember(String name, String email) async {
    settings.team.add(TeamMember(name: name, email: email));
    await _storage.saveSettings(settings);
    notifyListeners();
  }

  Future<void> removeTeamMember(TeamMember m) async {
    settings.team.remove(m);
    await _storage.saveSettings(settings);
    notifyListeners();
  }

  Future<void> saveSettings() async {
    await _storage.saveSettings(settings);
    _startPolling();
    notifyListeners();
  }

  /// Live tickets, unfiltered.
  List<Ticket> get allTickets => List.unmodifiable(_tickets);

  /// Open a ticket in the browser (clicking the key or the link icon).
  Future<void> openInBrowser(String key) async {
    if (_creds == null) return;
    final url = Uri.parse(_creds!.browseUrl(key));
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  /// Add a ticket to the "Needs Attention" section, recording who sent it
  /// and when. Returns false if the ticket key doesn't exist in Jira.
  Future<bool> addAttention(String key, String requestedBy) async {
    if (_jira == null) return false;
    final cleanKey = key.trim().toUpperCase();
    final t = await _jira!.fetchOne(cleanKey, asEstimate: true);
    if (t == null) return false;
    await attention.add(cleanKey, requestedBy);
    if (!_tickets.any((x) => x.key == t.key && x.isEstimateRequest)) {
      _tickets.add(t);
      await _storage.saveCache(_tickets);
    }
    notifyListeners();
    return true;
  }

  /// Mark an attention item as done: removes it from the section.
  Future<void> markAttentionDone(String key) async {
    await attention.markDone(key);
    _tickets.removeWhere((t) => t.key == key && t.isEstimateRequest);
    await _storage.saveCache(_tickets);
    notifyListeners();
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _retryTimer?.cancel();
    super.dispose();
  }
}
