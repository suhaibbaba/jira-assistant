import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:triage/state/app_state.dart';
import 'package:triage/theme/app_theme.dart';
import 'package:triage/services/notification_service.dart';
import 'package:triage/screens/connect_screen.dart';
import 'package:triage/screens/board_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.init();

  final appState = AppState();
  await appState.bootstrap();

  runApp(
    ChangeNotifierProvider.value(
      value: appState,
      child: const TriageApp(),
    ),
  );
}

class TriageApp extends StatelessWidget {
  const TriageApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Xngage — Jira Assistance',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      home: const _Root(),
    );
  }
}

class _Root extends StatelessWidget {
  const _Root();

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    // Show the board once we have credentials; otherwise the connect screen.
    if (app.isConfigured) {
      return const BoardScreen();
    }
    return const ConnectScreen();
  }
}
