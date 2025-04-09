// lib/screens/favorite_songs_screen.dart
import 'package:flutter/material.dart';
import '../models/song.dart'; // Import Song model
import '../state/favorites_state.dart'; // Import shared state
import 'song_detail_screen.dart'; // Import SongDetailScreen

class FavoriteSongsScreen extends StatelessWidget {
  const FavoriteSongsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final favoriteSongs = FavoritesState.instance.favorites; // Access shared state

    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorite Songs'),
      ),
      body: favoriteSongs.isEmpty
          ? const Center(
              child: Text('No favorite songs yet.'),
            )
          : ListView.builder(
              itemCount: favoriteSongs.length,
              itemBuilder: (context, index) {
                final song = favoriteSongs[index];
                return ListTile(
                  onTap: () {
                    // Navigate to SongDetailScreen when a song is tapped
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SongDetailScreen(song: song),
                      ),
                    );
                  },
                  title: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${song.number}. ',
                        style: Theme.of(context).textTheme.bodyLarge, // Style for the number
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              song.title,
                              style: Theme.of(context).textTheme.bodyLarge, // Style for the title
                            ),
                            if (song.translation != null && song.translation!.isNotEmpty)
                              Text(
                                song.translation!,
                                style: Theme.of(context).textTheme.bodyMedium, // Style for the translation
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}