// lib/models/song.dart
import 'package:flutter/foundation.dart';

// Helper class to represent one part of the lyrics (e.g., a stanza or chorus)
class LyricPart {
  final String key; // e.g., "stanza1", "chorus"
  final String text;
  final bool isChorus;

  LyricPart({required this.key, required this.text, required this.isChorus});
}

// Updated Song class
class Song {
  final int number;
  final String title;
  final List<LyricPart> lyrics; // Changed to a list of LyricPart objects
  final String? translation;
  final String? musicKey;

  Song({
    required this.number,
    required this.title,
    required this.lyrics, // Now expects a List<LyricPart>
    this.translation,
    this.musicKey,
  });

  // Updated factory constructor to process the lyrics map into LyricPart list
  factory Song.fromJson(Map<String, dynamic> json) {
    List<LyricPart> processedLyrics = [];
    try {
      // Expect 'lyrics' to be a Map (like {"stanza1": "...", "chorus": "..."})
      final lyricsData = json['lyrics'];

      if (lyricsData is Map<String, dynamic>) {
        // Get the keys from the map (e.g., "stanza1", "chorus", "stanza2")
        List<String> keys = lyricsData.keys.toList();

        // Sort the keys to try and maintain a logical order (e.g., stanza1, stanza2, chorus)
        // This assumes keys are named consistently like stanzaN, chorus, etc.
        // You might need to adjust sorting logic if keys are very different.
        keys.sort(); // Simple alphabetical sort

        // Create a LyricPart for each key-value pair
        for (String key in keys) {
          final value = lyricsData[key];
          if (value is String) { // Ensure the value is a string
            processedLyrics.add(
              LyricPart(
                key: key,
                text: value,
                // Check if the key (lowercase) contains 'chorus'
                isChorus: key.toLowerCase().contains('chorus'),
              ),
            );
          } else {
             if (kDebugMode) {
              print("Warning: Non-string value found for key '$key' in lyrics for song number ${json['number']}");
             }
          }
        }
      } else {
         if (kDebugMode) {
           print("Warning: Unexpected lyrics format (not a Map) for song number ${json['number']}: $lyricsData");
         }
      }
    } catch (e) {
       if (kDebugMode) {
        print("Error processing lyrics structure for song number ${json['number']}: $e");
       }
       // Add a placeholder part indicating an error
       processedLyrics.add(LyricPart(key: 'error', text: 'Error loading lyrics.', isChorus: false));
    }

    // Return the Song object with the processed list of LyricParts
    return Song(
      number: json['number'] as int,
      title: json['title'] as String,
      lyrics: processedLyrics, // Assign the processed list
      translation: json['translation'] as String?,
      musicKey: json['musicKey'] as String?,
    );
  }

  @override
  String toString() {
    return 'Song{number: $number, title: $title}';
  }
}