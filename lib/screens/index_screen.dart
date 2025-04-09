// lib/screens/index_screen.dart
import 'package:flutter/material.dart';
import '../models/song.dart';
import '../services/song_service.dart';
import 'song_detail_screen.dart';

class IndexScreen extends StatelessWidget {
  const IndexScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<Song> originalSongs = songService.songs;

    final List<Song> sortedSongs = List<Song>.from(originalSongs)
      ..sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));

    if (sortedSongs.isEmpty) {
       return Scaffold(
         appBar: AppBar(
           title: const Text('Index'),
         ),
         body: const Center(
           child: Text('No songs loaded. Check assets/songs.json and restart the app.'),
         ),
       );
     }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Index (Alphabetical)'),
      ),
      body: ListView.separated( // Changed from ListView.builder to ListView.separated
        itemCount: sortedSongs.length,
        separatorBuilder: (BuildContext context, int index) => const Divider(), // Add Divider here
        itemBuilder: (BuildContext context, int index) {
          final Song currentSong = sortedSongs[index];

          return ListTile(
            title: Text(currentSong.title),
            trailing: Text(
              currentSong.number.toString(),
              style: TextStyle(
                 color: Theme.of(context).colorScheme.outline,
                 fontSize: 14,
              ),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SongDetailScreen(song: currentSong),
                ),
              );
            },
          );
        },
      ),
    );
  }
}