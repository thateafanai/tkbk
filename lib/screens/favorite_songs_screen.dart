// lib/screens/favorite_songs_screen.dart
import 'package:flutter/material.dart';
import '../models/song.dart';
import '../state/favorites_state.dart';
import 'song_detail_screen.dart';

class FavoriteSongsScreen extends StatelessWidget {
  const FavoriteSongsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final favoriteSongs = FavoritesState.instance.favorites;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorite Songs'),
      ),
      body: favoriteSongs.isEmpty
          ? const Center(
              child: Text('No favorite songs yet.'),
            )
          : ListView.separated( // Changed from ListView.builder to ListView.separated
              itemCount: favoriteSongs.length,
              separatorBuilder: (context, index) => const Divider(), // Add Divider here
              itemBuilder: (context, index) {
                final song = favoriteSongs[index];
                return ListTile(
                  onTap: () {
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
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              song.title,
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            if (song.translation != null && song.translation!.isNotEmpty)
                              Text(
                                song.translation!,
                                style: Theme.of(context).textTheme.bodyMedium,
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