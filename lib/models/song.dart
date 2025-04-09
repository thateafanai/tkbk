// lib/models/song.dart
import 'package:flutter/foundation.dart';

// Helper class to represent one part of the lyrics (e.g., a stanza or chorus)
class LyricPart {
  final String key; // e.g., "stanza1", "chorus"
  final String text;
  final bool isChorus;

  LyricPart({required this.key, required this.text, required this.isChorus});
}

// Central Song class definition
class Song {
  final int number;
  final String title;
  final List<LyricPart> lyrics; // Stores processed lyrics parts in order
  final String? translation;
  final String? musicKey;

  Song({
    required this.number,
    required this.title,
    required this.lyrics,
    this.translation,
    this.musicKey,
  });

  // Factory constructor to create Song from JSON
  factory Song.fromJson(Map<String, dynamic> json) {
    List<LyricPart> processedLyrics = [];
    try {
      final lyricsData = json['lyrics'];

      if (lyricsData is Map<String, dynamic>) {
        // Iterate through entries to preserve original JSON order
        for (var entry in lyricsData.entries) {
          final key = entry.key;
          final value = entry.value;
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
       processedLyrics.add(LyricPart(key: 'error', text: 'Error loading lyrics.', isChorus: false));
    }

    return Song(
      number: json['number'] as int,
      title: json['title'] as String,
      lyrics: processedLyrics, // Assign the ordered, processed list
      translation: json['translation'] as String?,
      musicKey: json['musicKey'] as String?,
    );
  }

  @override
  String toString() {
    return 'Song{number: $number, title: $title}';
  }
}