import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:triage/l10n/gen/app_localizations.dart';
import 'package:triage/state/app_state.dart';
import 'package:triage/models/settings.dart';
import 'package:triage/theme/app_theme.dart';
import 'package:triage/widgets/ui/ui.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();

  @override
  void initState() {
    super.initState();
    _name.addListener(() => setState(() {}));
    _email.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    super.dispose();
  }

  void _toastSaved() {
    final l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(l10n.settingsSavedToast),
        duration: const Duration(milliseconds: 900),
        behavior: SnackBarBehavior.floating,
        width: 220,
      ));
  }

  bool get _canAddMember =>
      _name.text.trim().isNotEmpty && _email.text.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final l10n = AppLocalizations.of(context);
    final s = app.settings;

    return Scaffold(
      backgroundColor: AppColors.bgContent,
      appBar: AppBar(
        backgroundColor: AppColors.bgSidebar,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(l10n.settingsTitle,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        shape: const Border(
            bottom: BorderSide(color: AppColors.separator, width: 0.5)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
        children: [
          _label(l10n.settingsSectionAging),
          _block(children: [
            for (final r in s.agingRules) _agingRow(app, l10n, r),
          ]),
          _label(l10n.settingsSectionTeam),
          _block(children: [
            _addPersonRow(app, l10n),
            for (final m in s.team) _personRow(app, m),
          ]),
          _label(l10n.settingsSectionGeneral),
          _block(children: [
            _stepperRow(l10n.settingsMorningDigestTime, s.morningDigestTime,
                () {}, () {},
                editable: false),
            _segRow(
                l10n.settingsSyncInterval,
                [
                  l10n.settingsSync5m,
                  l10n.settingsSync15m,
                  l10n.settingsSync30m
                ],
                _syncIndex(s.syncIntervalMinutes), (i) {
              s.syncIntervalMinutes = [5, 15, 30][i];
              app.saveSettings();
              _toastSaved();
            }),
            _segRow(
                l10n.settingsAgingCounts,
                [l10n.settingsBusinessDays, l10n.settingsCalendarDays],
                s.agingUsesBusinessDays ? 0 : 1, (i) {
              s.agingUsesBusinessDays = i == 0;
              app.saveSettings();
              _toastSaved();
            }),
          ]),
          const SizedBox(height: 20),
          Center(
            child: TextButton(
              onPressed: () async {
                await app.signOut();
                if (context.mounted) {
                  Navigator.of(context).popUntil((r) => r.isFirst);
                }
              },
              child: Text(l10n.settingsDisconnect,
                  style: const TextStyle(color: AppColors.errorText)),
            ),
          ),
        ],
      ),
    );
  }

  int _syncIndex(int m) => m <= 5 ? 0 : (m <= 15 ? 1 : 2);

  Widget _label(String s) => Padding(
        padding: const EdgeInsets.fromLTRB(2, 8, 2, 6),
        child: Text(s.toUpperCase(), style: AppTypography.overline),
      );

  Widget _block({required List<Widget> children}) => Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadius.br10,
          border: Border.all(color: AppColors.separator, width: 0.5),
        ),
        child: Column(children: children),
      );

  Widget _agingRow(AppState app, AppLocalizations l10n, StatusAgingRule r) {
    return _rowContainer(
      child: Row(
        children: [
          Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(
                  color: AppColors.statusColor(r.status),
                  shape: BoxShape.circle)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(r.status,
                    style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w500)),
                if (r.status == 'New')
                  Text(l10n.settingsAgingNewHint,
                      style:
                          const TextStyle(fontSize: 10, color: AppColors.text2))
                else if (r.status == 'In Progress')
                  Text(l10n.settingsAgingInProgressHint,
                      style: const TextStyle(
                          fontSize: 10, color: AppColors.text2)),
              ],
            ),
          ),
          AppToggle(
              value: r.alertEnabled,
              width: 32,
              height: 19,
              onChanged: (v) {
                setState(() => r.alertEnabled = v);
                app.saveSettings();
                _toastSaved();
              }),
          const SizedBox(width: 12),
          AppStepper(
            value: r.alertEnabled
                ? l10n.settingsDaysShort(r.thresholdDays)
                : l10n.commonEmDash,
            enabled: r.alertEnabled,
            onMinus: () {
              setState(
                  () => r.thresholdDays = (r.thresholdDays - 1).clamp(1, 30));
              app.saveSettings();
              _toastSaved();
            },
            onPlus: () {
              setState(
                  () => r.thresholdDays = (r.thresholdDays + 1).clamp(1, 30));
              app.saveSettings();
              _toastSaved();
            },
          ),
        ],
      ),
    );
  }

  Widget _addPersonRow(AppState app, AppLocalizations l10n) {
    return _rowContainer(
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _name,
              style: const TextStyle(fontSize: 12),
              decoration: InputDecoration(
                  hintText: l10n.settingsNameHint,
                  isDense: true,
                  border: InputBorder.none),
            ),
          ),
          Expanded(
            child: TextField(
              controller: _email,
              style: const TextStyle(fontSize: 12),
              decoration: InputDecoration(
                  hintText: l10n.settingsEmailHint,
                  isDense: true,
                  border: InputBorder.none),
            ),
          ),
          GestureDetector(
            onTap: !_canAddMember
                ? null
                : () {
                    if (_name.text.trim().isEmpty ||
                        _email.text.trim().isEmpty) {
                      return;
                    }

                    app.addTeamMember(_name.text.trim(), _email.text.trim());
                    _name.clear();
                    _email.clear();
                    _toastSaved();
                  },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                  color: !_canAddMember
                      ? AppColors.accent.withValues(alpha: 0.3)
                      : AppColors.accent,
                  borderRadius: BorderRadius.circular(6)),
              child: Text(l10n.settingsAddMember,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _personRow(AppState app, TeamMember m) {
    return _rowContainer(
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                color: AppColors.avatarColor(m.name), shape: BoxShape.circle),
            child: Text(_initials(m.name),
                style: const TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.w600,
                    color: Colors.white)),
          ),
          const SizedBox(width: 9),
          Text(m.name, style: const TextStyle(fontSize: 12)),
          const SizedBox(width: 8),
          Text(m.email,
              style: const TextStyle(fontSize: 10, color: AppColors.text2)),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.close, size: 16, color: AppColors.text3),
            onPressed: () {
              app.removeTeamMember(m);
              _toastSaved();
            },
          ),
        ],
      ),
    );
  }

  Widget _stepperRow(
      String label, String value, VoidCallback onMinus, VoidCallback onPlus,
      {bool editable = true}) {
    return _rowContainer(
      child: Row(
        children: [
          Text(label, style: AppTypography.rowLabel),
          const Spacer(),
          AppStepper(
              value: value,
              enabled: editable,
              onMinus: onMinus,
              onPlus: onPlus),
        ],
      ),
    );
  }

  Widget _segRow(String label, List<String> options, int selected,
      ValueChanged<int> onSelect) {
    return _rowContainer(
      child: Row(
        children: [
          Text(label, style: AppTypography.rowLabel),
          const Spacer(),
          AppSegmentedControl(
              options: options, selectedIndex: selected, onSelect: onSelect),
        ],
      ),
    );
  }

  Widget _rowContainer({required Widget child}) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: const BoxDecoration(
          border: Border(
              bottom: BorderSide(color: AppColors.separator, width: 0.5)),
        ),
        child: child,
      );

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
        .toUpperCase();
  }
}
