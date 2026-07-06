// Smoke test: with no stored credentials the app boots to the connect screen.

import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:triage/main.dart';
import 'package:triage/screens/connect_screen.dart';
import 'package:triage/state/app_state.dart';

void main() {
  testWidgets('shows connect screen when unconfigured', (tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: AppState(),
        child: const TriageApp(),
      ),
    );
    expect(find.byType(ConnectScreen), findsOneWidget);
  });
}
