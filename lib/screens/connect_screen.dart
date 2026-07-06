import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:triage/state/app_state.dart';
import 'package:triage/theme/app_theme.dart';
import 'package:triage/widgets/ui/ui.dart';

class ConnectScreen extends StatefulWidget {
  const ConnectScreen({super.key});
  @override
  State<ConnectScreen> createState() => _ConnectScreenState();
}

class _ConnectScreenState extends State<ConnectScreen> {
  final _domain = TextEditingController();
  final _email = TextEditingController();
  final _token = TextEditingController();
  final _jql = TextEditingController();
  bool _busy = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final s = context.read<AppState>().settings;
    _domain.text = s.domain;
    _email.text = s.email;
    _jql.text = s.jql;
  }

  String? _validate() {
    final domain = _domain.text.trim();
    final email = _email.text.trim();
    final token = _token.text.trim();
    if (domain.isEmpty) return 'Enter your Jira domain.';
    if (domain.contains(' ') || !domain.contains('.')) {
      return 'Domain looks invalid — e.g. yourcompany.atlassian.net';
    }
    if (email.isEmpty) return 'Enter your email.';
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
      return 'Email format looks invalid.';
    }
    if (token.isEmpty) return 'Paste your API token.';
    if (token.length < 20) {
      return 'That token looks too short — paste the full API token.';
    }
    return null;
  }

  Future<void> _connect() async {
    final validationError = _validate();
    if (validationError != null) {
      setState(() => _error = validationError);
      return;
    }
    setState(() {
      _error = null;
      _busy = true;
    });
    final app = context.read<AppState>();
    app.settings.jql = _jql.text.trim();
    await app.connect(_domain.text.trim(), _email.text.trim(), _token.text.trim());
    if (!mounted) return;
    setState(() => _busy = false);
    if (app.conn == ConnState.authError) {
      setState(() => _error = 'Could not authenticate. Check email and API token.');
    } else if (app.conn == ConnState.offline) {
      setState(() => _error = app.statusMessage ?? 'Could not reach Jira.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF0F172A), Color(0xFF1E3A5F)]),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              width: 420,
              margin: const EdgeInsets.all(24),
              padding: const EdgeInsets.fromLTRB(32, 32, 32, 28),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text('🎯', style: TextStyle(fontSize: 34), textAlign: TextAlign.center),
                  const SizedBox(height: 8),
                  const Text('Xngage — Jira Assistance',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: AppColors.text)),
                  const SizedBox(height: 4),
                  const Text('Read-only · your Jira stays untouched',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 13, color: AppColors.text2)),
                  const SizedBox(height: 24),
                  if (_error != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                          color: const Color(0xFFFEF2F2),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFFECACA))),
                      child: Text('⚠️ $_error',
                          style: const TextStyle(
                              fontSize: 13, color: Color(0xFFDC2626))),
                    ),
                    const SizedBox(height: 16),
                  ],
                  AppTextField(
                      label: 'Jira Domain',
                      controller: _domain,
                      hint: 'yourcompany.atlassian.net',
                      labelAbove: true),
                  const SizedBox(height: 14),
                  AppTextField(
                      label: 'Email',
                      controller: _email,
                      hint: 'you@company.com',
                      labelAbove: true),
                  const SizedBox(height: 14),
                  AppTextField(
                      label: 'API Token',
                      controller: _token,
                      hint: 'Paste your API token',
                      obscure: true,
                      labelAbove: true),
                  const SizedBox(height: 14),
                  AppTextField(
                      label: 'JQL filter (optional)',
                      controller: _jql,
                      hint: 'project = "ABC" AND sprint in openSprints()',
                      labelAbove: true),
                  const SizedBox(height: 14),
                  const SizedBox(height: 8),
                  _busy
                      ? const Padding(
                          padding: EdgeInsets.all(8),
                          child: Center(
                              child: SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(strokeWidth: 2.5))))
                      : AppButton(label: 'Load Tickets  →', onTap: _connect),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: () => launchUrl(Uri.parse(
                        'https://id.atlassian.com/manage-profile/security/api-tokens')),
                    child: const Text('🔒 Get an API token ↗',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 11, color: AppColors.accent)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
