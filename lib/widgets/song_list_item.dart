// lib/widgets/song_list_item.dart
import 'package:flutter/material.dart';
import '../models/song.dart';
import '../screens/song_detail_screen.dart'; // For navigation

// Define as a StatelessWidget class
class SongListItem extends StatelessWidget {
  final Song song;
  final double fontSizeFactor;

  const SongListItem({
    super.key, // Use super parameter for key
    required this.song,
    required this.fontSizeFactor,
  });

  @override
  Widget build(BuildContext context) {
    // --- Logic moved inside build method ---
    final textTheme = Theme.of(context).textTheme;
    final titleStyle = textTheme.titleMedium?.copyWith(fontSize: (textTheme.titleMedium?.fontSize ?? 16.0) * fontSizeFactor);
    final subtitleStyle = textTheme.bodyMedium?.copyWith(fontSize: (textTheme.bodyMedium?.fontSize ?? 14.0) * fontSizeFactor);
    final trailingStyle = textTheme.bodyMedium?.copyWith(
          fontSize: (textTheme.bodyMedium?.fontSize ?? 14.0) * fontSizeFactor,
          color: Theme.of(context).colorScheme.outline
        );

    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final Color shadowColor = isDarkMode ? Colors.black.withOpacity(0.3) : Colors.black.withOpacity(0.1);
    final Color highlightColor = isDarkMode ? Colors.white.withOpacity(0.1) : Colors.white.withOpacity(0.7);
    final neumorphicDecoration = BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(8.0),
          boxShadow: [
            BoxShadow(blurRadius: 4.0, spreadRadius: 1.0, offset: const Offset(-2, -2), color: highlightColor),
            BoxShadow(blurRadius: 4.0, spreadRadius: 1.0, offset: const Offset(2, 2), color: shadowColor),
          ],
        );

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 4.0),
      color: Colors.transparent,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      child: Container(
        decoration: neumorphicDecoration,
        child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            title: Text(
              song.title, // Access song via class field
              style: titleStyle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: (song.translation != null && song.translation!.isNotEmpty)
                ? Text(
                    song.translation!,
                    style: subtitleStyle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  )
                : null,
            trailing: Text(song.number.toString(), style: trailingStyle), // Access song via class field
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  // Access song via class field
                  builder: (context) => SongDetailScreen(song: song),
                ),
              );
            },
          ),
      ),
    );
     // --- End logic inside build method ---
  }
}