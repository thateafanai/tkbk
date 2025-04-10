// lib/screens/all_songs_screen.dart
import 'package:flutter/material.dart';
import 'package:tkbk/widgets/custom_header.dart';
import '../models/song.dart';
import '../services/song_service.dart';
import 'song_detail_screen.dart';

class AllSongsScreen extends StatelessWidget {
  const AllSongsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Song> songs = songService.songs;

    return Scaffold(
      body: Column(
        children: [
          const CustomHeader(title: 'All Songs'),
          Expanded(
            child: songs.isEmpty
                ? const Center(
                    child: Text('No songs loaded. Check assets/songs.json and restart the app.'),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(8.0), // Add some padding around the list
                    itemCount: songs.length,
                    itemBuilder: (context, index) {
                      final Song currentSong = songs[index];
                      return Card( // Wrap ListTile with a Card
                        margin: const EdgeInsets.symmetric(vertical: 4.0), // Add vertical spacing between cards
                        shape: RoundedRectangleBorder( // Optional: Add rounded corners
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        elevation: 2, // Optional: Add a subtle shadow
                        child: ListTile(
                          title: Text(currentSong.title),
                          subtitle: Text('Number: ${currentSong.number}'),
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