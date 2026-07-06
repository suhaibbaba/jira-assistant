import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
    // Rebuild when text changes so the Add button enables/disables live.
    _name.addListener(() => setState(() {}));
    _email.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    super.dispose();
  }

  /// Small confirmation toast shown after any setting changes.
  void _toastSaved() {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(
        content: Text('Settings saved ✓'),
        duration: Duration(milliseconds: 900),
        behavior: SnackBarBehavior.floating,
        width: 220,
      ));
  }

  /// Add is enabled only when both fields have content.
  /// (Stricter option: replace the email check with
  ///  RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+\$').hasMatch(_email.text.trim()))
  bool get _canAddMember =>
      _name.text.trim().isNotEmpty && _email.text.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final s = app.settings;

    return Scaffold(
      backgroundColor: AppColors.bgContent,
      appBar: AppBar(
        backgroundColor: AppColors.bgSidebar,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text('Settings',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        shape: const Border(
            bottom: BorderSide(color: AppColors.separator, width: 0.5)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
        children: [
          _label('Aging alerts — per status'),
          _block(children: [
            for (final r in s.agingRules) _agingRow(app, r),
          ]),
          _label('Team members'),
          _block(children: [
            _addPersonRow(app),
            for (final m in s.team) _personRow(app, m),
          ]),
          _label('General'),
          _block(children: [
            _stepperRow(
                'Morning digest time', s.morningDigestTime, () {}, () {},
                editable: false),
            _segRow('Sync interval', ['5m', '15m', '30m'],
                _syncIndex(s.syncIntervalMinutes), (i) {
              s.syncIntervalMinutes = [5, 15, 30][i];
              app.saveSettings();
              _toastSaved();
            }),
            _segRow('Aging counts', ['Business days', 'Calendar'],
                s.agingUsesBusinessDays ? 0 : 1, (i) {
              s.agingUsesBusinessDays = i == 0;
              app.saveSettings();
              _toastSaved();
            }),
            _rowContainer(
              child: Row(
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Notifications', style: TextStyle(fontSize: 12)),
                        Text(
                            'If the test doesn\'t appear, allow the app in '
                            'System Settings → Notifications',
                            style: TextStyle(
                                fontSize: 10, color: AppColors.text2)),
                      ],
                    ),
                  ),
                  AppButton(
                    label: 'Send test',
                    fullWidth: false,
                    onTap: () => app.sendTestNotification(),
                  ),
                ],
              ),
            ),
          ]),
          const SizedBox(height: 20),
          Center(
            child: TextButton(
              onPressed: () async {
                await app.signOut();
                if (context.mounted) {
                  // Settings is a pushed route — pop back to root so the
                  // login screen (swapped in underneath) becomes visible.
                  Navigator.of(context).popUntil((r) => r.isFirst);
                }
              },
              child: const Text('Disconnect & erase all data',
                  style: TextStyle(color: Color(0xFFDC2626))),
            ),
          ),
        ],
      ),
    );
  }

  int _syncIndex(int m) => m <= 5 ? 0 : (m <= 15 ? 1 : 2);

  Widget _label(String s) => Padding(
        padding: const EdgeInsets.fromLTRB(2, 8, 2, 6),
        child: Text(s.toUpperCase(),
            style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.4,
                color: AppColors.text3)),
      );

  Widget _block({required List<Widget> children}) => Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.separator, width: 0.5),
        ),
        child: Column(children: children),
      );

  Widget _agingRow(AppState app, StatusAgingRule r) {
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
                  const Text('Untriaged — most urgent',
                      style: TextStyle(fontSize: 10, color: AppColors.text2))
                else if (r.status == 'In Progress')
                  const Text('Usually off — being worked',
                      style: TextStyle(fontSize: 10, color: AppColors.text2)),
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
          _stepper(
            r.alertEnabled ? '${r.thresholdDays}d' : '—',
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

  Widget _addPersonRow(AppState app) {
    return _rowContainer(
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _name,
              style: const TextStyle(fontSize: 12),
              decoration: const InputDecoration(
                  hintText: 'Name', isDense: true, border: InputBorder.none),
            ),
          ),
          Expanded(
            child: TextField(
              controller: _email,
              style: const TextStyle(fontSize: 12),
              decoration: const InputDecoration(
                  hintText: 'email@company.com',
                  isDense: true,
                  border: InputBorder.none),
            ),
          ),
          GestureDetector(
            onTap: !_canAddMember
                ? null // disabled: 0.3 alpha + not-allowed cursor (AppButton)
                : () {
                    if (_name.text.trim().isEmpty || _email.text.trim().isEmpty)
                      return;
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
              child: const Text('+ Add',
                  style: TextStyle(
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
          Text(label, style: const TextStyle(fontSize: 12)),
          const Spacer(),
          _stepper(value, enabled: editable, onMinus: onMinus, onPlus: onPlus),
        ],
      ),
    );
  }

  Widget _segRow(String label, List<String> options, int selected,
      ValueChanged<int> onSelect) {
    return _rowContainer(
      child: Row(
        children: [
          Text(label, style: const TextStyle(fontSize: 12)),
          const Spacer(),
          Container(
            decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(7)),
            padding: const EdgeInsets.all(2),
            child: Row(
              children: [
                for (var i = 0; i < options.length; i++)
                  GestureDetector(
                    onTap: () => onSelect(i),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 11, vertical: 4),
                      decoration: BoxDecoration(
                        color:
                            selected == i ? Colors.white : Colors.transparent,
                        borderRadius: BorderRadius.circular(5),
                        boxShadow: selected == i
                            ? [
                                BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.1),
                                    blurRadius: 2)
                              ]
                            : null,
                      ),
                      child: Text(options[i],
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: selected == i
                                  ? AppColors.text
                                  : AppColors.text2)),
                    ),
                  ),
              ],
            ),
          ),
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

  Widget _stepper(String value,
      {required bool enabled,
      required VoidCallback onMinus,
      required VoidCallback onPlus}) {
    return Opacity(
      opacity: enabled ? 1 : 0.4,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.separator),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _stepBtn('−', enabled ? onMinus : null),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              child: Text(value,
                  style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w600)),
            ),
            _stepBtn('+', enabled ? onPlus : null),
          ],
        ),
      ),
    );
  }

  Widget _stepBtn(String s, VoidCallback? onTap) => GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          color: Colors.black.withValues(alpha: 0.03),
          child: Text(s,
              style: const TextStyle(fontSize: 13, color: AppColors.text2)),
        ),
      );

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
        .toUpperCase();
  }
}
