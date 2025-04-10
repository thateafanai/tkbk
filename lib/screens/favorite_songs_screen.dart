// lib/screens/favorite_songs_screen.dart
import 'package:flutter/material.dart';
import 'package:tkbk/widgets/custom_header.dart';
import '../models/song.dart';
import '../state/favorites_state.dart';
import 'song_detail_screen.dart';

class FavoriteSongsScreen extends StatelessWidget {
  const FavoriteSongsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final favoriteSongs = FavoritesState.instance.favorites;

    return Scaffold(
      body: Column(
        children: [
          const CustomHeader(title: 'Favorite Songs'),
          Expanded(
            child: favoriteSongs.isEmpty
                ? const Center(
                    child: Text('No favorite songs yet.'),
                  )
                : ListView.builder( // Changed to ListView.builder
                    padding: const EdgeInsets.all(8.0), // Add padding around the list
                    itemCount: favoriteSongs.length,
                    itemBuilder: (context, index) {
                      final song = favoriteSongs[index];
                      return Card( // Wrap ListTile with a Card
                        margin: const EdgeInsets.symmetric(vertical: 4.0), // Add vertical spacing
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        elevation: 2, // Optional: Subtle shadow
                        child: ListTile(
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
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}