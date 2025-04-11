// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:tkbk/models/song.dart';
import 'package:tkbk/models/search_result.dart';
import 'package:tkbk/services/song_service.dart';
import 'package:tkbk/utils/route_observer.dart' as utils;
import 'package:tkbk/widgets/custom_header.dart';

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

  // --- BUILD METHOD ---
  @override
  Widget build(BuildContext context) {
    bool showResultsOverlay = _searchController.text.isNotEmpty && _searchResults.isNotEmpty;
    final Color baseColor = Theme.of(context).scaffoldBackgroundColor;
    final Color surfaceColor = Theme.of(context).colorScheme.surfaceVariant;

    return Scaffold(
      backgroundColor: baseColor,
      body: Column(
        children: <Widget>[
          const CustomHeader(title: 'APATANI BIISI KHETA'),
          Padding( // Search Bar Area
            padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
            child: Material( // Standard Material Search Bar
              elevation: 3.0, color: surfaceColor, shadowColor: Colors.black.withOpacity(0.2),
              borderRadius: BorderRadius.circular(30.0),
              child: TextField(
                controller: _searchController, focusNode: _searchFocusNode,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(icon: Icon(Icons.clear, color: Colors.grey[600]), onPressed: () { _searchController.clear(); _searchSongs(''); _searchFocusNode.unfocus(); })
                      : null,
                  hintText: 'Search songs or lyrics...', hintStyle: TextStyle(color: Colors.grey[600]),
                  filled: true, fillColor: Colors.transparent,
                  border: InputBorder.none, enabledBorder: InputBorder.none, focusedBorder: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 16.0),
                ),
                onChanged: _searchSongs,
              ),
            ),
          ),
          Expanded( // Main content area
            child: Stack(
              children: [
                SingleChildScrollView( // Buttons Area
                  padding: const EdgeInsets.only(top: 16.0, bottom: 16.0),
                  child: Column( crossAxisAlignment: CrossAxisAlignment.stretch, children: <Widget>[
                      // Call button builder method from THIS class
                      _buildHomeButtonNeumorphic(context: context, label: 'ALL SONGS', onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AllSongsScreen()))),
                      _buildHomeButtonNeumorphic(context: context, label: 'SEARCH BY NUMBER', onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SearchByNumberScreen()))),
                      _buildHomeButtonNeumorphic(context: context, label: 'FAVORITE SONGS', onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const FavoriteSongsScreen()))),
                      _buildHomeButtonNeumorphic(context: context, label: 'FEEDBACK', onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const FeedbackScreen()))),
                      _buildHomeButtonNeumorphic(context: context, label: 'INDEX', onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const IndexScreen()))),
                      Padding( padding: const EdgeInsets.only(top: 32.0, left: 32.0, right: 32.0), child: Center(child: RichText(textAlign: TextAlign.center, text: TextSpan(
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 15),
                              children: const [ TextSpan(text: 'Bless the LORD, O my soul; and all that is within me, bless his holy name. \n'), TextSpan(text: '(Psalm 103:1)', style: TextStyle(fontStyle: FontStyle.italic)), ],
                            ), ), ), ),
                    ], ),
                ), // <<<--- Added Comma
                // Search Results Overlay
                if (showResultsOverlay) Positioned.fill( child: GestureDetector( onTap: () => _searchFocusNode.unfocus(), child: Container( color: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.98),
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
                 if (_searchController.text.isNotEmpty && _searchResults.isEmpty) Positioned.fill( child: GestureDetector( onTap: () => _searchFocusNode.unfocus(), child: Container( color: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.95), child: const Center(child: Text("No results found.")) ), ), )
              ], // End Stack children
            ), // End Stack
          ), // End Expanded
        ],
      ),
    );
  }


  // --- Helper Functions MOVED INSIDE _HomeScreenState ---

  // Neumorphic Button Widget (Inset Style Attempt)
  Widget _buildHomeButtonNeumorphic({ required BuildContext context, required String label, required VoidCallback onPressed }) {
    final Color baseColor = Theme.of(context).scaffoldBackgroundColor;
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final Color darkShadow = isDarkMode ? Colors.black.withOpacity(0.7) : Colors.grey.shade500.withOpacity(0.8);
    final Color lightShadow = isDarkMode ? Colors.white.withOpacity(0.10) : Colors.white.withOpacity(0.9);
    final Color slightlyDarker = Color.lerp(baseColor, Colors.black, 0.03)!;
    final Color slightlyLighter = Color.lerp(baseColor, Colors.white, 0.05)!;
    return Padding( padding: const EdgeInsets.symmetric(vertical: 9.0, horizontal: 32.0),
      child: Material( color: Colors.transparent, borderRadius: BorderRadius.circular(15.0),
        child: InkWell( borderRadius: BorderRadius.circular(15.0), onTap: onPressed, splashColor: Theme.of(context).colorScheme.primary.withOpacity(0.1), highlightColor: Theme.of(context).colorScheme.primary.withOpacity(0.05),
          child: Container( padding: const EdgeInsets.symmetric(vertical: 16.0),
            decoration: BoxDecoration( color: baseColor, borderRadius: BorderRadius.circular(15.0),
              gradient: LinearGradient( begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [slightlyDarker, baseColor, slightlyLighter], stops: const [0.0, 0.5, 1.0]),
              boxShadow: [ BoxShadow(blurRadius: 3.0, spreadRadius: 1.0, offset: const Offset(-3, -3), color: darkShadow), BoxShadow(blurRadius: 3.0, spreadRadius: 1.0, offset: const Offset(3, 3), color: lightShadow), ],
            ), child: Center( child: Text(label, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), ),
          ),
        ),
      ),
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