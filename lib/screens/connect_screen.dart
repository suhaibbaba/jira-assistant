import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:triage/config/app_info.dart';
import 'package:triage/l10n/gen/app_localizations.dart';
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

  String? _validate(AppLocalizations l10n) {
    final domain = _domain.text.trim();
    final email = _email.text.trim();
    final token = _token.text.trim();
    if (domain.isEmpty) return l10n.connectErrDomainEmpty;
    if (domain.contains(' ') || !domain.contains('.')) {
      return l10n.connectErrDomainInvalid;
    }
    if (email.isEmpty) return l10n.connectErrEmailEmpty;
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
      return l10n.connectErrEmailInvalid;
    }
    if (token.isEmpty) return l10n.connectErrTokenEmpty;
    if (token.length < 20) {
      return l10n.connectErrTokenShort;
    }
    return null;
  }

  Future<void> _connect() async {
    final l10n = AppLocalizations.of(context);
    final validationError = _validate(l10n);
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
      setState(() => _error = l10n.connectErrAuth);
    } else if (app.conn == ConnState.offline) {
      setState(() => _error = app.statusMessage ?? l10n.connectErrNetwork);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.connectGradientTop,
                AppColors.connectGradientBottom
              ]),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              width: 420,
              margin: const EdgeInsets.all(24),
              padding: const EdgeInsets.fromLTRB(32, 32, 32, 28),
              decoration: const BoxDecoration(
                color: AppColors.surface,
                borderRadius: AppRadius.br16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text('🎯', style: TextStyle(fontSize: 34), textAlign: TextAlign.center),
                  const SizedBox(height: 8),
                  const Text(AppInfo.appNameFull,
                      textAlign: TextAlign.center,
                      style: AppTypography.heading),
                  const SizedBox(height: 4),
                  Text(l10n.connectSubtitle,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 13, color: AppColors.text2)),
                  const SizedBox(height: 24),
                  if (_error != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                          color: AppColors.errorSurface,
                          borderRadius: AppRadius.br8,
                          border: Border.all(color: AppColors.errorBorder)),
                      child: Text(l10n.connectErrorBanner(_error!),
                          style: const TextStyle(
                              fontSize: 13, color: AppColors.errorText)),
                    ),
                    const SizedBox(height: 16),
                  ],
                  AppTextField(
                      label: l10n.connectDomainLabel,
                      controller: _domain,
                      hint: l10n.connectDomainHint,
                      labelAbove: true),
                  const SizedBox(height: 14),
                  AppTextField(
                      label: l10n.connectEmailLabel,
                      controller: _email,
                      hint: l10n.connectEmailHint,
                      labelAbove: true),
                  const SizedBox(height: 14),
                  AppTextField(
                      label: l10n.connectTokenLabel,
                      controller: _token,
                      hint: l10n.connectTokenHint,
                      obscure: true,
                      labelAbove: true),
                  const SizedBox(height: 14),
                  AppTextField(
                      label: l10n.connectJqlLabel,
                      controller: _jql,
                      hint: l10n.connectJqlHint,
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
                      : AppButton(label: l10n.connectLoadTickets, onTap: _connect),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: () => launchUrl(Uri.parse(
                        'https://id.atlassian.com/manage-profile/security/api-tokens')),
                    child: Text(l10n.connectGetToken,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 11, color: AppColors.accent)),
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
