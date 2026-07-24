// lib/screens/scripture_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../models/scripture_message.dart';
import '../services/message_store.dart';
import '../widgets/custom_header.dart';

// The devotional page: today's verse shown beautifully. Serif verse, gold
// reference, optional image, share/delete actions.
class ScriptureDetailScreen extends StatefulWidget {
  final ScriptureMessage message;
  const ScriptureDetailScreen({super.key, required this.message});

  @override
  State<ScriptureDetailScreen> createState() => _ScriptureDetailScreenState();
}

class _ScriptureDetailScreenState extends State<ScriptureDetailScreen> {
  static const Color _gold = Color(0xFF9C7724);
  static const Color _goldDark = Color(0xFFD8B25A);

  @override
  void initState() {
    super.initState();
    if (!widget.message.read) {
      messageStore.markRead(widget.message.id);
    }
  }

  Color _goldFor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? _goldDark : _gold;

  void _share() {
    final m = widget.message;
    final buffer = StringBuffer();
    if (m.reference != null && m.reference!.isNotEmpty) buffer.writeln(m.reference);
    buffer.writeln(m.body);
    buffer.write('\n— ${m.title}, Apatani Biisi Kheta');
    Share.share(buffer.toString().trim());
  }

  String _formattedDate(DateTime d) {
    const weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    const months = ['January', 'February', 'March', 'April', 'May', 'June', 'July',
      'August', 'September', 'October', 'November', 'December'];
    return '${weekdays[d.weekday - 1]}, ${d.day} ${months[d.month - 1]} ${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    final m = widget.message;
    final gold = _goldFor(context);
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;

    final serifRef = TextStyle(
      fontFamily: 'Georgia',
      fontSize: 26,
      fontWeight: FontWeight.bold,
      color: onSurface,
    );
    final serifVerse = TextStyle(
      fontFamily: 'Georgia',
      fontSize: 21,
      height: 1.62,
      color: onSurface,
    );

    return Scaffold(
      appBar: CustomHeader(
        title: m.title,
        showBackButton: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined, color: Colors.white),
            tooltip: 'Share',
            onPressed: _share,
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              m.title.toUpperCase(),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                letterSpacing: 2.0,
                fontWeight: FontWeight.bold,
                color: gold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _formattedDate(m.receivedDate),
              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
            ),
            if (m.reference != null && m.reference!.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(m.reference!, textAlign: TextAlign.center, style: serifRef),
            ],
            const SizedBox(height: 18),
            _Ornament(color: gold),
            const SizedBox(height: 20),
            Text(m.body, textAlign: TextAlign.center, style: serifVerse),
            if (m.imageUrl != null && m.imageUrl!.isNotEmpty) ...[
              const SizedBox(height: 26),
              ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Image.network(
                  m.imageUrl!,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;
                    return Container(
                      height: 180,
                      alignment: Alignment.center,
                      color: theme.colorScheme.surfaceContainerHighest,
                      child: const CircularProgressIndicator(),
                    );
                  },
                  errorBuilder: (context, error, stack) => const SizedBox.shrink(),
                ),
              ),
            ],
            const SizedBox(height: 28),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _share,
                    icon: const Icon(Icons.share, size: 18),
                    label: const Text('Share'),
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.indigo[900],
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      ),
    );
  }
}

// A thin gold rule with a centered mark, echoing an illuminated divider.
class _Ornament extends StatelessWidget {
  final Color color;
  const _Ornament({required this.color});

  @override
  Widget build(BuildContext context) {
    Widget rule() => Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color.withValues(alpha: 0), color.withValues(alpha: 0.55), color.withValues(alpha: 0)],
              ),
            ),
          ),
        );
    return SizedBox(
      width: 150,
      child: Row(
        children: [
          rule(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Icon(Icons.star, size: 9, color: color),
          ),
          rule(),
        ],
      ),
    );
  }
}
