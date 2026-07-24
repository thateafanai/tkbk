// lib/screens/scripture_inbox_screen.dart
import 'package:flutter/material.dart';

import '../models/scripture_message.dart';
import '../services/message_store.dart';
import '../widgets/custom_header.dart';
import 'scripture_detail_screen.dart';

// The archive: every received message as a card, newest first.
class ScriptureInboxScreen extends StatelessWidget {
  const ScriptureInboxScreen({super.key});

  static const Color _gold = Color(0xFF9C7724);
  static const Color _goldDark = Color(0xFFD8B25A);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomHeader(
        title: 'Scripture',
        showBackButton: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all, color: Colors.white),
            tooltip: 'Mark all read',
            onPressed: () => messageStore.markAllRead(),
          ),
        ],
      ),
      body: ValueListenableBuilder<List<ScriptureMessage>>(
        valueListenable: messageStore.messages,
        builder: (context, messages, _) {
          if (messages.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.menu_book_outlined, size: 56, color: Theme.of(context).colorScheme.outline),
                    const SizedBox(height: 16),
                    Text(
                      'No messages yet',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Scripture of the Day and announcements will appear here.",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Theme.of(context).colorScheme.outline),
                    ),
                  ],
                ),
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            itemCount: messages.length,
            itemBuilder: (context, index) => _MessageCard(message: messages[index]),
          );
        },
      ),
    );
  }
}

class _MessageCard extends StatelessWidget {
  final ScriptureMessage message;
  const _MessageCard({required this.message});

  Color _gold(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? ScriptureInboxScreen._goldDark
          : ScriptureInboxScreen._gold;

  String _relativeDate(DateTime d) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final that = DateTime(d.year, d.month, d.day);
    final diff = today.difference(that).inDays;
    final time = '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
    if (diff == 0) return 'Today · $time';
    if (diff == 1) return 'Yesterday · $time';
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${d.day} ${months[d.month - 1]} · $time';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final gold = _gold(context);
    final isDark = theme.brightness == Brightness.dark;
    final hasImage = message.imageUrl != null && message.imageUrl!.isNotEmpty;

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _relativeDate(message.receivedDate),
              style: TextStyle(fontSize: 11.5, color: theme.colorScheme.outline),
            ),
            if (!message.read)
              Container(
                width: 9,
                height: 9,
                decoration: BoxDecoration(
                  color: gold,
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: gold.withValues(alpha: 0.35), blurRadius: 4, spreadRadius: 1)],
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        if (message.reference != null && message.reference!.isNotEmpty)
          Text(
            message.reference!.toUpperCase(),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
              color: gold,
            ),
          ),
        if (message.reference != null && message.reference!.isNotEmpty) const SizedBox(height: 6),
        Text(
          message.body.isNotEmpty ? message.body : message.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontFamily: 'Georgia', fontSize: 15.5, height: 1.5),
        ),
      ],
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      child: Material(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        elevation: isDark ? 0 : 1.5,
        shadowColor: Colors.black.withValues(alpha: 0.15),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => ScriptureDetailScreen(message: message)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: hasImage
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: content),
                      const SizedBox(width: 14),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          message.imageUrl!,
                          width: 66,
                          height: 66,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const SizedBox(width: 66, height: 66),
                        ),
                      ),
                    ],
                  )
                : content,
          ),
        ),
      ),
    );
  }
}
