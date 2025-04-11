// lib/screens/song_detail_screen.dart
import 'package:flutter/material.dart';
import '../models/song.dart';
import '../state/favorites_state.dart';
import '../state/settings_state.dart';
import '../widgets/custom_header.dart';

class SongDetailScreen extends StatefulWidget {
  final Song song;
  const SongDetailScreen({super.key, required this.song});
  @override
  State<SongDetailScreen> createState() => _SongDetailScreenState();
}

class _SongDetailScreenState extends State<SongDetailScreen> {
  double _currentFontSize = 16.0;
  final double _minFontSize = 10.0;
  final double _maxFontSize = 30.0;

  @override
  Widget build(BuildContext context) {
    final baseStyle = Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.6, fontSize: _currentFontSize);
    final italicStyle = baseStyle?.copyWith(fontStyle: FontStyle.italic);
    final infoStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.outline);

    return Scaffold(
      appBar: CustomHeader(
        title: '${widget.song.number}. ${widget.song.title}',
        showBackButton: true,
        actions: [
          ValueListenableBuilder<List<int>>(
            valueListenable: favoritesState.favoriteSongNumbersNotifier,
            builder: (context, favoriteNumbers, child) {
              final bool isFavorite = favoriteNumbers.contains(widget.song.number);
              return IconButton(
                icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border, color: Colors.white),
                tooltip: isFavorite ? 'Remove from Favorites' : 'Mark as Favorite',
                onPressed: () {
                  favoritesState.toggleFavorite(widget.song);
                  ScaffoldMessenger.of(context).removeCurrentSnackBar();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(favoritesState.isFavorite(widget.song) ? 'Added to favorites.' : 'Removed from favorites.'),
                      duration: const Duration(seconds: 1),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              );
            }
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Translation and Key
                  if (widget.song.translation != null && widget.song.translation!.isNotEmpty)
                    Padding(padding: const EdgeInsets.only(bottom: 4.0), child: Text('Translation: ${widget.song.translation}', style: infoStyle)),
                  if (widget.song.musicKey != null && widget.song.musicKey!.isNotEmpty)
                    Padding(padding: const EdgeInsets.only(bottom: 12.0), child: Text('Key: ${widget.song.musicKey}', style: infoStyle)),
                  if ((widget.song.translation != null && widget.song.translation!.isNotEmpty) || (widget.song.musicKey != null && widget.song.musicKey!.isNotEmpty))
                     const Divider(height: 20, thickness: 1),
                  // Lyrics
                  for (LyricPart part in widget.song.lyrics)
                    Padding(padding: const EdgeInsets.only(bottom: 24.0), child: Text(part.text, style: part.isChorus ? italicStyle : baseStyle)),
                ],
              ),
            ),
          ),
          // --- Fixed Font Size Slider Area (Adjusted Padding) ---
          Padding(
            // Reduce top/bottom padding, keep accounting for system inset
            padding: EdgeInsets.fromLTRB(
                12.0,
                4.0, // Reduced top padding
                12.0,
                MediaQuery.of(context).padding.bottom + 8.0 // Reduced extra space
            ),
            child: Row(
              children: [
                 // Use smaller text style for label
                Text(
                  'Font Size:',
                  style: Theme.of(context).textTheme.labelSmall, // Smaller label
                ),
                const SizedBox(width: 8), // Add small gap
                Expanded(
                  child: Slider(
                    value: _currentFontSize,
                    min: _minFontSize, max: _maxFontSize,
                    divisions: (_maxFontSize - _minFontSize).round(),
                    label: _currentFontSize.round().toString(),
                    // Make slider visually smaller if possible
                    activeColor: Theme.of(context).colorScheme.primary, // Use theme color
                    inactiveColor: Theme.of(context).colorScheme.primary.withOpacity(0.3), // Lighter inactive track
                    onChanged: (double value) { setState(() { _currentFontSize = value; }); },
                  ),
                ),
              ],
            ),
          ),
          // --- End of Fixed Slider Area ---
        ],
      ),
    );
  }
}