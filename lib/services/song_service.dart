// lib/services/song_service.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import '../models/song.dart'; // Import the central Song model

// Global instance of the service
final SongService songService = SongService();

class SongService {
  List<Song> _songs = [];
  List<Song> get songs => _songs; // Public getter for the loaded songs

  Future<void> loadSongs() async {
    // Clear previous songs in case of reload
    _songs = [];
    try {
      final String jsonString = await rootBundle.loadString('assets/songs.json');
      final List<dynamic> jsonList = jsonDecode(jsonString) as List<dynamic>;

      List<Song?> potentiallyNullSongs = jsonList.map((jsonItem) {
         try {
           // Attempt to parse each item using the Song.fromJson factory
           return Song.fromJson(jsonItem as Map<String, dynamic>);
         } catch (e) {
            // If parsing a single song fails, print error and return null
            if (kDebugMode) {
              print('Error parsing individual song: $jsonItem. Error: $e');
            }
            return null; // Indicates failure for this specific song item
         }
      }).toList();

       // Filter out any nulls (songs that failed to parse) and cast back to non-nullable
      _songs = potentiallyNullSongs.where((song) => song != null).cast<Song>().toList();

      // Sort the successfully loaded songs by number
      _songs.sort((a, b) => a.number.compareTo(b.number));

      if (kDebugMode) {
        print('Successfully loaded and parsed ${_songs.length} songs.');
      }

    } catch (e) {
      // Handle errors during file loading or initial JSON decoding of the whole list
      if (kDebugMode) {
       print('Fatal Error loading or decoding songs file: $e');
      }
      _songs = []; // Ensure songs list is empty on fatal error
    }
  }
}