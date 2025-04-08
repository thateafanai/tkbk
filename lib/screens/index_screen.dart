// lib/screens/index_screen.dart
import 'package:flutter/material.dart';
import '../models/song.dart';          // Import the Song model
import '../services/song_service.dart'; // Import the SongService to access songs
import 'song_detail_screen.dart';     // Import the detail screen for navigation

class IndexScreen extends StatelessWidget {
  const IndexScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Get the original list of songs (which is sorted by number)
    final List<Song> originalSongs = songService.songs;

    // Create a *new* list and sort it alphabetically by title (case-insensitive)
    // We create a copy so we don't change the original order in the service.
    final List<Song> sortedSongs = List<Song>.from(originalSongs)
      ..sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));

    // Basic check if songs are loaded
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

    // Build the screen with the alphabetically sorted list
    return Scaffold(
      appBar: AppBar(
        title: const Text('Index (Alphabetical)'),
      ),
      // Use ListView.builder for efficient list rendering
      body: ListView.builder(
        itemCount: sortedSongs.length, // Use the length of the sorted list
        itemBuilder: (BuildContext context, int index) {
          // Get the specific song for this row from the *sorted* list
          final Song currentSong = sortedSongs[index];

          // Use ListTile for a nicely formatted row
          return ListTile(
            // Display the song title as the main text
            title: Text(currentSong.title),
            // Display the song number on the right (trailing) side
            trailing: Text(
              currentSong.number.toString(),
              style: TextStyle( // Optional styling for the number
                 color: Theme.of(context).colorScheme.outline,
                 fontSize: 14,
              ),
            ),
            // Action to perform when the row is tapped
            onTap: () {
              // Navigate to the SongDetailScreen
              Navigator.push(
                context,
                MaterialPageRoute(
                  // Pass the 'currentSong' object (from the sorted list)
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