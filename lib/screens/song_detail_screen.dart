// lib/screens/song_detail_screen.dart
import 'package:flutter/material.dart';
import '../models/song.dart';
import '../state/favorites_state.dart'; // Adjust path if needed
import '../widgets/custom_header.dart'; // Import the CustomHeader

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
      body: Stack(
        children: [
          Column(
            children: [
              CustomHeader(title: '${widget.song.number}. ${widget.song.title}'), // Add CustomHeader here
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 20.0),
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
              Padding(
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
          // --- Favorite Button positioned using Stack ---
          Positioned(
            bottom: 60.0, // Adjust this value to position it above the slider
            right: 16.0, // Adjust this value for right positioning
            child: FloatingActionButton(
              mini: true, // Make it a smaller button if desired
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
              child: Icon(isFavorite ? Icons.favorite : Icons.favorite_border),
            ),
          ),
        ],
      ),
    );
  }
}