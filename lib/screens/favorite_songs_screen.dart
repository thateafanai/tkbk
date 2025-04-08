// lib/screens/favorite_songs_screen.dart
import 'package:flutter/material.dart';

class FavoriteSongsScreen extends StatelessWidget {
  const FavoriteSongsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorite Songs'),
      ),
      body: const Center(
        child: Text('Favorite Songs Screen - Placeholder'),
      ),
    );
  }
}