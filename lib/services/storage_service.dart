import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:triage/models/settings.dart';
import 'package:triage/models/ticket.dart';

class StorageService {
  static const _kToken = 'jira_token';
  static const _kSettings = 'app_settings';
  static const _kManualOrder = 'manual_order';
  static const _kCache = 'ticket_cache';
  static const _kSeenKeys = 'seen_keys';

  final _secure = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  Future<void> saveToken(String token) => _secure.write(key: _kToken, value: token);
  Future<String?> readToken() => _secure.read(key: _kToken);
  Future<void> clearToken() => _secure.delete(key: _kToken);

  Future<void> saveSettings(AppSettings s) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kSettings, s.toRawJson());
  }

  Future<AppSettings> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kSettings);
    if (raw == null) return AppSettings();
    try {
      return AppSettings.fromRawJson(raw);
    } catch (_) {
      return AppSettings();
    }
  }

  Future<void> saveManualOrder(Map<String, int> order) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kManualOrder, jsonEncode(order));
  }

  Future<Map<String, int>> loadManualOrder() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kManualOrder);
    if (raw == null) return {};
    final m = jsonDecode(raw) as Map<String, dynamic>;
    return m.map((k, v) => MapEntry(k, v as int));
  }

  Future<void> saveCache(List<Ticket> tickets) async {
    final prefs = await SharedPreferences.getInstance();
    final list = tickets
        .map((t) => {
              'key': t.key,
              'summary': t.summary,
              'description': t.description,
              'status': t.status,
              'priority': t.priority,
              'issueType': t.issueType,
              'projectKey': t.projectKey,
              'projectName': t.projectName,
              'assigneeName': t.assigneeName,
              'assigneeEmail': t.assigneeEmail,
              'updated': t.updated?.toIso8601String(),
              'statusChangedAt': t.statusChangedAt?.toIso8601String(),
              'isEstimateRequest': t.isEstimateRequest,
            })
        .toList();
    await prefs.setString(_kCache, jsonEncode(list));
  }

  Future<List<Ticket>> loadCache() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kCache);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List;
    return list.map((e) {
      final m = e as Map<String, dynamic>;
      return Ticket(
        key: m['key'],
        summary: m['summary'] ?? '',
        description: m['description'] ?? '',
        status: m['status'] ?? 'Unknown',
        priority: m['priority'] ?? 'None',
        issueType: m['issueType'] ?? '',
        projectKey: m['projectKey'] ?? '',
        projectName: m['projectName'] ?? '',
        assigneeName: m['assigneeName'],
        assigneeEmail: m['assigneeEmail'],
        updated: m['updated'] != null ? DateTime.tryParse(m['updated']) : null,
        statusChangedAt:
            m['statusChangedAt'] != null ? DateTime.tryParse(m['statusChangedAt']) : null,
        isEstimateRequest: m['isEstimateRequest'] ?? false,
      );
    }).toList();
  }

  Future<Set<String>> loadSeenKeys() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getStringList(_kSeenKeys) ?? []).toSet();
  }

  Future<void> saveSeenKeys(Set<String> keys) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_kSeenKeys, keys.toList());
  }
}
