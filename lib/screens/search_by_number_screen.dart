// lib/screens/search_by_number_screen.dart
import 'package:flutter/material.dart';
import '../widgets/custom_header.dart'; // Import your custom header
import '../models/song.dart';
import '../services/song_service.dart';
import 'song_detail_screen.dart';

class SearchByNumberScreen extends StatelessWidget {
  const SearchByNumberScreen({super.key});

  final int totalSongs = 237;

  // --- Helper for Stateless, Styled Number Buttons ---
  Widget _buildNumberButton({
    required BuildContext context,
    required int number,
    required VoidCallback onPressed,
  }) {
    // Use ElevatedButton for default elevation and tap feedback
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.indigo[900], // Header color for text
        padding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0), // Rounded rectangle
        ),
        elevation: 2.0,
      ),
      onPressed: onPressed,
      child: Text(
        number.toString(),
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
  // --- End Helper Widget ---

  @override
  Widget build(BuildContext context) {
    final List<Song> songs = songService.songs;

    return Scaffold(
      // Use CustomHeader in the appBar slot for consistency
      appBar: const CustomHeader(
        title: 'Search By Number',
        showBackButton: true, // Make sure back button is enabled
      ),
      body: GridView.builder(
          // Padding includes extra space at the bottom now
          padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 32.0),
          itemCount: totalSongs,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            mainAxisSpacing: 10.0,
            crossAxisSpacing: 10.0,
            childAspectRatio: 1.5, // Rectangular buttons
          ),
          itemBuilder: (BuildContext context, int index) {
            final int songNumber = index + 1;

            // Use the stateless helper to build the button
            return _buildNumberButton(
              context: context,
              number: songNumber,
              onPressed: () {
                // Direct Navigation Logic
                Song? targetSong;
                try {
                  targetSong = songs.firstWhere(
                    (song) => song.number == songNumber,
                  );
                } catch (e) {
                  targetSong = null;
                  print('Song number $songNumber not found.');
                }

                if (targetSong != null) {
                   if (!context.mounted) return;
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SongDetailScreen(song: targetSong!),
                    ),
                  );
                } else {
                   if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Song data for number $songNumber not found.'),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }
              },
            );
          },
        ),
    );
  }
}