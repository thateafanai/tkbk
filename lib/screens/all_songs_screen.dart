// lib/screens/all_songs_screen.dart
import 'package:flutter/material.dart';
import 'package:tkbk/widgets/custom_header.dart';
import '../models/song.dart';
import '../services/song_service.dart';
import 'song_detail_screen.dart';

class AllSongsScreen extends StatelessWidget {
  const AllSongsScreen({Key? key}) : super(key: key); // Added Key? key

  @override
  Widget build(BuildContext context) {
    final List<Song> songs = songService.songs;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(), // Dismiss keyboard
      child: Scaffold(
        body: Column(
          children: [
            const CustomHeader(title: 'All Songs'),
            Expanded(
              child: songs.isEmpty
                  ? const Center(
                      child: Text('No songs loaded. Check assets/songs.json and restart the app.'),
                    )
                  : ListView.separated(
                      itemCount: songs.length,
                      separatorBuilder: (BuildContext context, int index) => const Divider(),
                      itemBuilder: (BuildContext context, int index) {
                        final Song currentSong = songs[index];

                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Theme.of(context).colorScheme.primary,
                            foregroundColor: Theme.of(context).colorScheme.onPrimary,
                            child: Text(currentSong.number.toString()),
                          ),
                          title: Text(currentSong.title),
                          subtitle: (currentSong.translation != null && currentSong.translation!.isNotEmpty)
                              ? Text(currentSong.translation!)
                              : null,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SongDetailScreen(song: currentSong),
                              ),
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}