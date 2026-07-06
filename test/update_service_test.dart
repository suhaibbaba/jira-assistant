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
}
