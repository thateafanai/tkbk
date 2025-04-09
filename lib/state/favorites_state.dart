import '../models/song.dart';

class FavoritesState {
  FavoritesState._privateConstructor();
  static final FavoritesState instance = FavoritesState._privateConstructor();

  final List<Song> _favorites = [];

  List<Song> get favorites => List.unmodifiable(_favorites);

  bool isFavorite(Song song) {
    return _favorites.contains(song);
  }

  void toggleFavorite(Song song) {
    if (isFavorite(song)) {
      _favorites.remove(song);
    } else {
      _favorites.add(song);
    }
  }
}
