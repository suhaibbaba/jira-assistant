import 'package:local_notifier/local_notifier.dart';

/// Thin wrapper over local_notifier for native Mac & Windows notifications.
/// Call NotificationService.init() once at startup (see main.dart).
class NotificationService {
  static Future<void> init() async {
    await localNotifier.setup(appName: 'Triage');
  }

  /// Fire a native notification. On macOS this appears in Notification Center;
  /// on Windows it appears as a toast.
  static Future<void> show(String title, String body) async {
    final n = LocalNotification(title: title, body: body);
    await n.show();
  }

  /// "New high-priority ticket appeared" notification.
  static Future<void> newTicket(String key, String summary) =>
      show('New high-priority ticket', '$key · $summary');

  /// Morning digest summary.
  static Future<void> morningDigest(int agingCount, int newCount) => show(
        '☀️ Good morning',
        '$agingCount tickets aging · $newCount new since yesterday',
      );

  /// Estimate request reminder.
  static Future<void> estimateReminder(String key) =>
      show('⏰ Estimate still pending', '$key is waiting for your estimate.');
}
