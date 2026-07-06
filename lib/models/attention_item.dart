import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AttentionMeta {
  final String ticketKey;
  final String requestedBy;
  final DateTime addedAt;

  AttentionMeta({
    required this.ticketKey,
    required this.requestedBy,
    required this.addedAt,
  });

  Map<String, dynamic> toJson() => {
        'key': ticketKey,
        'by': requestedBy,
        'at': addedAt.toIso8601String(),
      };

  factory AttentionMeta.fromJson(Map<String, dynamic> j) => AttentionMeta(
        ticketKey: j['key'],
        requestedBy: j['by'] ?? '',
        addedAt: DateTime.tryParse(j['at'] ?? '') ?? DateTime.now(),
      );

  String get agoLabel {
    final d = DateTime.now().difference(addedAt);
    if (d.inDays >= 1) return '${d.inDays}d ago';
    if (d.inHours >= 1) return '${d.inHours}h ago';
    if (d.inMinutes >= 1) return '${d.inMinutes}m ago';
    return 'just now';
  }
}

class AttentionStore {
  static const _key = 'attention_items';
  final Map<String, AttentionMeta> _items = {};

  List<AttentionMeta> get all => _items.values.toList()
    ..sort((a, b) => b.addedAt.compareTo(a.addedAt));

  AttentionMeta? metaFor(String ticketKey) => _items[ticketKey.toUpperCase()];

  bool contains(String ticketKey) => _items.containsKey(ticketKey.toUpperCase());

  Future<void> add(String ticketKey, String requestedBy) async {
    final k = ticketKey.toUpperCase();
    _items[k] = AttentionMeta(
        ticketKey: k, requestedBy: requestedBy.trim(), addedAt: DateTime.now());
    await save();
  }

  Future<void> markDone(String ticketKey) async {
    _items.remove(ticketKey.toUpperCase());
    await save();
  }

  Future<void> clearAll() async {
    _items.clear();
    await save();
  }

  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _key, jsonEncode(_items.values.map((m) => m.toJson()).toList()));
  }

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return;
    _items.clear();
    for (final e in (jsonDecode(raw) as List)) {
      final m = AttentionMeta.fromJson(e as Map<String, dynamic>);
      _items[m.ticketKey] = m;
    }
  }
}
