// lib/services/song_service.dart
import 'dart:convert';
import 'package:flutter/foundation.dart'; // Import for kDebugMode check
import 'package:flutter/services.dart' show rootBundle;
import '../models/song.dart';

// Creates a single instance we can use anywhere
final SongService songService = SongService();

class SongService {
  List<Song> _songs = [];
  List<Song> get songs => _songs;

  Future<void> loadSongs() async {
    try {
      final String jsonString = await rootBundle.loadString('assets/songs.json');
      final List<dynamic> jsonList = jsonDecode(jsonString) as List<dynamic>;

      _songs = jsonList
          .map((jsonItem) {
             try {
               return Song.fromJson(jsonItem as Map<String, dynamic>);
             } catch (e) {
                // Handle potential errors during parsing of a single song item
                if (kDebugMode) {
                  print('Error parsing individual song: $jsonItem. Error: $e');
                }
                return null; // Return null if a song fails to parse
             }
          })
          .where((song) => song != null) // Filter out any songs that failed to parse (returned null)
          .cast<Song>() // Cast the result back to List<Song>
          .toList();

      // *** THIS IS THE CORRECTED LINE ***
      // Sort songs by the 'number' field (previously was songNumber)
      _songs.sort((a, b) => a.number.compareTo(b.number));

      if (kDebugMode) { // Only print success message in debug mode
        print('Successfully loaded and parsed ${_songs.length} songs.');
      }

    } catch (e) {
      // Handle errors during file loading or initial JSON decoding
      if (kDebugMode) {
       print('Error loading or decoding songs file: $e');
      }
      _songs = [];
    }
  }
}