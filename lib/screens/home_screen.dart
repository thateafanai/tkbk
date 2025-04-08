// lib/screens/home_screen.dart
import 'package:flutter/material.dart';

// Import the placeholder screens we want to navigate to
import 'all_songs_screen.dart';
import 'search_by_number_screen.dart';
import 'favorite_songs_screen.dart';
import 'feedback_screen.dart';
import 'index_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // Helper function to create styled buttons (optional, but cleans up the code)
  Widget _buildHomeButton({
    required BuildContext context,
    required String label,
    required VoidCallback onPressed,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 32.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          textStyle: const TextStyle(fontSize: 18),
        ),
        onPressed: onPressed,
        child: Text(label),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Optional: Add an AppBar if you want a title bar on the home screen
      appBar: AppBar(
        title: const Text('TKBK Songbook'),
        // centerTitle: true, // Optional: Center the title
      ),
      body: Center( // Center the column vertically
        child: SingleChildScrollView( // Allow scrolling if screen is too small
         child: Column(
            mainAxisAlignment: MainAxisAlignment.center, // Center buttons vertically in the column
            crossAxisAlignment: CrossAxisAlignment.stretch, // Make buttons stretch horizontally
            children: <Widget>[
              _buildHomeButton(
                context: context,
                label: 'ALL SONGS',
                onPressed: () {
                  // Navigate to the AllSongsScreen placeholder
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AllSongsScreen()),
                  );
                },
              ),
              _buildHomeButton(
                context: context,
                label: 'SEARCH BY NUMBER',
                onPressed: () {
                  // Navigate to the SearchByNumberScreen placeholder
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SearchByNumberScreen()),
                  );
                },
              ),
              _buildHomeButton(
                context: context,
                label: 'FAVORITE SONGS',
                onPressed: () {
                  // Navigate to the FavoriteSongsScreen placeholder
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const FavoriteSongsScreen()),
                  );
                },
              ),
              _buildHomeButton(
                context: context,
                label: 'FEEDBACK',
                onPressed: () {
                  // Navigate to the FeedbackScreen placeholder
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const FeedbackScreen()),
                  );
                },
              ),
              _buildHomeButton(
                context: context,
                label: 'INDEX',
                onPressed: () {
                  // Navigate to the IndexScreen placeholder
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const IndexScreen()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}