// lib/screens/index_screen.dart
import 'package:flutter/material.dart';
import '../models/song.dart';
import '../services/song_service.dart';
import '../state/settings_state.dart';
import '../widgets/custom_header.dart';
import '../widgets/song_list_item.dart'; // Import the list item WIDGET
import '../screens/song_detail_screen.dart';

class IndexScreen extends StatelessWidget {
  const IndexScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Song> originalSongs = songService.songs;
    // This list holds the alphabetically sorted songs
    final List<Song> sortedSongs = List<Song>.from(originalSongs)
      ..sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));

    if (sortedSongs.isEmpty) {
       return const Scaffold(
         appBar: CustomHeader(title: 'Index (Alphabetical)', showBackButton: true),
         body: Center(child: Text('No songs loaded.')),
       );
     }

    // Listen to font size changes
    return ValueListenableBuilder<double>(
        valueListenable: settingsState.fontSize,
        builder: (context, _, child) {
           // Calculate factor based on current font size from state
           final double fontSizeFactor = settingsState.fontSizeFactor;

           return Scaffold(
             appBar: const CustomHeader(title: 'Index (Alphabetical)', showBackButton: true),
             body: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                // Use the length of the sorted list
                itemCount: sortedSongs.length,
                itemBuilder: (BuildContext context, int index) {
                  // Get the song from the CORRECT list variable: sortedSongs
                  final Song currentSong = sortedSongs[index];

                  // Instantiate the SongListItem widget class using the correct song object
                  return SongListItem(
                    // Use key based on the song from the correct list
                    key: ValueKey(currentSong.number),
                    // Pass the song from the correct list
                    song: currentSong,
                    fontSizeFactor: fontSizeFactor,
                  );
                },
             ),
           );
        }
    );
  }
}