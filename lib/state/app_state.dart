import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:triage/models/ticket.dart';
import 'package:triage/models/settings.dart';
import 'package:triage/models/attention_item.dart';
import 'package:triage/models/time_log.dart';
import 'package:triage/services/jira_service.dart';
import 'package:triage/services/storage_service.dart';
import 'package:triage/services/update_service.dart';

enum ViewScope { mine, team }

enum ConnState { unconfigured, ok, offline, authError }

class AppState extends ChangeNotifier {
  final StorageService _storage = StorageService();
  final UpdateService _updates = UpdateService();

  AppSettings settings = AppSettings();
  JiraCredentials? _creds;
  JiraService? _jira;

  List<Ticket> _tickets = [];
  Map<String, int> _manualOrder = {};
  Set<String> _seenKeys = {};

  final AttentionStore attention = AttentionStore();
  final TimeTracker tracker = TimeTracker();

  ViewScope scope = ViewScope.mine;
  ConnState conn = ConnState.unconfigured;
  String? statusMessage;
  DateTime? lastSyncedAt;
  bool isSyncing = false;

  bool newBannerDismissed = false;

  UpdateInfo? availableUpdate;

  Timer? _pollTimer;
  Timer? _retryTimer;
  int _retryAttempt = 0;

  bool get isConfigured => _creds != null;

  Future<void> bootstrap() async {
    settings = await _storage.loadSettings();
    _manualOrder = await _storage.loadManualOrder();
    _seenKeys = await _storage.loadSeenKeys();
    _tickets = await _storage.loadCache();
    await attention.load();
    await tracker.load();

    final token = await _storage.readToken();
    if (settings.domain.isNotEmpty &&
        settings.email.isNotEmpty &&
        token != null) {
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

    // ignore: unawaited_futures
    _checkForUpdate();
  }

  Future<void> _checkForUpdate() async {
    final info = await _updates.checkForUpdate();
    if (info == null) return;
    availableUpdate = info;
    notifyListeners();
  }

  Future<void> dismissUpdate() async {
    final info = availableUpdate;
    if (info == null) return;
    availableUpdate = null;
    notifyListeners();
    await _updates.dismiss(info.version);
  }

  Future<void> openUpdatePage() async {
    final info = availableUpdate;
    if (info == null) return;
    final url = Uri.parse(info.htmlUrl);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
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

  Future<void> signOut() async {
    await _storage.clearToken();
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
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
    newBannerDismissed = false;
    _pollTimer?.cancel();
    _retryTimer?.cancel();
    notifyListeners();
  }

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

    final estimates = _tickets.where((t) => t.isEstimateRequest).toList();
    final byKey = {for (final t in fresh) t.key: t};

    if (fresh.any((t) => !_seenKeys.contains(t.key))) {
      newBannerDismissed = false;
    }

    final merged = [...fresh];
    for (final e in estimates) {
      if (!byKey.containsKey(e.key)) merged.add(e);
    }

    _applyManualOrder(merged);
    _tickets = merged;
    _seenKeys = fresh.map((t) => t.key).toSet()
      ..addAll(estimates.map((e) => e.key));

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
      _retryTimer?.cancel();
    } else {
      conn = ConnState.offline;
      _scheduleRetry();
    }
  }

  void _scheduleRetry() {
    _retryTimer?.cancel();
    const schedule = [30, 60, 120, 300];
    final secs = schedule[_retryAttempt.clamp(0, schedule.length - 1)];
    _retryAttempt++;
    _retryTimer = Timer(Duration(seconds: secs), sync);
  }

  void _applyManualOrder(List<Ticket> tickets) {
    for (final t in tickets) {
      t.manualOrder = _manualOrder[t.key] ?? 1 << 20;
    }
  }

  Future<void> reorderWithin(String status, List<Ticket> ordered) async {
    for (var i = 0; i < ordered.length; i++) {
      ordered[i].manualOrder = i;
      _manualOrder[ordered[i].key] = i;
    }
    await _storage.saveManualOrder(_manualOrder);
    notifyListeners();
  }

  List<Ticket> get _visibleTickets {
    return _tickets.where((t) {
      if (settings.hiddenProjectKeys.contains(t.projectKey)) return false;
      if (scope == ViewScope.team) {
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

  Map<String, List<Ticket>> get groupedByStatus {
    final map = <String, List<Ticket>>{};
    for (final t in _visibleTickets) {
      final bucket = t.isEstimateRequest ? 'Needs Attention' : t.status;
      if (!t.isEstimateRequest &&
          !settings.visibleStatuses.contains(t.status)) {
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

  Map<String, int> get statusCounts {
    final map = <String, int>{};
    for (final t in _visibleTickets) {
      if (t.isEstimateRequest) continue;
      map[t.status] = (map[t.status] ?? 0) + 1;
    }
    return map;
  }

  Map<String, ({String name, int count})> get projectsWithCounts {
    final map = <String, ({String name, int count})>{};
    for (final t in _tickets) {
      if (t.projectKey.isEmpty || t.isEstimateRequest) continue;
      map.putIfAbsent(t.projectKey, () => (name: t.projectName, count: 0));
    }
    for (final t in _tickets) {
      if (t.projectKey.isEmpty || t.isEstimateRequest) continue;
      if (!settings.visibleStatuses.contains(t.status)) continue;
      if (scope == ViewScope.team) {
        final visibleEmails = settings.team
            .where((m) => m.visible)
            .map((m) => m.email.toLowerCase())
            .toSet();
        if (t.assigneeEmail != null &&
            !visibleEmails.contains(t.assigneeEmail!.toLowerCase())) {
          continue;
        }
      }
      final e = map[t.projectKey]!;
      map[t.projectKey] = (name: e.name, count: e.count + 1);
    }
    return map;
  }

  int get newTicketCount => groupedByStatus['New']?.length ?? 0;

  void setScope(ViewScope s) {
    scope = s;
    notifyListeners();
    sync();
  }

  void dismissNewBanner() {
    newBannerDismissed = true;
    notifyListeners();
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

  List<Ticket> get allTickets => List.unmodifiable(_tickets);

  Future<void> openInBrowser(String key) async {
    if (_creds == null) return;
    final url = Uri.parse(_creds!.browseUrl(key));
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

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
