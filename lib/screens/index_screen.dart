// lib/screens/index_screen.dart
import 'package:flutter/material.dart';
import 'package:tkbk/widgets/custom_header.dart';
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

    return Scaffold(
      body: Column(
        children: [
          const CustomHeader(title: 'Index (Alphabetical)'),
          Expanded(
            child: sortedSongs.isEmpty
                ? const Center(
                    child: Text('No songs loaded. Check assets/songs.json and restart the app.'),
                  )
                : ListView.builder( // Changed back to ListView.builder and handle spacing with Card
                    padding: const EdgeInsets.all(8.0),
                    itemCount: sortedSongs.length,
                    itemBuilder: (BuildContext context, int index) {
                      final Song currentSong = sortedSongs[index];
                      return Card( // Wrap ListTile with a Card
                        margin: const EdgeInsets.symmetric(vertical: 4.0), // Add vertical spacing
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        elevation: 2, // Optional: Subtle shadow
                        child: ListTile(
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