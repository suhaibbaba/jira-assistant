import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../models/settings.dart';
import '../theme/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();

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
            }),
            _segRow('Aging counts', ['Business days', 'Calendar'],
                s.agingUsesBusinessDays ? 0 : 1, (i) {
              s.agingUsesBusinessDays = i == 0;
              app.saveSettings();
            }),
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
          _switch(r.alertEnabled, (v) {
            setState(() => r.alertEnabled = v);
            app.saveSettings();
          }),
          const SizedBox(width: 12),
          _stepper(
            r.alertEnabled ? '${r.thresholdDays}d' : '—',
            enabled: r.alertEnabled,
            onMinus: () {
              setState(
                  () => r.thresholdDays = (r.thresholdDays - 1).clamp(1, 30));
              app.saveSettings();
            },
            onPlus: () {
              setState(
                  () => r.thresholdDays = (r.thresholdDays + 1).clamp(1, 30));
              app.saveSettings();
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
                  hintText: 'Name',
                  hintStyle:
                      const TextStyle(fontSize: 12, color: AppColors.text3),
                  isDense: true,
                  border: InputBorder.none),
            ),
          ),
          Expanded(
            child: TextField(
              controller: _email,
              style: const TextStyle(fontSize: 12),
              decoration: const InputDecoration(
                  hintText: 'email@company.com',
                  hintStyle:
                      const TextStyle(fontSize: 12, color: AppColors.text3),
                  isDense: true,
                  border: InputBorder.none),
            ),
          ),
          GestureDetector(
            onTap: () {
              if (_name.text.trim().isEmpty || _email.text.trim().isEmpty)
                return;
              app.addTeamMember(_name.text.trim(), _email.text.trim());
              _name.clear();
              _email.clear();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                  color: AppColors.accent,
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
            onPressed: () => app.removeTeamMember(m),
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
                color: Colors.black.withOpacity(0.05),
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
                                    color: Colors.black.withOpacity(0.1),
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

  Widget _switch(bool value, ValueChanged<bool> onChanged) => GestureDetector(
        onTap: () => onChanged(!value),
        child: Container(
          width: 32,
          height: 19,
          decoration: BoxDecoration(
            color: value
                ? AppColors.priority['Low']
                : Colors.black.withOpacity(0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: AnimatedAlign(
            duration: const Duration(milliseconds: 120),
            alignment: value ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              margin: const EdgeInsets.all(2),
              width: 15,
              height: 15,
              decoration: const BoxDecoration(
                  color: Colors.white, shape: BoxShape.circle),
            ),
          ),
        ),
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
          color: Colors.black.withOpacity(0.03),
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
