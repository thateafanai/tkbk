// lib/models/search_result.dart
import 'song.dart'; // Import the central Song model

class SearchResult {
  final Song song; // Uses the correct Song type
  final String fieldName; // e.g., "title", "stanza1", "chorus"
  final String matchingLine; // The line containing the match
  final String searchTerm; // The term that was searched for

  SearchResult({
    required this.song,
    required this.fieldName,
    required this.matchingLine,
    required this.searchTerm,
  });
}