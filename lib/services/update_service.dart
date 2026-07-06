import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:triage/config/app_info.dart';

class UpdateInfo {
  final String version;

  final String htmlUrl;

  const UpdateInfo({required this.version, required this.htmlUrl});
}

class UpdateService {
  static const _owner = '<OWNER>';
  static const _repo = '<REPO>';

  static const _kLastChecked = 'update_last_checked_on';
  static const _kDismissedVersion = 'update_dismissed_version';

  static Uri get _latestReleaseUri =>
      Uri.https('api.github.com', '/repos/$_owner/$_repo/releases/latest');

  Future<UpdateInfo?> checkForUpdate({bool force = false}) async {
    if (_owner.startsWith('<')) return null;

    final prefs = await SharedPreferences.getInstance();
    final today = _todayStamp();
    if (!force && prefs.getString(_kLastChecked) == today) return null;

    UpdateInfo? found;
    try {
      final res = await http.get(_latestReleaseUri, headers: {
        'Accept': 'application/vnd.github+json',
      }).timeout(const Duration(seconds: 10));
      if (res.statusCode == 200) {
        final json = jsonDecode(res.body) as Map<String, dynamic>;
        final tag = (json['tag_name'] ?? '').toString();
        final url = (json['html_url'] ?? '').toString();
        final version = tag.startsWith('v') ? tag.substring(1) : tag;
        if (version.isNotEmpty &&
            url.isNotEmpty &&
            isNewer(version, AppInfo.appVersion)) {
          found = UpdateInfo(version: version, htmlUrl: url);
        }
      }
      await prefs.setString(_kLastChecked, today);
    } catch (e) {
      debugPrint('[Update] check failed: $e');
      return null;
    }

    if (found != null && prefs.getString(_kDismissedVersion) == found.version) {
      return null;
    }
    return found;
  }

  Future<void> dismiss(String version) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kDismissedVersion, version);
  }

  @visibleForTesting
  static bool isNewer(String candidate, String current) {
    List<int> parse(String v) => v
        .split('-')
        .first
        .split('.')
        .map((p) => int.tryParse(p.trim()) ?? 0)
        .toList();
    final a = parse(candidate);
    final b = parse(current);
    for (var i = 0; i < 3; i++) {
      final x = i < a.length ? a[i] : 0;
      final y = i < b.length ? b[i] : 0;
      if (x != y) return x > y;
    }
    return false;
  }

  static String _todayStamp() {
    final now = DateTime.now();
    return '${now.year}-${now.month}-${now.day}';
  }
}
