// lib/screens/song_detail_screen.dart
import 'package:flutter/material.dart';
import '../models/song.dart';
import '../state/favorites_state.dart'; // Adjust path if needed

class SongDetailScreen extends StatefulWidget {
  final Song song;

  const SongDetailScreen({
    super.key,
    required this.song,
  });

  @override
  State<SongDetailScreen> createState() => _SongDetailScreenState();
}

class _SongDetailScreenState extends State<SongDetailScreen> {
  // --- Re-added Font Size Slider State Variables ---
  double _currentFontSize = 16.0; // Default font size
  final double _minFontSize = 10.0;
  final double _maxFontSize = 30.0;

  @override
  Widget build(BuildContext context) {
    final isFavorite = FavoritesState.instance.isFavorite(widget.song);

    // Define text styles based on the _currentFontSize state variable
    final baseStyle = Theme.of(context).textTheme.bodyLarge?.copyWith(
          height: 1.6,
          fontSize: _currentFontSize, // Use state variable
        );
    final italicStyle = baseStyle?.copyWith(fontStyle: FontStyle.italic);
    final infoStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Theme.of(context).colorScheme.outline,
        );

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.song.number}. ${widget.song.title}'),
        actions: [
          IconButton(
            icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border),
            tooltip: isFavorite ? 'Remove from Favorites' : 'Mark as Favorite',
            onPressed: () {
              setState(() {
                FavoritesState.instance.toggleFavorite(widget.song);
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(FavoritesState.instance.isFavorite(widget.song)
                      ? 'Added to favorites.'
                      : 'Removed from favorites.'),
                  duration: const Duration(seconds: 1),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
        ],
      ),
      // Use a Column to arrange the scrollable area and the fixed slider
      body: Column(
        children: [
          // Expanded makes the SingleChildScrollView take up available vertical space
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 20.0),
              // Removed SizedBox wrapper around Column
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- Display Translation and Key ---
                  if (widget.song.translation != null && widget.song.translation!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4.0),
                      child: Text('Translation: ${widget.song.translation}', style: infoStyle),
                    ),
                  if (widget.song.musicKey != null && widget.song.musicKey!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: Text('Key: ${widget.song.musicKey}', style: infoStyle),
                    ),
                  if ((widget.song.translation != null && widget.song.translation!.isNotEmpty) || (widget.song.musicKey != null && widget.song.musicKey!.isNotEmpty))
                     const Divider(height: 20, thickness: 1),

                  // --- Display Processed Lyrics ---
                  for (LyricPart part in widget.song.lyrics)
                    Padding(
                      // Increased bottom padding for double spacing
                      padding: const EdgeInsets.only(bottom: 24.0),
                      child: Text(
                        part.text,
                        style: part.isChorus ? italicStyle : baseStyle,
                      ),
                    ),
                ],
              ),
            ),
          ),
          // --- Fixed Font Size Slider Area ---
          // Placed outside Expanded, so it's fixed at the bottom of the Column
          Padding(
            // Add padding around the slider row, especially bottom for safe area
            padding: const EdgeInsets.fromLTRB(18.0, 8.0, 18.0, 12.0),
            child: Row(
              children: [
                const Text('Font Size:'),
                Expanded(
                  child: Slider(
                    value: _currentFontSize,
                    min: _minFontSize,
                    max: _maxFontSize,
                    divisions: (_maxFontSize - _minFontSize).round(),
                    label: _currentFontSize.round().toString(),
                    onChanged: (double value) {
                      setState(() {
                        _currentFontSize = value;
                      });
                    },
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