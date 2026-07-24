// lib/services/message_store.dart
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/scripture_message.dart';

// The Scripture archive. Source of truth is the Firestore `scriptures`
// collection (shared by all installs + managed from the browser admin page);
// cloud_firestore caches it offline automatically. Per-user read state is
// kept locally in shared_preferences. Singleton, matching the app's other
// services.
class MessageStore {
  MessageStore._privateConstructor();
  static final MessageStore instance = MessageStore._privateConstructor();

  static const _collection = 'scriptures';
  static const _readIdsKey = 'read_scripture_ids';

  final ValueNotifier<List<ScriptureMessage>> messages = ValueNotifier([]);
  final ValueNotifier<int> unreadCount = ValueNotifier(0);

  Set<String> _readIds = {};
  List<ScriptureMessage> _raw = [];
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _sub;

  // Loads read-state, then subscribes to the Firestore archive (real-time).
  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _readIds = (prefs.getStringList(_readIdsKey) ?? []).toSet();
    } catch (e) {
      if (kDebugMode) print('MessageStore read-ids load error: $e');
    }

    // Ordered by visibleFrom (release time). Future-scheduled scriptures are
    // filtered out client-side until their time arrives.
    _sub ??= FirebaseFirestore.instance
        .collection(_collection)
        .orderBy('visibleFrom', descending: true)
        .limit(200)
        .snapshots()
        .listen(_onSnapshot, onError: (e) {
      // Firestore not set up yet / offline first run: keep an empty archive.
      if (kDebugMode) print('Scripture stream error: $e');
    });
  }

  void _onSnapshot(QuerySnapshot<Map<String, dynamic>> snap) {
    final nowMillis = DateTime.now().millisecondsSinceEpoch;
    _raw = snap.docs
        .map((d) {
          final data = d.data();
          final vf = data['visibleFrom'] ?? data['createdAt'];
          final millis = vf is Timestamp ? vf.millisecondsSinceEpoch : 0;
          return ScriptureMessage.fromFirestore(id: d.id, data: data, createdAtMillis: millis);
        })
        .where((m) => m.receivedAt <= nowMillis)
        .toList();
    _publish();
  }

  void _publish() {
    messages.value = _raw
        .map((m) => m.copyWith(read: _readIds.contains(m.id)))
        .toList();
    unreadCount.value = _raw.where((m) => !_readIds.contains(m.id)).length;
  }

  ScriptureMessage? byId(String id) {
    for (final m in messages.value) {
      if (m.id == id) return m;
    }
    return null;
  }

  Future<void> markRead(String id) async {
    if (_readIds.add(id)) {
      _publish();
      await _persistReadIds();
    }
  }

  Future<void> markAllRead() async {
    _readIds.addAll(_raw.map((m) => m.id));
    _publish();
    await _persistReadIds();
  }

  Future<void> _persistReadIds() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_readIdsKey, _readIds.toList());
    } catch (e) {
      if (kDebugMode) print('MessageStore read-ids save error: $e');
    }
  }
}

final messageStore = MessageStore.instance;
