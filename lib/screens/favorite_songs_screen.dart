// lib/screens/favorite_songs_screen.dart
import 'package:flutter/material.dart';
import '../models/song.dart';
import '../services/song_service.dart';
import '../state/favorites_state.dart';
import '../state/settings_state.dart';
import '../widgets/custom_header.dart';
import '../screens/song_detail_screen.dart';
import '../widgets/song_list_item.dart';

// --- Local Helper function specific to this screen ---
Widget _buildSongListItem(BuildContext context, Song song, double fontSizeFactor) {
  // (Paste the exact same function definition from AllSongsScreen here)
  final textTheme = Theme.of(context).textTheme;
  final titleStyle = textTheme.titleMedium?.copyWith(fontSize: (textTheme.titleMedium?.fontSize ?? 16.0) * fontSizeFactor);
  final subtitleStyle = textTheme.bodyMedium?.copyWith(fontSize: (textTheme.bodyMedium?.fontSize ?? 14.0) * fontSizeFactor);
  final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
  final Color shadowColor = isDarkMode ? Colors.black.withOpacity(0.3) : Colors.black.withOpacity(0.1);
  final Color highlightColor = isDarkMode ? Colors.white.withOpacity(0.1) : Colors.white.withOpacity(0.7);

  return Card(
    margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 4.0),
    color: Theme.of(context).cardColor, elevation: 0,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
    child: Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(blurRadius: 4.0, spreadRadius: 1.0, offset: const Offset(-2, -2), color: highlightColor),
          BoxShadow(blurRadius: 4.0, spreadRadius: 1.0, offset: const Offset(2, 2), color: shadowColor),
        ],
      ),
      child: InkWell(
         borderRadius: BorderRadius.circular(8.0),
         onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => SongDetailScreen(song: song))),
         child: Padding(
           padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
           child: Row(
             children: [
                Text("${song.number}.", style: subtitleStyle?.copyWith(color: Theme.of(context).colorScheme.primary)),
                 const SizedBox(width: 12),
                 Expanded(
                   child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                         Text(song.title, style: titleStyle, maxLines: 1, overflow: TextOverflow.ellipsis),
                         if (song.translation != null && song.translation!.isNotEmpty)
                           Padding(padding: const EdgeInsets.only(top: 2.0), child: Text(song.translation!, style: subtitleStyle, maxLines: 1, overflow: TextOverflow.ellipsis)),
                       ],
                    ),
                 ),
             ],
           ),
         ),
      ),
    ),
  );
}
// --- END Local Helper ---


class FavoriteSongsScreen extends StatelessWidget {
  const FavoriteSongsScreen({super.key});

  @override
  Widget build(BuildContext context) {

    return ValueListenableBuilder<List<int>>(
      valueListenable: favoritesState.favoriteSongNumbersNotifier,
      builder: (context, favoriteNumbers, child) {

        final List<Song> favoriteSongs = songService.songs
            .where((song) => favoriteNumbers.contains(song.number))
            .toList();
        favoriteSongs.sort((a, b) => a.number.compareTo(b.number));

         return ValueListenableBuilder<double>(
            valueListenable: settingsState.fontSize,
            builder: (context, _, child) {
               final double fontSizeFactor = settingsState.fontSizeFactor;

               return Scaffold(
                  appBar: const CustomHeader(title: 'Favorite Songs', showBackButton: true),
                  body: favoriteSongs.isEmpty
                      ? Center(
                          child: Text(
                            'No favorite songs marked yet.',
                            style: TextStyle(fontSize: 16 * fontSizeFactor, color: Colors.grey[600]),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                          itemCount: favoriteSongs.length,
                          itemBuilder: (BuildContext context, int index) {
                        // Instantiate the SongListItem widget class
                        return SongListItem(
                          key: ValueKey(favoriteSongs[index].number), // Add key
                          song: favoriteSongs[index],
                          fontSizeFactor: fontSizeFactor,
                        );
                      },
                        ),
                );
             }
         );
      },
    );
  }
}