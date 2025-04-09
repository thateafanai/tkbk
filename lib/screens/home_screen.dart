// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:tkbk/models/song.dart'; // Use the central Song model
// **** ADD THIS IMPORT ****
import 'package:tkbk/models/search_result.dart'; // Use the central SearchResult model
// **** END OF ADDED IMPORT ****
import 'package:tkbk/services/song_service.dart'; // Use the SongService
// Assuming route_observer is defined and exported from here or globally
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
  List<Song> _songs = []; // Holds songs from the service
  List<SearchResult> _searchResults = []; // Now uses the imported SearchResult
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // Get songs from the already loaded service
    _songs = songService.songs;
    _searchFocusNode.addListener(_onFocusChange);
  }

   @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Subscribe to route changes for focus management
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
          // Use the imported SearchResult constructor
          _searchResults = _songs.expand((song) {
            List<SearchResult> results = [];

            // Search in title
            final sentenceCaseTitle = toSentenceCase(song.title);
            if (sentenceCaseTitle.toLowerCase().contains(query.toLowerCase())) {
              // Use the imported SearchResult constructor
              results.add(SearchResult(
                song: song,
                fieldName: 'title',
                matchingLine: sentenceCaseTitle,
                searchTerm: query,
              ));
            }

            // Search in lyrics (List<LyricPart>)
            if (song.lyrics.isNotEmpty) {
              for (LyricPart part in song.lyrics) {
                final matchingLines = _findMatchingLines(part.text, query);
                // Use the imported SearchResult constructor
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

  Widget _buildHomeButton({
    required BuildContext context,
    required String label,
    required VoidCallback onPressed,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 32.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          textStyle: const TextStyle(fontSize: 18),
        ),
        onPressed: onPressed,
        child: Text(label),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool showResultsOverlay = _searchController.text.isNotEmpty && _searchResults.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'APATANI BIISI KHETA',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
            child: Container(
               decoration: BoxDecoration(
                 color: Theme.of(context).colorScheme.surface.withOpacity(0.8),
                 borderRadius: BorderRadius.circular(30.0),
                 border: Border.all(color: Theme.of(context).dividerColor),
               ),
              child: Row(
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12.0),
                    child: Icon(Icons.search, color: Colors.grey),
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
                 if (_searchController.text.isEmpty)
                    const SizedBox(width: 48),
                ],
              ),
            ),
          ),

          Expanded(
            child: Stack(
              children: [
                 SingleChildScrollView(
                   child: Padding(
                     padding: const EdgeInsets.only(top: 16.0, bottom: 16.0),
                     child: Column(
                       crossAxisAlignment: CrossAxisAlignment.stretch,
                       children: <Widget>[
                        _buildHomeButton(
                          context: context, label: 'ALL SONGS',
                          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AllSongsScreen())),
                        ),
                        _buildHomeButton(
                          context: context, label: 'SEARCH BY NUMBER',
                          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SearchByNumberScreen())),
                        ),
                         _buildHomeButton(
                          context: context, label: 'FAVORITE SONGS',
                          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const FavoriteSongsScreen())),
                        ),
                        _buildHomeButton(
                          context: context, label: 'FEEDBACK',
                          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const FeedbackScreen())),
                        ),
                        _buildHomeButton(
                          context: context, label: 'INDEX',
                          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const IndexScreen())),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 24.0, left: 32.0, right: 32.0),
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
                             // Use the imported SearchResult type
                             final SearchResult result = _searchResults[index];
                             final sentenceCaseTitle = toSentenceCase(result.song.title);

                             return Card(
                               margin: const EdgeInsets.symmetric(vertical: 4.0),
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
                                       // Pass the correct Song type
                                       builder: (context) => SongDetailScreen(song: result.song),
                                     ),
                                   );
                                 },
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
                          child: const Center(child: Text("No results found."))),
                     ),
                   ),

              ],
            ),
          ),
        ],
      ),
    );
  }
}


// --- Helper Functions (Moved outside class) ---

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
     // Use default text style from theme
     return TextSpan(text: text /*, style: DefaultTextStyle.of(context).style */);
   }

   // Use default text style from theme as base
   final TextStyle defaultStyle = TextStyle(color: Colors.grey[600]); // Example base style
   final TextStyle highlightStyle = const TextStyle(
           fontWeight: FontWeight.bold,
           backgroundColor: Colors.yellow,
           color: Colors.black
           );

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