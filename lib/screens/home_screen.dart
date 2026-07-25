// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:tkbk/models/song.dart';
import 'package:tkbk/models/search_result.dart';
import 'package:tkbk/services/song_service.dart';
import 'package:tkbk/utils/route_observer.dart' as utils;

// Import screen destinations
import 'all_songs_screen.dart';
import 'search_by_number_screen.dart';
import 'favorite_songs_screen.dart';
import 'feedback_screen.dart';
import 'index_screen.dart';
import 'song_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with RouteAware {
  List<Song> _songs = [];
  List<SearchResult> _searchResults = [];
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _songs = songService.songs;
    _searchFocusNode.addListener(_onFocusChange);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (ModalRoute.of(context) is PageRoute) {
       utils.routeObserver.subscribe(this, ModalRoute.of(context)! as PageRoute);
    }
  }

  @override
  void didPopNext() { if (mounted) { _searchFocusNode.unfocus(); } }
  @override
  void didPushNext() { if (mounted) { _searchFocusNode.unfocus(); } }
  void _onFocusChange() { if (mounted) { setState(() {}); } }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    _searchFocusNode.removeListener(_onFocusChange);
    _searchFocusNode.dispose();
    utils.routeObserver.unsubscribe(this);
    super.dispose();
  }

  void _searchSongs(String query) {
     if (_debounceTimer?.isActive ?? false) _debounceTimer?.cancel();
     _debounceTimer = Timer(const Duration(milliseconds: 300), () {
       if (!mounted) return;
       setState(() {
         if (query.isEmpty) { _searchResults = []; }
         else {
           final lowerQuery = query.toLowerCase();
           _searchResults = _songs.expand((song) {
             List<SearchResult> results = [];
             // Use helper methods defined within the class
             final sentenceCaseTitle = _toSentenceCase(song.title);
             if (sentenceCaseTitle.toLowerCase().contains(lowerQuery)) {
               results.add(SearchResult(song: song, fieldName: 'Title', matchingLine: sentenceCaseTitle, searchTerm: query));
             }
             if (song.translation != null && song.translation!.toLowerCase().contains(lowerQuery)) {
               results.add(SearchResult(song: song, fieldName: 'Translation', matchingLine: song.translation!, searchTerm: query));
             }
             if (song.lyrics.isNotEmpty) {
               for (LyricPart part in song.lyrics) {
                 // Use helper methods defined within the class
                 final matchingLines = _findMatchingLines(part.text, lowerQuery);
                 results.addAll(matchingLines.map((line) => SearchResult(song: song, fieldName: _toSentenceCase(part.key), matchingLine: line, searchTerm: query)));
               }
             } return results;
           }).toList();
         }
       });
     });
  }

  // Design tokens (indigo + gold), matching the Scripture screens.
  static const Color _indigoLight = Color(0xFF1A237E);
  static const Color _indigoLight2 = Color(0xFF2C3AA0);
  static const Color _indigoDark = Color(0xFF131A57);
  static const Color _indigoDark2 = Color(0xFF1E2670);
  static const Color _goldLight = Color(0xFF9C7724);
  static const Color _goldDark = Color(0xFFD8B25A);
  static const Color _bgLight = Color(0xFFF6F5F2);
  static const Color _bgDark = Color(0xFF101120);
  static const Color _cardDark = Color(0xFF1A1C2B);

  // --- BUILD METHOD ---
  @override
  Widget build(BuildContext context) {
    bool showResultsOverlay = _searchController.text.isNotEmpty && _searchResults.isNotEmpty;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color homeBg = isDark ? _bgDark : _bgLight;
    final Color cardColor = isDark ? _cardDark : Colors.white;
    final Color gold = isDark ? _goldDark : _goldLight;
    final Color muted = isDark ? const Color(0xFF9298AE) : const Color(0xFF6E7488);
    final Color lineColor = isDark ? Colors.white.withValues(alpha: 0.08) : _indigoLight.withValues(alpha: 0.10);
    final Color textColor = Theme.of(context).textTheme.bodyLarge?.color ?? (isDark ? Colors.white : Colors.black);

    return Scaffold(
      backgroundColor: homeBg,
      body: Column(
        children: <Widget>[
          // Header with the search card overlapping its bottom edge. The Stack
          // reserves space below the header so the card stays inside its
          // parent's bounds (keeps taps working) while still overlapping.
          Stack(
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 28.0),
                child: _buildHeroHeader(context, isDark),
              ),
              Positioned(
                left: 18.0,
                right: 18.0,
                bottom: 0,
                child: _buildSearchCard(cardColor, muted),
              ),
            ],
          ),
          Expanded( // Main content area
            child: Stack(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(18.0, 18.0, 18.0, 28.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      _buildFeatureGrid(context, cardColor, gold, muted, textColor, isDark),
                      const SizedBox(height: 12),
                      _buildFeedbackRow(context, muted, gold, lineColor),
                      const SizedBox(height: 22),
                      _buildVerseCard(cardColor, gold, textColor, muted, isDark),
                    ],
                  ),
                ),
                // Search Results Overlay
                if (showResultsOverlay) Positioned.fill( child: GestureDetector( onTap: () => _searchFocusNode.unfocus(), child: Container( color: homeBg.withValues(alpha: 0.98),
                        child: ListView.builder( padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0), itemCount: _searchResults.length,
                          itemBuilder: (context, index) { final SearchResult result = _searchResults[index]; final originalTitle = result.song.title;
                            return Card( margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 4.0), color: Theme.of(context).cardColor, elevation: 1.0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                              child: ListTile(
                                // Call highlight method from THIS class
                                title: RichText(text: _highlightSearchTerm(result.matchingLine, result.searchTerm), maxLines: 2, overflow: TextOverflow.ellipsis),
                                subtitle: Text("${result.song.number}. $originalTitle (Match in: ${result.fieldName})", maxLines: 1, overflow: TextOverflow.ellipsis),
                                onTap: () { _searchFocusNode.unfocus(); Navigator.push(context, MaterialPageRoute(builder: (context) => SongDetailScreen(song: result.song))); },
                              ), ); }, ), ), ), ), // <<<--- Added Comma
                 // No Results Message
                 if (_searchController.text.isNotEmpty && _searchResults.isEmpty) Positioned.fill( child: GestureDetector( onTap: () => _searchFocusNode.unfocus(), child: Container( color: homeBg.withValues(alpha: 0.95), child: const Center(child: Text("No results found.")) ), ), )
              ], // End Stack children
            ), // End Stack
          ), // End Expanded
        ],
      ),
    );
  }


  // --- Helper Functions MOVED INSIDE _HomeScreenState ---

  // Hero header: app mark, title, and a live song-count tagline, on an
  // indigo diagonal gradient with rounded bottom corners.
  Widget _buildHeroHeader(BuildContext context, bool isDark) {
    final gradientColors = isDark ? [_indigoDark, _indigoDark2] : [_indigoLight, _indigoLight2];
    final songCount = songService.songs.length;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(20.0, MediaQuery.of(context).padding.top + 26.0, 20.0, 46.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: gradientColors),
        borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(26.0), bottomRight: Radius.circular(26.0)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.25), blurRadius: 16.0, offset: const Offset(0, 6))],
      ),
      child: Column(
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.14), borderRadius: BorderRadius.circular(11.0)),
            child: const Icon(Icons.menu_book, color: Colors.white, size: 22),
          ),
          const SizedBox(height: 10),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: const Text(
              'Apatani Kristan Biisi Kheta',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 17, letterSpacing: 0.2),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            '$songCount hymns, always with you',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.72), fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchCard(Color cardColor, Color muted) {
    return Material(
      color: cardColor,
      borderRadius: BorderRadius.circular(16.0),
      elevation: 6,
      shadowColor: Colors.black.withValues(alpha: 0.18),
      child: TextField(
        controller: _searchController, focusNode: _searchFocusNode,
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.search, color: muted),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(icon: Icon(Icons.clear, color: muted), onPressed: () { _searchController.clear(); _searchSongs(''); _searchFocusNode.unfocus(); })
              : null,
          hintText: 'Search songs or lyrics...', hintStyle: TextStyle(color: muted),
          filled: true, fillColor: Colors.transparent,
          border: InputBorder.none, enabledBorder: InputBorder.none, focusedBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16.0),
        ),
        onChanged: _searchSongs,
      ),
    );
  }

  // 2x2 grid of the app's browsing destinations.
  Widget _buildFeatureGrid(BuildContext context, Color cardColor, Color gold, Color muted, Color textColor, bool isDark) {
    return Column(
      children: [
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: _buildFeatureTile(
                context: context, cardColor: cardColor, gold: gold, muted: muted, textColor: textColor, isDark: isDark,
                icon: Icons.library_music_outlined, label: 'All Songs', subtitle: 'Browse the full hymnal',
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AllSongsScreen())),
              )),
              const SizedBox(width: 12),
              Expanded(child: _buildFeatureTile(
                context: context, cardColor: cardColor, gold: gold, muted: muted, textColor: textColor, isDark: isDark,
                icon: Icons.numbers, label: 'By Number', subtitle: 'Jump straight to a hymn',
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SearchByNumberScreen())),
              )),
            ],
          ),
        ),
        const SizedBox(height: 12),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: _buildFeatureTile(
                context: context, cardColor: cardColor, gold: gold, muted: muted, textColor: textColor, isDark: isDark,
                icon: Icons.favorite_border, label: 'Favorites', subtitle: 'Your saved songs',
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const FavoriteSongsScreen())),
              )),
              const SizedBox(width: 12),
              Expanded(child: _buildFeatureTile(
                context: context, cardColor: cardColor, gold: gold, muted: muted, textColor: textColor, isDark: isDark,
                icon: Icons.sort_by_alpha, label: 'Index', subtitle: 'A–Z by title',
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const IndexScreen())),
              )),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureTile({
    required BuildContext context,
    required Color cardColor,
    required Color gold,
    required Color muted,
    required Color textColor,
    required bool isDark,
    required IconData icon,
    required String label,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: cardColor,
      borderRadius: BorderRadius.circular(16.0),
      elevation: isDark ? 0 : 2,
      shadowColor: Colors.black.withValues(alpha: 0.12),
      child: InkWell(
        borderRadius: BorderRadius.circular(16.0),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 38, height: 38,
                decoration: BoxDecoration(color: gold.withValues(alpha: 0.16), borderRadius: BorderRadius.circular(11.0)),
                child: Icon(icon, color: gold, size: 20),
              ),
              const SizedBox(height: 10),
              Text(label, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5, color: textColor)),
              const SizedBox(height: 3),
              Text(subtitle, style: TextStyle(fontSize: 11.5, color: muted), maxLines: 2, overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ),
    );
  }

  // Feedback, demoted to a quiet utility row rather than a fourth peer tile.
  Widget _buildFeedbackRow(BuildContext context, Color muted, Color gold, Color lineColor) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(14.0),
      child: InkWell(
        borderRadius: BorderRadius.circular(14.0),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const FeedbackScreen())),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(14.0), border: Border.all(color: lineColor)),
          child: Row(
            children: [
              Icon(Icons.feedback_outlined, size: 18, color: muted),
              const SizedBox(width: 10),
              Expanded(child: Text('Need help or have a suggestion?', style: TextStyle(fontSize: 12.5, color: muted))),
              Text('FEEDBACK', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.4, color: gold)),
              Icon(Icons.chevron_right, size: 16, color: gold),
            ],
          ),
        ),
      ),
    );
  }

  // Verse of the day, styled to match the Scripture detail screen.
  Widget _buildVerseCard(Color cardColor, Color gold, Color textColor, Color muted, bool isDark) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20.0, 22.0, 20.0, 20.0),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18.0),
        boxShadow: isDark ? null : [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 16.0, offset: const Offset(0, 6))],
      ),
      child: Column(
        children: [
          _buildOrnament(gold),
          const SizedBox(height: 14),
          Text(
            '"Bless the LORD, O my soul; and all that is within me, bless his holy name."',
            textAlign: TextAlign.center,
            style: TextStyle(fontFamily: 'Georgia', fontSize: 15.5, height: 1.6, color: textColor),
          ),
          const SizedBox(height: 10),
          Text('— Psalm 103:1', style: TextStyle(fontSize: 11.5, fontStyle: FontStyle.italic, color: muted, letterSpacing: 0.3)),
        ],
      ),
    );
  }

  Widget _buildOrnament(Color gold) {
    Widget rule() => Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [gold.withValues(alpha: 0), gold.withValues(alpha: 0.55), gold.withValues(alpha: 0)]),
            ),
          ),
        );
    return SizedBox(
      width: 130,
      child: Row(children: [rule(), Padding(padding: const EdgeInsets.symmetric(horizontal: 8), child: Icon(Icons.star, size: 8, color: gold)), rule()]),
    );
  }

  // Helper function to find matching lines
  List<String> _findMatchingLines(String text, String query) {
    if (query.isEmpty) return [];
    final lines = text.split('\n');
    return lines.where((line) => line.toLowerCase().contains(query.toLowerCase())).toList();
  }

  // Helper function for sentence case
  String _toSentenceCase(String? text) { // Renamed slightly to avoid conflict
    if (text == null || text.isEmpty) return '';
    if (text.isEmpty) return '';
    // Handle keys like 'stanza1' -> 'Stanza1'
    if (text.contains(RegExp(r'[0-9]'))) {
        // Simple capitalize first letter if it contains numbers
        return text[0].toUpperCase() + text.substring(1);
    }
    // Otherwise, full sentence case
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  // Helper function to highlight search term
  TextSpan _highlightSearchTerm(String text, String searchTerm) {
     final TextStyle defaultStyle = TextStyle(color: Colors.grey[600]);
     final TextStyle highlightStyle = const TextStyle( fontWeight: FontWeight.bold, backgroundColor: Colors.yellow, color: Colors.black );
     if (searchTerm.isEmpty || text.isEmpty) { return TextSpan(text: text, style: defaultStyle); }
     final lowerCaseText = text.toLowerCase();
     final lowerCaseSearchTerm = searchTerm.toLowerCase();
     final List<TextSpan> spans = [];
     int start = 0;
     int indexOfHighlight;
     while (start < text.length) {
       indexOfHighlight = lowerCaseText.indexOf(lowerCaseSearchTerm, start);
       if (indexOfHighlight < 0) { spans.add(TextSpan(text: text.substring(start), style: defaultStyle)); break; }
       if (indexOfHighlight > start) { spans.add(TextSpan(text: text.substring(start, indexOfHighlight), style: defaultStyle)); }
       final endIndex = indexOfHighlight + searchTerm.length;
       spans.add(TextSpan(text: text.substring(indexOfHighlight, endIndex), style: highlightStyle));
       start = endIndex;
     }
     return TextSpan(children: spans);
  }
  // --- END Helper Functions ---
} // End of _HomeScreenState class
