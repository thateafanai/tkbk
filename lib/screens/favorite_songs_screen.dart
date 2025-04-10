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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final baseColor = Theme.of(context).scaffoldBackgroundColor; // Use the scaffold background color

    // Define shadow and highlight colors based on the theme
    final Color shadowColor = isDarkMode ? Colors.black54 : Colors.grey.shade400;
    final Color highlightColor = isDarkMode ? Colors.grey.shade800 : Colors.white;
    final Color secondShadowColor = isDarkMode ? Colors.black45 : Colors.grey.shade300; // A slightly lighter shadow

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
      bottomNavigationBar: Container( // Wrap BottomNavigationBar with Container
        decoration: BoxDecoration(
          color: baseColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(15)), // Optional rounded corners
          boxShadow: [
            // Subtle top highlight
            BoxShadow(
              color: highlightColor,
              offset: const Offset(-1, -1),
              blurRadius: 3,
              spreadRadius: 0,
            ),
            // Primary bottom shadow
            BoxShadow(
              color: shadowColor,
              offset: const Offset(2, 2),
              blurRadius: 6,
              spreadRadius: 1,
            ),
            // Secondary, softer bottom shadow for more depth
            BoxShadow(
              color: secondShadowColor,
              offset: const Offset(3, 3),
              blurRadius: 8,
              spreadRadius: 1,
            ),
          ],
        ),
        child: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
          currentIndex: 0, // Changed currentIndex to 0
          onTap: (index) {
            if (index == 0) {
              Navigator.pushReplacementNamed(context, '/home');
            } else if (index == 1) {
              Navigator.pushReplacementNamed(context, '/settings');
            }
            // No need for index 2 as it doesn't exist in the items list
          },
          selectedItemColor: Theme.of(context).bottomNavigationBarTheme.selectedItemColor ?? Colors.blue,
          unselectedItemColor: Theme.of(context).bottomNavigationBarTheme.unselectedItemColor ?? Colors.grey,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent, // Make the BottomNavigationBar background transparent
          elevation: 0, // Remove default elevation
        ),
      ),
    );
  }
}