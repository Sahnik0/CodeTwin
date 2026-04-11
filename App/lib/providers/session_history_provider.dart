import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/session_history.dart';
import 'onboarding_provider.dart';

const _historyStorageKey = 'session_history_v1';
const _maxHistorySessions = 100;

class SessionHistoryNotifier extends AsyncNotifier<List<SessionHistoryItem>> {
  @override
  Future<List<SessionHistoryItem>> build() async {
    return _load();
  }

  List<SessionHistoryItem> get _current => state.valueOrNull ?? const [];

  Future<void> reload() async {
    state = const AsyncLoading();
    state = AsyncData(await _load());
  }

  Future<void> add(SessionHistoryItem item) async {
    final updated = [item, ..._current];
    final trimmed = updated.length > _maxHistorySessions
        ? updated.sublist(0, _maxHistorySessions)
        : updated;
    state = AsyncData(trimmed);
    await _persist(trimmed);
  }

  Future<void> clear() async {
    state = const AsyncData([]);
    await _persist(const []);
  }

  Future<void> removeById(String id) async {
    final updated = _current.where((item) => item.id != id).toList();
    state = AsyncData(updated);
    await _persist(updated);
  }

  Future<List<SessionHistoryItem>> _load() async {
    try {
      final prefs = ref.read(sharedPreferencesProvider);
      final raw = prefs.getString(_historyStorageKey);
      if (raw == null || raw.isEmpty) return const [];
      final decoded = jsonDecode(raw);
      if (decoded is! List) return const [];

      return decoded
          .whereType<Map>()
          .map(
            (item) => SessionHistoryItem.fromJson(item.cast<String, dynamic>()),
          )
          .toList();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[SessionHistory] Failed to load history: $e');
      }
      return const [];
    }
  }

  Future<void> _persist(List<SessionHistoryItem> items) async {
    try {
      final prefs = ref.read(sharedPreferencesProvider);
      final payload = jsonEncode(items.map((e) => e.toJson()).toList());
      await prefs.setString(_historyStorageKey, payload);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[SessionHistory] Failed to persist history: $e');
      }
    }
  }
}

final sessionHistoryProvider =
    AsyncNotifierProvider<SessionHistoryNotifier, List<SessionHistoryItem>>(
      SessionHistoryNotifier.new,
    );
