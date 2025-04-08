// lib/screens/all_songs_screen.dart
import 'package:flutter/material.dart';
import '../models/song.dart'; // Import the Song model
import '../services/song_service.dart'; // Import the SongService to access the loaded songs
import 'song_detail_screen.dart'; // Import the detail screen to navigate to

class AllSongsScreen extends StatelessWidget {
  const AllSongsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Get the list of songs that was loaded by our SongService
    final List<Song> songs = songService.songs; // Access the global instance

    // Check if songs haven't loaded yet (basic check)
    if (songs.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('All Songs'),
        ),
        body: const Center(
          child: Text('No songs loaded. Check assets/songs.json and restart the app.'),
        ),
      );
    }

    // If songs are loaded, build the list
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Songs'),
      ),
      // Use ListView.builder for efficient list rendering
      body: ListView.builder(
        // How many items are in the list?
        itemCount: songs.length,
        // How to build each item (list row)
        itemBuilder: (BuildContext context, int index) {
          // Get the specific song for this row
          final Song currentSong = songs[index];

          // Use ListTile for a nicely formatted row
          return ListTile(
            // Display the song number on the left (leading) side
            leading: CircleAvatar(
              // Use the theme's primary color for background
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary, // Text color on the circle
              child: Text(currentSong.number.toString()),
            ),
            // Display the song title as the main text
            title: Text(currentSong.title),
            // Display the translation as subtitle, only if it exists and is not empty
            subtitle: (currentSong.translation != null && currentSong.translation!.isNotEmpty)
                ? Text(currentSong.translation!)
                : null, // If no translation, show nothing here
            // Action to perform when the row is tapped
            onTap: () {
              // Navigate to the SongDetailScreen
              Navigator.push(
                context,
                MaterialPageRoute(
                  // Pass the 'currentSong' object to the SongDetailScreen
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