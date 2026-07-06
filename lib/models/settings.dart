import 'dart:convert';

class JiraCredentials {
  final String domain;
  final String email;
  final String token;

  const JiraCredentials({required this.domain, required this.email, required this.token});

  String get cleanDomain =>
      domain.replaceAll(RegExp(r'^https?://'), '').replaceAll(RegExp(r'/+$'), '');

  String browseUrl(String key) => 'https://$cleanDomain/browse/$key';
}

class StatusAgingRule {
  final String status;
  bool alertEnabled;
  int thresholdDays;

  StatusAgingRule({
    required this.status,
    required this.alertEnabled,
    required this.thresholdDays,
  });

  Map<String, dynamic> toJson() =>
      {'status': status, 'enabled': alertEnabled, 'days': thresholdDays};

  factory StatusAgingRule.fromJson(Map<String, dynamic> j) => StatusAgingRule(
        status: j['status'],
        alertEnabled: j['enabled'] ?? false,
        thresholdDays: j['days'] ?? 2,
      );
}

class TeamMember {
  final String name;
  final String email;
  bool visible;

  TeamMember({required this.name, required this.email, this.visible = true});

  Map<String, dynamic> toJson() => {'name': name, 'email': email, 'visible': visible};
  factory TeamMember.fromJson(Map<String, dynamic> j) =>
      TeamMember(name: j['name'] ?? '', email: j['email'] ?? '', visible: j['visible'] ?? true);
}

class AppSettings {
  String domain;
  String email;
  String jql;

  int syncIntervalMinutes;
  bool agingUsesBusinessDays;
  String morningDigestTime;
  bool morningDigestEnabled;

  int estimateReminderHours;

  List<StatusAgingRule> agingRules;
  List<TeamMember> team;
  Set<String> hiddenProjectKeys;
  Set<String> visibleStatuses;

  AppSettings({
    this.domain = '',
    this.email = '',
    this.jql = '',
    this.syncIntervalMinutes = 15,
    this.agingUsesBusinessDays = true,
    this.morningDigestTime = '08:30',
    this.morningDigestEnabled = true,
    this.estimateReminderHours = 4,
    List<StatusAgingRule>? agingRules,
    List<TeamMember>? team,
    Set<String>? hiddenProjectKeys,
    Set<String>? visibleStatuses,
  })  : agingRules = agingRules ?? _defaultAgingRules(),
        team = team ?? [],
        hiddenProjectKeys = hiddenProjectKeys ?? {},
        visibleStatuses = visibleStatuses ??
            {'New', 'Blocked', 'Need Clarification', 'In Progress', 'Review'};

  static List<StatusAgingRule> _defaultAgingRules() => [
        StatusAgingRule(status: 'New', alertEnabled: true, thresholdDays: 1),
        StatusAgingRule(status: 'Blocked', alertEnabled: true, thresholdDays: 2),
        StatusAgingRule(status: 'Need Clarification', alertEnabled: true, thresholdDays: 2),
        StatusAgingRule(status: 'In Progress', alertEnabled: false, thresholdDays: 0),
        StatusAgingRule(status: 'Review', alertEnabled: false, thresholdDays: 0),
      ];

  String toRawJson() => jsonEncode({
        'domain': domain,
        'email': email,
        'jql': jql,
        'sync': syncIntervalMinutes,
        'business': agingUsesBusinessDays,
        'digestTime': morningDigestTime,
        'digestOn': morningDigestEnabled,
        'estHours': estimateReminderHours,
        'aging': agingRules.map((r) => r.toJson()).toList(),
        'team': team.map((m) => m.toJson()).toList(),
        'hidden': hiddenProjectKeys.toList(),
        'statuses': visibleStatuses.toList(),
      });

  factory AppSettings.fromRawJson(String raw) {
    final j = jsonDecode(raw) as Map<String, dynamic>;
    return AppSettings(
      domain: j['domain'] ?? '',
      email: j['email'] ?? '',
      jql: j['jql'] ?? '',
      syncIntervalMinutes: j['sync'] ?? 15,
      agingUsesBusinessDays: j['business'] ?? true,
      morningDigestTime: j['digestTime'] ?? '08:30',
      morningDigestEnabled: j['digestOn'] ?? true,
      estimateReminderHours: j['estHours'] ?? 4,
      agingRules: (j['aging'] as List?)
              ?.map((e) => StatusAgingRule.fromJson(e))
              .toList() ??
          _defaultAgingRules(),
      team: (j['team'] as List?)?.map((e) => TeamMember.fromJson(e)).toList() ?? [],
      hiddenProjectKeys: ((j['hidden'] as List?)?.cast<String>() ?? []).toSet(),
      visibleStatuses: ((j['statuses'] as List?)?.cast<String>() ??
              ['New', 'Blocked', 'Need Clarification', 'In Progress', 'Review'])
          .toSet(),
    );
  }
}
