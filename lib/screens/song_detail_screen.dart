// lib/screens/song_detail_screen.dart
import 'package:flutter/material.dart';
import '../models/song.dart'; // Imports Song and LyricPart
import '../state/favorites_state.dart'; // Import shared state

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
  double _currentFontSize = 16.0;
  final double _minFontSize = 10.0;
  final double _maxFontSize = 30.0;

  @override
  Widget build(BuildContext context) {
    final isFavorite = FavoritesState.instance.isFavorite(widget.song);

    // Define text styles based on the current font size state
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
                  content: Text(isFavorite
                      ? 'Removed from favorites.'
                      : 'Added to favorites.'),
                  duration: const Duration(seconds: 1),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Display Translation and Key (same as before) ---
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
            // Iterate through the List<LyricPart> stored in the song object
            for (LyricPart part in widget.song.lyrics)
              Padding(
                // Add padding below each part (stanza/chorus) for spacing
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Text(
                  part.text, // Display the text of the part
                  // Apply italic style if the part was marked as a chorus during loading
                  style: part.isChorus ? italicStyle : baseStyle,
                ),
              ),

            // --- Font Size Slider (same as before) ---
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
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
          ],
        ),
      ),
    );
  }
}