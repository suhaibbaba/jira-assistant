import 'package:flutter_test/flutter_test.dart';
import 'package:triage/services/update_service.dart';

void main() {
  group('UpdateService.isNewer', () {
    test('detects newer versions', () {
      expect(UpdateService.isNewer('1.7.0', '1.6.0'), isTrue);
      expect(UpdateService.isNewer('2.0.0', '1.9.9'), isTrue);
      expect(UpdateService.isNewer('1.6.1', '1.6.0'), isTrue);
      expect(UpdateService.isNewer('1.10.0', '1.9.0'), isTrue);
    });

    test('rejects same or older versions', () {
      expect(UpdateService.isNewer('1.6.0', '1.6.0'), isFalse);
      expect(UpdateService.isNewer('1.5.9', '1.6.0'), isFalse);
      expect(UpdateService.isNewer('0.9.0', '1.0.0'), isFalse);
    });

    test('tolerates short and suffixed versions', () {
      expect(UpdateService.isNewer('1.7', '1.6.0'), isTrue);
      expect(UpdateService.isNewer('1.6', '1.6.0'), isFalse);
      expect(UpdateService.isNewer('2.0.0-beta', '1.6.0'), isTrue);
    });
  });

  group('UpdateService.parseRelease', () {
    final release = {
      'tag_name': 'v1.8.0',
      'html_url': 'https://github.com/o/r/releases/tag/v1.8.0',
      'assets': [
        {
          'name': 'Xngage-v1.8.0-macos.dmg',
          'browser_download_url': 'https://example.com/mac.dmg',
        },
        {
          'name': 'Xngage-v1.8.0-windows-setup.exe',
          'browser_download_url': 'https://example.com/setup.exe',
        },
      ],
    };

    test('picks the installer for this platform', () {
      final win = UpdateService.parseRelease(release,
          currentVersion: '1.7.2', assetSuffix: '-windows-setup.exe')!;
      expect(win.version, '1.8.0');
      expect(win.assetUrl, 'https://example.com/setup.exe');
      expect(win.assetName, 'Xngage-v1.8.0-windows-setup.exe');

      final mac = UpdateService.parseRelease(release,
          currentVersion: '1.7.2', assetSuffix: '-macos.dmg')!;
      expect(mac.assetUrl, 'https://example.com/mac.dmg');
    });

    test('falls back to the release page when no installer matches', () {
      final info = UpdateService.parseRelease(release,
          currentVersion: '1.7.2', assetSuffix: null)!;
      expect(info.assetUrl, isNull);
      expect(info.htmlUrl, contains('/releases/tag/v1.8.0'));
    });

    test('ignores releases that are not newer', () {
      expect(
          UpdateService.parseRelease(release,
              currentVersion: '1.8.0', assetSuffix: '-macos.dmg'),
          isNull);
    });
  });
}
