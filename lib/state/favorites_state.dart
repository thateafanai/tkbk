// lib/state/favorites_state.dart
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/song.dart';
// Assuming songService is accessible globally or passed if needed for rehydration (not needed here)
// import '../services/song_service.dart';

const String _favoritesKey = 'favoriteSongNumbers';

class FavoritesState {
  FavoritesState._privateConstructor();
  static final FavoritesState instance = FavoritesState._privateConstructor();

  // Use ValueNotifier to hold the LIST OF FAVORITE SONG NUMBERS
  final ValueNotifier<List<int>> favoriteSongNumbersNotifier = ValueNotifier([]);

  // Getter to easily access the current list of numbers
  List<int> get favoriteNumbers => favoriteSongNumbersNotifier.value;

  // --- Load/Save Logic ---

  Future<void> loadFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // Load the list of strings, default to empty list if not found
      final List<String> numbersAsString = prefs.getStringList(_favoritesKey) ?? [];
      // Convert strings back to integers
      favoriteSongNumbersNotifier.value = numbersAsString
          .map((numStr) => int.tryParse(numStr)) // Attempt to parse each string
          .where((num) => num != null) // Filter out any that failed to parse
          .cast<int>() // Cast to non-nullable int
          .toList();
       if (kDebugMode) {
         print('Loaded favorite numbers: ${favoriteSongNumbersNotifier.value}');
       }
    } catch (e) {
      if (kDebugMode) {
        print('Error loading favorites: $e');
      }
      favoriteSongNumbersNotifier.value = []; // Reset on error
    }
  }

  Future<void> _saveFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // Convert the list of integers to a list of strings for saving
      final List<String> numbersAsString = favoriteSongNumbersNotifier.value
          .map((num) => num.toString())
          .toList();
      await prefs.setStringList(_favoritesKey, numbersAsString);
       if (kDebugMode) {
         print('Saved favorite numbers: $numbersAsString');
       }
    } catch (e) {
      if (kDebugMode) {
        print('Error saving favorites: $e');
      }
    }
  }

  // --- Public Methods ---

  // Check if a song's NUMBER is in the favorite list
  bool isFavorite(Song song) {
    return favoriteSongNumbersNotifier.value.contains(song.number);
  }

  // Toggle favorite status by song NUMBER
  void toggleFavorite(Song song) {
    final currentList = List<int>.from(favoriteSongNumbersNotifier.value); // Create mutable copy
    if (currentList.contains(song.number)) {
      currentList.remove(song.number); // Remove number
    } else {
      currentList.add(song.number); // Add number
    }
    // Update the notifier, which triggers listeners
    favoriteSongNumbersNotifier.value = currentList;
    // Save the updated list asynchronously
    _saveFavorites();
  }
}

// Global instance
final favoritesState = FavoritesState.instance; // Changed name slightly for clarity