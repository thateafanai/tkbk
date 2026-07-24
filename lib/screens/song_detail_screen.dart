// lib/screens/song_detail_screen.dart
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import '../models/song.dart';
import '../services/song_service.dart';
import '../state/favorites_state.dart';
import '../state/settings_state.dart';
import '../widgets/custom_header.dart';

class SongDetailScreen extends StatefulWidget {
  final Song song;
  final double? initialFontSize; // carried across swipe navigation
  const SongDetailScreen({super.key, required this.song, this.initialFontSize});
  @override
  State<SongDetailScreen> createState() => _SongDetailScreenState();
}

class _SongDetailScreenState extends State<SongDetailScreen> {
  double _currentFontSize = 16.0;
  final double _minFontSize = 10.0;
  final double _maxFontSize = 30.0;

  // --- Pinch-to-zoom: track active fingers and scale the font live ---
  final Map<int, Offset> _pointers = {};
  double? _pinchStartDistance;
  double _pinchStartFontSize = 16.0;

  // --- Pitch pipe: play the song's key note ---
  final AudioPlayer _player = AudioPlayer();
  bool _isPlaying = false;
  // Chromatic tone files (assets/tones/*.wav), index 0 = C .. 11 = B.
  static const List<String> _noteFiles = [
    'C', 'Db', 'D', 'Eb', 'E', 'F', 'Gb', 'G', 'Ab', 'A', 'Bb', 'B'
  ];
  static const Map<String, int> _letterIndex = {
    'C': 0, 'D': 2, 'E': 4, 'F': 5, 'G': 7, 'A': 9, 'B': 11
  };

  @override
  void initState() {
    super.initState();
    _currentFontSize = widget.initialFontSize ?? _currentFontSize;
    _player.onPlayerComplete.listen((_) {
      if (mounted) setState(() => _isPlaying = false);
    });
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  // Resolves a key string ("G", "Db", "Ab/G", "E, lah is Em") to its tone asset,
  // or null if there's no recognizable root note.
  String? _toneAssetForKey(String? key) {
    if (key == null) return null;
    final s = key.trim();
    if (s.isEmpty) return null;
    final base = _letterIndex[s[0].toUpperCase()];
    if (base == null) return null;
    int idx = base;
    if (s.length > 1) {
      final accidental = s[1];
      if (accidental == 'b' || accidental == '♭') {
        idx -= 1;
      } else if (accidental == '#' || accidental == '♯') {
        idx += 1;
      }
    }
    idx = (idx + 12) % 12;
    return 'tones/${_noteFiles[idx]}.wav';
  }

  Future<void> _togglePitch(String asset) async {
    try {
      if (_isPlaying) {
        await _player.stop();
        if (mounted) setState(() => _isPlaying = false);
        return;
      }
      await _player.stop();
      await _player.play(AssetSource(asset));
      if (mounted) setState(() => _isPlaying = true);
    } catch (_) {
      if (mounted) setState(() => _isPlaying = false);
    }
  }

  Widget _buildPitchButton(String asset) {
    final primary = Theme.of(context).colorScheme.primary;
    return Material(
      color: primary.withOpacity(0.10),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => _togglePitch(asset),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(_isPlaying ? Icons.stop_rounded : Icons.music_note, size: 18, color: primary),
              const SizedBox(width: 5),
              Text(_isPlaying ? 'Stop' : 'Hear key',
                  style: TextStyle(color: primary, fontWeight: FontWeight.w600, fontSize: 13)),
            ],
          ),
        ),
      ),
    );
  }

  bool get _isPinching => _pointers.length >= 2;

  void _onPointerDown(PointerDownEvent e) {
    _pointers[e.pointer] = e.position;
    if (_pointers.length == 2) {
      _pinchStartDistance = _pointerDistance();
      _pinchStartFontSize = _currentFontSize;
    }
    setState(() {}); // refresh scroll physics (disabled while pinching)
  }

  void _onPointerMove(PointerMoveEvent e) {
    if (!_pointers.containsKey(e.pointer)) return;
    _pointers[e.pointer] = e.position;
    if (_isPinching && _pinchStartDistance != null && _pinchStartDistance! > 0) {
      final scale = _pointerDistance() / _pinchStartDistance!;
      final newSize = (_pinchStartFontSize * scale).clamp(_minFontSize, _maxFontSize);
      if ((newSize - _currentFontSize).abs() > 0.1) {
        setState(() => _currentFontSize = newSize);
      }
    }
  }

  void _onPointerEnd(PointerEvent e) {
    _pointers.remove(e.pointer);
    if (_pointers.length < 2) _pinchStartDistance = null;
    setState(() {});
  }

  double _pointerDistance() {
    final pts = _pointers.values.toList();
    return (pts[0] - pts[1]).distance;
  }

  // --- Swipe navigation: left = next song, right = previous ---
  void _goToAdjacent(int direction) {
    final songs = songService.songs; // sorted by number
    final idx = songs.indexWhere((s) => s.number == widget.song.number);
    if (idx == -1) return;
    final targetIdx = idx + direction;
    if (targetIdx < 0 || targetIdx >= songs.length) {
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(direction > 0 ? 'This is the last song.' : 'This is the first song.'),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ));
      return;
    }
    final target = songs[targetIdx];
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 260),
        pageBuilder: (_, __, ___) =>
            SongDetailScreen(song: target, initialFontSize: _currentFontSize),
        transitionsBuilder: (_, animation, __, child) {
          final begin = Offset(direction > 0 ? 1.0 : -1.0, 0.0);
          return SlideTransition(
            position: Tween(begin: begin, end: Offset.zero)
                .animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
            child: child,
          );
        },
      ),
    );
  }

  // Returns the verse number (e.g. "1") for stanza keys, or a display name
  // (e.g. "Chorus") for non-stanza parts like chorus/refrain/outro.
  String _verseLabel(String key) {
    final match = RegExp(r'^stanza(\d+)$').firstMatch(key.toLowerCase());
    if (match != null) return match.group(1)!;
    if (key.isEmpty) return key;
    return key[0].toUpperCase() + key.substring(1).toLowerCase();
  }

  Widget _buildLyricPart(LyricPart part, TextStyle? baseStyle, TextStyle? italicStyle) {
    final label = _verseLabel(part.key);
    final bool isVerseNumber = int.tryParse(label) != null;
    final labelStyle = baseStyle?.copyWith(
      fontWeight: FontWeight.bold,
      color: Theme.of(context).colorScheme.primary,
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 28.0,
            child: Text(isVerseNumber ? label : '', style: labelStyle),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!isVerseNumber)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4.0),
                    child: Text(label, style: labelStyle?.copyWith(fontStyle: FontStyle.italic)),
                  ),
                Text(part.text, style: part.isChorus ? italicStyle : baseStyle),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final baseStyle = Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.6, fontSize: _currentFontSize);
    final italicStyle = baseStyle?.copyWith(fontStyle: FontStyle.italic);
    final infoStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.outline);

    return Scaffold(
      appBar: CustomHeader(
        title: '${widget.song.number}. ${widget.song.title}',
        showBackButton: true,
        actions: [
          ValueListenableBuilder<List<int>>(
            valueListenable: favoritesState.favoriteSongNumbersNotifier,
            builder: (context, favoriteNumbers, child) {
              final bool isFavorite = favoriteNumbers.contains(widget.song.number);
              return IconButton(
                icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border, color: Colors.white),
                tooltip: isFavorite ? 'Remove from Favorites' : 'Mark as Favorite',
                onPressed: () {
                  favoritesState.toggleFavorite(widget.song);
                  ScaffoldMessenger.of(context).removeCurrentSnackBar();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(favoritesState.isFavorite(widget.song) ? 'Added to favorites.' : 'Removed from favorites.'),
                      duration: const Duration(seconds: 1),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              );
            }
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Listener(
              onPointerDown: _onPointerDown,
              onPointerMove: _onPointerMove,
              onPointerUp: _onPointerEnd,
              onPointerCancel: _onPointerEnd,
              child: GestureDetector(
                onHorizontalDragEnd: (details) {
                  if (_isPinching) return;
                  final v = details.primaryVelocity ?? 0;
                  if (v < -100) {
                    _goToAdjacent(1); // swipe left → next
                  } else if (v > 100) {
                    _goToAdjacent(-1); // swipe right → previous
                  }
                },
                child: SingleChildScrollView(
                  physics: _isPinching
                      ? const NeverScrollableScrollPhysics()
                      : const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  // Translation and Key
                  if (widget.song.translation != null && widget.song.translation!.isNotEmpty)
                    Padding(padding: const EdgeInsets.only(bottom: 4.0), child: Text('Translation: ${widget.song.translation}', style: infoStyle)),
                  if (widget.song.musicKey != null && widget.song.musicKey!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: Row(
                        children: [
                          Text('Key: ${widget.song.musicKey}', style: infoStyle),
                          if (_toneAssetForKey(widget.song.musicKey) != null) ...[
                            const SizedBox(width: 12),
                            _buildPitchButton(_toneAssetForKey(widget.song.musicKey)!),
                          ],
                        ],
                      ),
                    ),
                  if ((widget.song.translation != null && widget.song.translation!.isNotEmpty) || (widget.song.musicKey != null && widget.song.musicKey!.isNotEmpty))
                     const Divider(height: 20, thickness: 1),
                  // Lyrics
                  for (LyricPart part in widget.song.lyrics)
                    _buildLyricPart(part, baseStyle, italicStyle),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // --- Fixed Font Size Slider Area (Adjusted Padding) ---
          Padding(
            // Reduce top/bottom padding, keep accounting for system inset
            padding: EdgeInsets.fromLTRB(
                12.0,
                4.0, // Reduced top padding
                12.0,
                MediaQuery.of(context).padding.bottom + 8.0 // Reduced extra space
            ),
            child: Row(
              children: [
                 // Use smaller text style for label
                Text(
                  'Font Size:',
                  style: Theme.of(context).textTheme.labelSmall, // Smaller label
                ),
                const SizedBox(width: 8), // Add small gap
                Expanded(
                  child: Slider(
                    value: _currentFontSize,
                    min: _minFontSize, max: _maxFontSize,
                    divisions: (_maxFontSize - _minFontSize).round(),
                    label: _currentFontSize.round().toString(),
                    // Make slider visually smaller if possible
                    activeColor: Theme.of(context).colorScheme.primary, // Use theme color
                    inactiveColor: Theme.of(context).colorScheme.primary.withOpacity(0.3), // Lighter inactive track
                    onChanged: (double value) { setState(() { _currentFontSize = value; }); },
                  ),
                ),
              ],
            ),
          ),
          // --- End of Fixed Slider Area ---
        ],
      ),
    );
  }
}