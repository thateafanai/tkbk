// lib/models/scripture_message.dart

// One received push message, as persisted in the inbox. Populated from an
// FCM RemoteMessage's notification + data payload.
class ScriptureMessage {
  final String id; // FCM messageId, or a generated fallback
  final String title; // e.g. "Scripture of the Day"
  final String? reference; // e.g. "John 3:16" (data key: reference)
  final String body; // the verse / message text
  final String? imageUrl; // optional attached image
  final int receivedAt; // millisecondsSinceEpoch
  final bool read;

  ScriptureMessage({
    required this.id,
    required this.title,
    required this.body,
    this.reference,
    this.imageUrl,
    required this.receivedAt,
    this.read = false,
  });

  DateTime get receivedDate => DateTime.fromMillisecondsSinceEpoch(receivedAt);

  ScriptureMessage copyWith({bool? read}) => ScriptureMessage(
        id: id,
        title: title,
        reference: reference,
        body: body,
        imageUrl: imageUrl,
        receivedAt: receivedAt,
        read: read ?? this.read,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'reference': reference,
        'body': body,
        'imageUrl': imageUrl,
        'receivedAt': receivedAt,
        'read': read ? 1 : 0,
      };

  factory ScriptureMessage.fromMap(Map<String, dynamic> map) => ScriptureMessage(
        id: map['id'] as String,
        title: (map['title'] as String?) ?? '',
        reference: map['reference'] as String?,
        body: (map['body'] as String?) ?? '',
        imageUrl: map['imageUrl'] as String?,
        receivedAt: (map['receivedAt'] as int?) ?? 0,
        read: (map['read'] as int?) == 1,
      );

  // Build from a Firestore `scriptures` document. The store computes
  // createdAtMillis from the doc's createdAt Timestamp so this stays free of
  // any cloud_firestore import.
  factory ScriptureMessage.fromFirestore({
    required String id,
    required Map<String, dynamic> data,
    required int createdAtMillis,
    bool read = false,
  }) {
    String? str(String key) {
      final v = data[key];
      if (v == null) return null;
      final s = v.toString();
      return s.isEmpty ? null : s;
    }

    return ScriptureMessage(
      id: id,
      title: str('title') ?? 'Scripture of the Day',
      reference: str('reference'),
      body: str('verse') ?? str('body') ?? '',
      imageUrl: str('imageUrl') ?? str('image'),
      receivedAt: createdAtMillis,
      read: read,
    );
  }

  // Build from an FCM message's notification + data fields. Prefers explicit
  // data keys (reference/verse/imageUrl) so background-delivered messages,
  // which only carry data reliably, still populate correctly.
  factory ScriptureMessage.fromRemote({
    required String id,
    String? notificationTitle,
    String? notificationBody,
    String? notificationImageUrl,
    required Map<String, dynamic> data,
    required int receivedAt,
  }) {
    String? str(String key) {
      final v = data[key];
      if (v == null) return null;
      final s = v.toString();
      return s.isEmpty ? null : s;
    }

    return ScriptureMessage(
      id: id,
      title: str('title') ?? notificationTitle ?? 'Message',
      reference: str('reference'),
      body: str('verse') ?? str('body') ?? notificationBody ?? '',
      imageUrl: str('imageUrl') ?? str('image') ?? notificationImageUrl,
      receivedAt: receivedAt,
      read: false,
    );
  }
}
