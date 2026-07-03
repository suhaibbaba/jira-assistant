import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../models/settings.dart';
import '../theme/app_theme.dart';

class Sidebar extends StatelessWidget {
  const Sidebar({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();

    return Container(
      width: 210,
      decoration: const BoxDecoration(
        color: AppColors.bgSidebar,
        border: Border(right: BorderSide(color: AppColors.separator, width: 0.5)),
      ),
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        children: [
          _label('My / Team'),
          _segmented(app),
          const SizedBox(height: 8),
          if (app.scope == ViewScope.team) ...[
            _label('Teammates'),
            ...app.settings.team.map((m) => _personRow(context, app, m)),
            const _Divider(),
          ],
          _label('Show statuses'),
          ...AppColors.status.keys
              .where((s) => s != 'Estimate Requested')
              .map((s) => _statusRow(context, app, s)),
          const _Divider(),
          _label('Projects'),
          ...app.projectsWithCounts.entries.map((e) =>
              _projectRow(context, app, e.key, e.value.name, e.value.count)),
        ],
      ),
    );
  }

  Widget _label(String s) => Padding(
        padding: const EdgeInsets.fromLTRB(8, 6, 8, 3),
        child: Text(s.toUpperCase(),
            style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.4,
                color: AppColors.text3)),
      );

  Widget _segmented(AppState app) {
    Widget opt(String label, ViewScope scope) {
      final sel = app.scope == scope;
      return Expanded(
        child: GestureDetector(
          onTap: () => app.setScope(scope),
          child: Container(
            margin: const EdgeInsets.all(2),
            padding: const EdgeInsets.symmetric(vertical: 4),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: sel ? Colors.white : Colors.transparent,
              borderRadius: BorderRadius.circular(5),
              boxShadow: sel
                  ? [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 2)]
                  : null,
            ),
            child: Text(label,
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: sel ? AppColors.text : AppColors.text2)),
          ),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.05),
          borderRadius: BorderRadius.circular(7)),
      child: Row(children: [
        opt('My tickets', ViewScope.mine),
        opt('Team', ViewScope.team),
      ]),
    );
  }

  Widget _statusRow(BuildContext context, AppState app, String status) {
    final on = app.settings.visibleStatuses.contains(status);
    final count = app.groupedByStatus[status]?.length ?? 0;
    return _row(
      onTap: () => app.toggleStatusVisible(status),
      active: on,
      leading: _checkbox(on),
      dotColor: AppColors.statusColor(status),
      label: status,
      count: count,
    );
  }

  Widget _projectRow(BuildContext context, AppState app, String key, String name,
      int count) {
    final hidden = app.settings.hiddenProjectKeys.contains(key);
    return Opacity(
      opacity: hidden ? 0.5 : 1,
      child: _row(
        onTap: () => app.toggleProjectHidden(key),
        active: false,
        dotColor: AppColors.avatarColor(key),
        label: name.isEmpty ? key : name,
        count: count,
        trailing: _toggle(!hidden),
      ),
    );
  }

  Widget _personRow(BuildContext context, AppState app, TeamMember member) {
    return Opacity(
      opacity: member.visible ? 1 : 0.5,
      child: _row(
        onTap: () => app.toggleTeamMemberVisible(member),
        active: member.visible,
        leading: _avatar(member.name),
        label: member.name,
        trailing: _toggle(member.visible),
      ),
    );
  }

  Widget _row({
    required VoidCallback onTap,
    required bool active,
    Widget? leading,
    Color? dotColor,
    required String label,
    int? count,
    Widget? trailing,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: const EdgeInsets.only(bottom: 1),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
          color: active ? AppColors.accentSoft : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          children: [
            if (leading != null) ...[leading, const SizedBox(width: 8)],
            if (dotColor != null) ...[
              Container(
                  width: 7,
                  height: 7,
                  decoration:
                      BoxDecoration(color: dotColor, shape: BoxShape.circle)),
              const SizedBox(width: 8),
            ],
            Expanded(
              child: Text(label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12, color: AppColors.text)),
            ),
            if (count != null)
              Padding(
                padding: const EdgeInsets.only(left: 6, right: 4),
                child: Text('$count',
                    style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: AppColors.text3)),
              ),
            if (trailing != null) trailing,
          ],
        ),
      ),
    );
  }

  Widget _checkbox(bool on) => Container(
        width: 15,
        height: 15,
        decoration: BoxDecoration(
          color: on ? AppColors.accent : Colors.transparent,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
              color: on ? AppColors.accent : AppColors.text3, width: 1.5),
        ),
        child: on
            ? const Icon(Icons.check, size: 10, color: Colors.white)
            : null,
      );

  Widget _toggle(bool on) => Container(
        width: 28,
        height: 17,
        decoration: BoxDecoration(
          color: on ? AppColors.priority['Low'] : Colors.black.withOpacity(0.15),
          borderRadius: BorderRadius.circular(9),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 120),
          alignment: on ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.all(2),
            width: 13,
            height: 13,
            decoration: const BoxDecoration(
                color: Colors.white, shape: BoxShape.circle),
          ),
        ),
      );

  Widget _avatar(String name) => Container(
        width: 18,
        height: 18,
        alignment: Alignment.center,
        decoration: BoxDecoration(
            color: AppColors.avatarColor(name), shape: BoxShape.circle),
        child: Text(_initials(name),
            style: const TextStyle(
                fontSize: 8, fontWeight: FontWeight.w600, color: Colors.white)),
      );

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
        .toUpperCase();
  }
}

class _Divider extends StatelessWidget {
  const _Divider();
  @override
  Widget build(BuildContext context) => Container(
        height: 0.5,
        color: AppColors.separator,
        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      );
}
