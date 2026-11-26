import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:triage/config/app_info.dart';

/// A newer release found on GitHub.
class UpdateInfo {
  final String version;

  /// The release page — fallback when there's no installer for this OS.
  final String htmlUrl;

  /// Direct download of this platform's installer, if the release has one.
  final String? assetUrl;
  final String? assetName;

  const UpdateInfo({
    required this.version,
    required this.htmlUrl,
    this.assetUrl,
    this.assetName,
  });
}

/// Checks GitHub Releases for a newer version and installs it.
///
/// - Windows: downloads `*-windows-setup.exe` in the background; [install]
///   runs it silently (Inno Setup closes the app, upgrades, and relaunches it).
/// - macOS: the sandboxed app can't replace itself, so [install] opens the
///   `*-macos.dmg` download in the browser; the user drags it to Applications.
///
/// Asset names come from .github/workflows/release.yml — keep them in sync.
class UpdateService {
  static const _owner = 'suhaibbaba';
  static const _repo = 'jira-assistant';

  static const _kDismissedVersion = 'update_dismissed_version';

  static Uri get _latestReleaseUri =>
      Uri.https('api.github.com', '/repos/$_owner/$_repo/releases/latest');

  /// Returns the newer release, or null if up to date, dismissed or offline.
  Future<UpdateInfo?> checkForUpdate() async {
    UpdateInfo? found;
    try {
      final res = await http.get(_latestReleaseUri, headers: {
        'Accept': 'application/vnd.github+json',
      }).timeout(const Duration(seconds: 10));
      if (res.statusCode != 200) return null;
      found = parseRelease(
        jsonDecode(res.body) as Map<String, dynamic>,
        currentVersion: AppInfo.appVersion,
        assetSuffix: _assetSuffix,
      );
    } catch (e) {
      debugPrint('[Update] check failed: $e');
      return null;
    }
    if (found == null) return null;

    final prefs = await SharedPreferences.getInstance();
    if (prefs.getString(_kDismissedVersion) == found.version) return null;
    return found;
  }

  Future<void> dismiss(String version) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kDismissedVersion, version);
  }

  /// Whether this platform installs updates by itself (vs. a manual download).
  static bool get canAutoInstall => Platform.isWindows;

  /// Windows: downloads the installer to the temp folder and returns its path.
  /// Returns null on other platforms or if the download fails.
  Future<String?> download(UpdateInfo info) async {
    if (!canAutoInstall || info.assetUrl == null) return null;
    final client = http.Client();
    try {
      final res = await client
          .send(http.Request('GET', Uri.parse(info.assetUrl!)))
          .timeout(const Duration(seconds: 30));
      if (res.statusCode != 200) return null;
      final dir = await Directory.systemTemp.createTemp('xngage-update-');
      final file =
          File('${dir.path}${Platform.pathSeparator}${info.assetName}');
      await res.stream.pipe(file.openWrite());
      if (res.contentLength != null &&
          await file.length() != res.contentLength) {
        return null;
      }
      return file.path;
    } catch (e) {
      debugPrint('[Update] download failed: $e');
      return null;
    } finally {
      client.close();
    }
  }

  /// Windows: runs the downloaded installer silently, then quits so it can
  /// replace the app; the installer relaunches the new version.
  /// macOS / fallback: opens the installer download (or release page).
  Future<void> install(UpdateInfo info, {String? downloadedPath}) async {
    if (canAutoInstall && downloadedPath != null) {
      await Process.start(
        downloadedPath,
        const [
          '/VERYSILENT',
          '/SUPPRESSMSGBOXES',
          '/NORESTART',
          '/CLOSEAPPLICATIONS',
        ],
        mode: ProcessStartMode.detached,
      );
      exit(0);
    }
    final url = Uri.parse(info.assetUrl ?? info.htmlUrl);
    await launchUrl(url, mode: LaunchMode.externalApplication);
  }

  static String? get _assetSuffix {
    if (Platform.isWindows) return '-windows-setup.exe';
    if (Platform.isMacOS) return '-macos.dmg';
    return null;
  }

  /// Turns a GitHub "latest release" response into an [UpdateInfo] when it's
  /// newer than [currentVersion].
  @visibleForTesting
  static UpdateInfo? parseRelease(
    Map<String, dynamic> json, {
    required String currentVersion,
    required String? assetSuffix,
  }) {
    final tag = (json['tag_name'] ?? '').toString();
    final url = (json['html_url'] ?? '').toString();
    final version = tag.startsWith('v') ? tag.substring(1) : tag;
    if (version.isEmpty || url.isEmpty || !isNewer(version, currentVersion)) {
      return null;
    }
    Map<String, dynamic>? asset;
    if (assetSuffix != null) {
      for (final a in (json['assets'] as List? ?? const [])) {
        if (a is Map<String, dynamic> &&
            (a['name'] ?? '').toString().endsWith(assetSuffix)) {
          asset = a;
          break;
        }
      }
    }
    return UpdateInfo(
      version: version,
      htmlUrl: url,
      assetUrl: asset?['browser_download_url']?.toString(),
      assetName: asset?['name']?.toString(),
    );
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
}
