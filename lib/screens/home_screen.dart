// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:tkbk/models/song.dart';
import 'package:tkbk/models/search_result.dart';
import 'package:tkbk/services/song_service.dart';
import 'package:tkbk/utils/route_observer.dart' as utils;
import 'package:tkbk/widgets/custom_header.dart'; // Import the custom header

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
    utils.routeObserver.subscribe(this, ModalRoute.of(context)! as PageRoute);
  }

  @override
  void didPopNext() {
    if (mounted) {
      _searchFocusNode.unfocus();
    }
  }

  @override
  void didPushNext() {
    if (mounted) {
      _searchFocusNode.unfocus();
    }
  }

  void _onFocusChange() {
    if (mounted) {
      setState(() {});
    }
  }

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
        if (query.isEmpty) {
          _searchResults = [];
        } else {
          _searchResults = _songs.expand((song) {
            List<SearchResult> results = [];
            final sentenceCaseTitle = toSentenceCase(song.title);
            if (sentenceCaseTitle.toLowerCase().contains(query.toLowerCase())) {
              results.add(SearchResult(
                song: song,
                fieldName: 'title',
                matchingLine: sentenceCaseTitle,
                searchTerm: query,
              ));
            }
            if (song.lyrics.isNotEmpty) {
              for (LyricPart part in song.lyrics) {
                final matchingLines = _findMatchingLines(part.text, query);
                results.addAll(matchingLines.map((line) => SearchResult(
                      song: song,
                      fieldName: part.key,
                      matchingLine: line,
                      searchTerm: query,
                    )));
              }
            }
            return results;
          }).toList();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    bool showResultsOverlay = _searchController.text.isNotEmpty && _searchResults.isNotEmpty;
    final Color baseColor = Theme.of(context).scaffoldBackgroundColor;

    return Scaffold(
      backgroundColor: baseColor,
      body: Column(
        children: <Widget>[
          const CustomHeader(title: 'APATANI BIISI KHETA'), // Use the custom header
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(30.0),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 5.0,
                    offset: const Offset(-3, -3),
                    color: Colors.white.withOpacity(0.9),
                  ),
                  BoxShadow(
                    blurRadius: 5.0,
                    offset: const Offset(3, 3),
                    color: Colors.black.withOpacity(0.1),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Icon(Icons.search, color: Colors.grey[600]),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      focusNode: _searchFocusNode,
                      decoration: InputDecoration(
                        hintText: 'Search songs or lyrics...',
                        border: InputBorder.none,
                        hintStyle: TextStyle(color: Colors.grey[600]),
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 14.0),
                      ),
                      onChanged: _searchSongs,
                    ),
                  ),
                  if (_searchController.text.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.clear, color: Colors.grey),
                      onPressed: () {
                        _searchController.clear();
                        _searchSongs('');
                        _searchFocusNode.unfocus();
                      },
                    ),
                  if (_searchController.text.isEmpty) const SizedBox(width: 48),
                ],
              ),
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      _buildHomeButtonNeumorphic(
                        context: context,
                        label: 'ALL SONGS',
                        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AllSongsScreen())),
                      ),
                      _buildHomeButtonNeumorphic(
                        context: context,
                        label: 'SEARCH BY NUMBER',
                        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SearchByNumberScreen())),
                      ),
                      _buildHomeButtonNeumorphic(
                        context: context,
                        label: 'FAVORITE SONGS',
                        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const FavoriteSongsScreen())),
                      ),
                      _buildHomeButtonNeumorphic(
                        context: context,
                        label: 'FEEDBACK',
                        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const FeedbackScreen())),
                      ),
                      _buildHomeButtonNeumorphic(
                        context: context,
                        label: 'INDEX',
                        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const IndexScreen())),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 32.0, left: 32.0, right: 32.0),
                        child: Center(
                          child: RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 15),
                              children: const [
                                TextSpan(text: 'Bless the LORD, O my soul; and all that is within me, bless his holy name. \n'),
                                TextSpan(text: '(Psalm 103:1)', style: TextStyle(fontStyle: FontStyle.italic)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (showResultsOverlay)
                  Positioned.fill(
                    child: GestureDetector(
                      onTap: () => _searchFocusNode.unfocus(),
                      child: Container(
                        color: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.95),
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          itemCount: _searchResults.length,
                          itemBuilder: (context, index) {
                            final SearchResult result = _searchResults[index];
                            final sentenceCaseTitle = toSentenceCase(result.song.title);

                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 4.0),
                              color: Theme.of(context).scaffoldBackgroundColor,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Theme.of(context).scaffoldBackgroundColor,
                                  borderRadius: BorderRadius.circular(10.0),
                                  boxShadow: [
                                    BoxShadow(
                                      blurRadius: 3.0,
                                      offset: const Offset(-2, -2),
                                      color: Colors.white.withOpacity(0.8),
                                    ),
                                    BoxShadow(
                                      blurRadius: 3.0,
                                      offset: const Offset(2, 2),
                                      color: Colors.black.withOpacity(0.1),
                                    ),
                                  ],
                                ),
                                child: ListTile(
                                  title: RichText(
                                    text: _highlightSearchTerm(result.matchingLine, result.searchTerm),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  subtitle: Text("${result.song.number}. $sentenceCaseTitle"),
                                  onTap: () {
                                    _searchFocusNode.unfocus();
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => SongDetailScreen(song: result.song),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                if (_searchController.text.isNotEmpty && _searchResults.isEmpty)
                  Positioned.fill(
                    child: GestureDetector(
                      onTap: () => _searchFocusNode.unfocus(),
                      child: Container(
                        color: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.95),
                        child: const Center(child: Text("No results found.")),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // New Neumorphic Button Widget
  Widget _buildHomeButtonNeumorphic({
    required BuildContext context,
    required String label,
    required VoidCallback onPressed,
  }) {
    final Color baseColor = Theme.of(context).scaffoldBackgroundColor;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 32.0),
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          decoration: BoxDecoration(
            color: baseColor,
            borderRadius: BorderRadius.circular(15.0),
            boxShadow: [
              BoxShadow(
                blurRadius: 5.0,
                offset: const Offset(-3, -3),
                color: Colors.white.withOpacity(0.9),
              ),
              BoxShadow(
                blurRadius: 5.0,
                offset: const Offset(3, 3),
                color: Colors.black.withOpacity(0.1),
              ),
            ],
          ),
          child: Center(
            child: Text(
              label,
              style: const TextStyle(fontSize: 18),
            ),
          ),
        ),
      ),
    );
  }

  // --- Helper Functions ---
  List<String> _findMatchingLines(String text, String query) {
    if (query.isEmpty) return [];
    final lines = text.split('\n');
    return lines
        .where((line) => line.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  String toSentenceCase(String? text) {
    if (text == null || text.isEmpty) return '';
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  TextSpan _highlightSearchTerm(String text, String searchTerm) {
    if (searchTerm.isEmpty || text.isEmpty) {
      return TextSpan(text: text);
    }

    final TextStyle defaultStyle = TextStyle(color: Colors.grey[600]);
    final TextStyle highlightStyle = const TextStyle(
        fontWeight: FontWeight.bold, backgroundColor: Colors.yellow, color: Colors.black);

    final lowerCaseText = text.toLowerCase();
    final lowerCaseSearchTerm = searchTerm.toLowerCase();

    final List<TextSpan> spans = [];
    int start = 0;
    int indexOfHighlight;

    while (start < text.length) {
      indexOfHighlight = lowerCaseText.indexOf(lowerCaseSearchTerm, start);

      if (indexOfHighlight < 0) {
        spans.add(TextSpan(text: text.substring(start), style: defaultStyle));
        break;
      }

      if (indexOfHighlight > start) {
        spans.add(TextSpan(text: text.substring(start, indexOfHighlight), style: defaultStyle));
      }

      final endIndex = indexOfHighlight + searchTerm.length;
      spans.add(TextSpan(
        text: text.substring(indexOfHighlight, endIndex),
        style: highlightStyle,
      ));

      start = endIndex;
    }

    return TextSpan(children: spans);
  }
}