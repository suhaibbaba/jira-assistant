import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// The four personal lists. All local — never touches Jira.
enum PersonalList { estimates, followUp, dismissed, priorityWatch }

extension PersonalListMeta on PersonalList {
  String get label => switch (this) {
        PersonalList.estimates => 'Estimates Needed',
        PersonalList.followUp => 'Follow Up',
        PersonalList.dismissed => 'Dismissed',
        PersonalList.priorityWatch => 'Priority Watch',
      };
  String get emoji => switch (this) {
        PersonalList.estimates => '📋',
        PersonalList.followUp => '👀',
        PersonalList.dismissed => '🚫',
        PersonalList.priorityWatch => '⭐',
      };
  String get storageKey => 'list_${name}';
}

/// Holds the membership of each personal list as sets of ticket keys.
class PersonalLists {
  final Map<PersonalList, Set<String>> _data = {
    for (final l in PersonalList.values) l: <String>{},
  };

  Set<String> of(PersonalList list) => _data[list]!;

  bool contains(PersonalList list, String key) => _data[list]!.contains(key);

  void add(PersonalList list, String key) => _data[list]!.add(key.toUpperCase());
  void remove(PersonalList list, String key) =>
      _data[list]!.remove(key.toUpperCase());

  void toggle(PersonalList list, String key) {
    if (contains(list, key)) {
      remove(list, key);
    } else {
      add(list, key);
    }
  }

  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();
    for (final l in PersonalList.values) {
      await prefs.setString(l.storageKey, jsonEncode(_data[l]!.toList()));
    }
  }

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    for (final l in PersonalList.values) {
      final raw = prefs.getString(l.storageKey);
      if (raw != null) {
        _data[l] = (jsonDecode(raw) as List).cast<String>().toSet();
      }
    }
  }
}
