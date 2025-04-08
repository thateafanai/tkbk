// lib/screens/search_by_number_screen.dart
import 'package:flutter/material.dart';
import '../models/song.dart';
import '../services/song_service.dart';
import 'song_detail_screen.dart';

class SearchByNumberScreen extends StatelessWidget {
  const SearchByNumberScreen({super.key});

  final int totalSongs = 237;

  @override
  Widget build(BuildContext context) {
    final List<Song> songs = songService.songs;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Search By Number'),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(12.0),
        itemCount: totalSongs,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          mainAxisSpacing: 10.0,
          crossAxisSpacing: 10.0,
          childAspectRatio: 1.6,
        ),
        itemBuilder: (BuildContext context, int index) {
          final int songNumber = index + 1;

          return ElevatedButton(
            style: ElevatedButton.styleFrom(
              // padding: EdgeInsets.zero,
            ),
            onPressed: () {
              Song? targetSong;
              try {
                 targetSong = songs.firstWhere(
                   (song) => song.number == songNumber,
                 );
              } catch (e) {
                 targetSong = null;
                 print('Song number $songNumber not found in the loaded list.');
              }

              // This 'if' check ensures targetSong is not null before proceeding
              if (targetSong != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    // *** THIS IS THE CORRECTED LINE ***
                    // Add '!' to assert that targetSong is not null here
                    builder: (context) => SongDetailScreen(song: targetSong!),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Song data for number $songNumber not found.'),
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            },
            child: Text(
              songNumber.toString(),
              style: const TextStyle(fontSize: 16),
            ),
          );
        },
      ),
    );
  }
}