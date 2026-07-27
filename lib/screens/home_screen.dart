// lib/screens/home_screen.dart
import 'dart:async';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:tkbk/models/search_result.dart';
import 'package:tkbk/models/song.dart';
import 'package:tkbk/services/ios_web_install.dart';
import 'package:tkbk/services/song_service.dart';
import 'package:tkbk/utils/route_observer.dart' as utils;

import 'all_songs_screen.dart';
import 'favorite_songs_screen.dart';
import 'feedback_screen.dart';
import 'index_screen.dart';
import 'search_by_number_screen.dart';
import 'song_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with RouteAware {
  List<Song> _songs = [];
  List<SearchResult> _searchResults = [];
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  Timer? _debounceTimer;
  bool _showIosInstallCard = false;

  static const Color _indigoLight = Color(0xFF1A237E);
  static const Color _indigoLight2 = Color(0xFF2C3AA0);
  static const Color _indigoDark = Color(0xFF131A57);
  static const Color _indigoDark2 = Color(0xFF1E2670);
  static const Color _goldLight = Color(0xFF9C7724);
  static const Color _goldDark = Color(0xFFD8B25A);
  static const Color _bgLight = Color(0xFFF6F5F2);
  static const Color _bgDark = Color(0xFF101120);
  static const Color _cardDark = Color(0xFF1A1C2B);
  static const Color _ivoryLight = Color(0xFFFBF8F1);
  static const Color _surfaceWarm = Color(0xFFF3EDE0);

  @override
  void initState() {
    super.initState();
    _songs = songService.songs;
    _searchFocusNode.addListener(_onFocusChange);
    _showIosInstallCard = kIsWeb && shouldOfferIosInstall();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (ModalRoute.of(context) is PageRoute) {
      utils.routeObserver.subscribe(this, ModalRoute.of(context)! as PageRoute);
    }
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

  void _dismissIosInstallCard() {
    dismissIosInstallForSession();
    setState(() => _showIosInstallCard = false);
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
    if (_debounceTimer?.isActive ?? false) {
      _debounceTimer?.cancel();
    }
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      setState(() {
        if (query.isEmpty) {
          _searchResults = [];
        } else {
          final lowerQuery = query.toLowerCase();
          _searchResults = _songs.expand((song) {
            final results = <SearchResult>[];
            final sentenceCaseTitle = _toSentenceCase(song.title);
            if (sentenceCaseTitle.toLowerCase().contains(lowerQuery)) {
              results.add(
                SearchResult(
                  song: song,
                  fieldName: 'Title',
                  matchingLine: sentenceCaseTitle,
                  searchTerm: query,
                ),
              );
            }
            if (song.translation != null && song.translation!.toLowerCase().contains(lowerQuery)) {
              results.add(
                SearchResult(
                  song: song,
                  fieldName: 'Translation',
                  matchingLine: song.translation!,
                  searchTerm: query,
                ),
              );
            }
            if (song.lyrics.isNotEmpty) {
              for (final LyricPart part in song.lyrics) {
                final matchingLines = _findMatchingLines(part.text, lowerQuery);
                results.addAll(
                  matchingLines.map(
                    (line) => SearchResult(
                      song: song,
                      fieldName: _toSentenceCase(part.key),
                      matchingLine: line,
                      searchTerm: query,
                    ),
                  ),
                );
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
    final bool showResultsOverlay = _searchController.text.isNotEmpty && _searchResults.isNotEmpty;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color homeBg = isDark ? _bgDark : _bgLight;
    final Color cardColor = isDark ? _cardDark : Colors.white;
    final Color warmCardColor = isDark ? _cardDark : _ivoryLight;
    final Color gold = isDark ? _goldDark : _goldLight;
    final Color muted = isDark ? const Color(0xFF9298AE) : const Color(0xFF6E7488);
    final Color lineColor = isDark ? Colors.white.withValues(alpha: 0.08) : _indigoLight.withValues(alpha: 0.10);
    final Color textColor = Theme.of(context).textTheme.bodyLarge?.color ?? (isDark ? Colors.white : Colors.black);

    return Scaffold(
      backgroundColor: homeBg,
      body: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: isDark
                      ? [_bgDark, const Color(0xFF14182B), _bgDark]
                      : [_surfaceWarm, _bgLight, _ivoryLight],
                ),
              ),
            ),
          ),
          Column(
            children: <Widget>[
              Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 30.0),
                    child: _buildHeroHeader(context, isDark, gold),
                  ),
                  Positioned(
                    left: 18.0,
                    right: 18.0,
                    bottom: 0,
                    child: _buildSearchCard(cardColor, muted, gold, isDark),
                  ),
                ],
              ),
              Expanded(
                child: Stack(
                  children: [
                    SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(18.0, 18.0, 18.0, 28.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          if (_showIosInstallCard) ...[
                            _buildIosInstallCard(),
                            const SizedBox(height: 16),
                          ],
                          _buildFeatureGrid(context, cardColor, gold, muted, textColor, isDark),
                          const SizedBox(height: 14),
                          _buildFeedbackRow(context, muted, gold, lineColor, isDark),
                          const SizedBox(height: 22),
                          _buildVerseCard(warmCardColor, gold, textColor, muted, isDark),
                        ],
                      ),
                    ),
                    if (showResultsOverlay)
                      Positioned.fill(
                        child: GestureDetector(
                          onTap: () => _searchFocusNode.unfocus(),
                          child: Container(
                            color: homeBg.withValues(alpha: 0.98),
                            child: ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                              itemCount: _searchResults.length,
                              itemBuilder: (context, index) {
                                final SearchResult result = _searchResults[index];
                                final originalTitle = result.song.title;
                                return Card(
                                  margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 4.0),
                                  color: Theme.of(context).cardColor,
                                  elevation: 1.0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  child: ListTile(
                                    title: RichText(
                                      text: _highlightSearchTerm(result.matchingLine, result.searchTerm),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    subtitle: Text(
                                      '${result.song.number}. $originalTitle (Match in: ${result.fieldName})',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
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
                            color: homeBg.withValues(alpha: 0.95),
                            child: const Center(child: Text('No results found.')),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeroHeader(BuildContext context, bool isDark, Color gold) {
    final gradientColors = isDark ? [_indigoDark, _indigoDark2] : [_indigoLight, _indigoLight2];

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(20.0, MediaQuery.of(context).padding.top + 18.0, 20.0, 42.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30.0),
          bottomRight: Radius.circular(30.0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 16.0,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(17.0),
                color: Colors.white.withValues(alpha: 0.14),
                border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
                boxShadow: [
                  BoxShadow(
                    color: gold.withValues(alpha: 0.20),
                    blurRadius: 18,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(17.0),
                child: Image.asset(
                  'assets/icon/app_icon.png',
                  width: 54,
                  height: 54,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 12),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: const Text(
                'Tanii Kristan Biisi Kheta',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 19,
                  letterSpacing: 0.2,
                ),
              ),
            ),
            const SizedBox(height: 5),
            Text(
              '\'Sing for Joy to the Lord\'',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: gold.withValues(alpha: 0.95),
                fontSize: 12,
                fontStyle: FontStyle.italic,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIosInstallCard() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final gold = isDark ? _goldDark : _goldLight;
    final gradientColors = isDark ? [_indigoDark, _indigoDark2] : [_indigoLight, _indigoLight2];

    return Container(
      padding: const EdgeInsets.fromLTRB(14.0, 12.0, 8.0, 12.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: gradientColors),
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 1.0),
            child: Icon(Icons.ios_share, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(fontSize: 12.5, height: 1.45, color: Colors.white),
                children: [
                  const TextSpan(text: 'Install this app on your iPhone: tap '),
                  TextSpan(text: 'Share', style: TextStyle(fontWeight: FontWeight.bold, color: gold)),
                  const TextSpan(text: ', then '),
                  TextSpan(text: 'Add to Home Screen', style: TextStyle(fontWeight: FontWeight.bold, color: gold)),
                  const TextSpan(text: '.'),
                ],
              ),
            ),
          ),
          InkWell(
            onTap: _dismissIosInstallCard,
            borderRadius: BorderRadius.circular(20.0),
            child: const Padding(
              padding: EdgeInsets.all(6.0),
              child: Icon(Icons.close, color: Colors.white70, size: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchCard(Color cardColor, Color muted, Color gold, bool isDark) {
    return Material(
      color: cardColor,
      borderRadius: BorderRadius.circular(20.0),
      elevation: 10,
      shadowColor: Colors.black.withValues(alpha: isDark ? 0.22 : 0.12),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.0),
          border: Border.all(
            color: _searchFocusNode.hasFocus ? gold.withValues(alpha: 0.38) : Colors.white.withValues(alpha: 0.0),
          ),
        ),
        child: TextField(
          controller: _searchController,
          focusNode: _searchFocusNode,
          decoration: InputDecoration(
            prefixIcon: Padding(
              padding: const EdgeInsets.only(left: 4),
              child: Icon(Icons.search_rounded, color: muted),
            ),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: Icon(Icons.clear_rounded, color: muted),
                    onPressed: () {
                      _searchController.clear();
                      _searchSongs('');
                      _searchFocusNode.unfocus();
                    },
                  )
                : Padding(
                    padding: const EdgeInsets.only(right: 14, top: 13, bottom: 13),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: gold.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        child: Text(
                          'Search',
                          style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: gold),
                        ),
                      ),
                    ),
                  ),
            hintText: 'Search songs or lyrics...',
            hintStyle: TextStyle(color: muted),
            filled: true,
            fillColor: Colors.transparent,
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 18.0),
          ),
          onChanged: _searchSongs,
        ),
      ),
    );
  }

  Widget _buildFeatureGrid(BuildContext context, Color cardColor, Color gold, Color muted, Color textColor, bool isDark) {
    return Column(
      children: [
        _buildFeaturedTile(
          context: context,
          gold: gold,
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AllSongsScreen())),
          isDark: isDark,
        ),
        const SizedBox(height: 14),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _buildFeatureTile(
                  context: context,
                  cardColor: cardColor,
                  gold: gold,
                  muted: muted,
                  textColor: textColor,
                  isDark: isDark,
                  icon: Icons.favorite_border,
                  label: 'Favorites',
                  subtitle: 'Your saved songs',
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const FavoriteSongsScreen())),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildFeatureTile(
                  context: context,
                  cardColor: cardColor,
                  gold: gold,
                  muted: muted,
                  textColor: textColor,
                  isDark: isDark,
                  icon: Icons.numbers_rounded,
                  label: 'By Number',
                  subtitle: 'Jump straight to a hymn',
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SearchByNumberScreen())),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _buildFeatureTile(
          context: context,
          cardColor: cardColor,
          gold: gold,
          muted: muted,
          textColor: textColor,
          isDark: isDark,
          icon: Icons.sort_by_alpha,
          label: 'Index',
          subtitle: 'A–Z by title',
          compact: false,
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const IndexScreen())),
        ),
      ],
    );
  }

  Widget _buildFeaturedTile({
    required BuildContext context,
    required Color gold,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    final gradient = isDark
        ? [_indigoDark2, _indigoDark, const Color(0xFF202B7F)]
        : [_indigoLight2, _indigoLight, const Color(0xFF3144B8)];

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(24.0),
      child: InkWell(
        borderRadius: BorderRadius.circular(24.0),
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: gradient,
            ),
            borderRadius: BorderRadius.circular(24.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.18 : 0.12),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(18.0),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          'PRIMARY',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.9,
                            color: gold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        'All Songs',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 19,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Browse the full hymnal and open any song in one place.',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.78),
                          fontSize: 12.2,
                          height: 1.45,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 14),
                Column(
                  children: [
                    Container(
                      width: 54,
                      height: 54,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Icon(Icons.library_music_outlined, color: Colors.white, size: 28),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: gold.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(Icons.arrow_forward_rounded, color: gold, size: 20),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
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
    bool compact = true,
  }) {
    return Material(
      color: cardColor,
      borderRadius: BorderRadius.circular(18.0),
      elevation: isDark ? 0 : 1.5,
      shadowColor: Colors.black.withValues(alpha: 0.10),
      child: InkWell(
        borderRadius: BorderRadius.circular(18.0),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18.0),
            border: Border.all(
              color: isDark ? Colors.white.withValues(alpha: 0.06) : gold.withValues(alpha: 0.08),
            ),
          ),
          child: Padding(
            padding: EdgeInsets.all(compact ? 14.0 : 16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: compact ? 42 : 46,
                  height: compact ? 42 : 46,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [gold.withValues(alpha: 0.18), gold.withValues(alpha: 0.08)],
                    ),
                    borderRadius: BorderRadius.circular(13.0),
                  ),
                  child: Icon(icon, color: gold, size: compact ? 20 : 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: compact ? 14.5 : 15.0,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(fontSize: 11.8, height: 1.35, color: muted),
                        maxLines: compact ? 2 : 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                if (!compact) ...[
                  const SizedBox(width: 10),
                  Icon(Icons.chevron_right_rounded, color: gold, size: 20),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeedbackRow(BuildContext context, Color muted, Color gold, Color lineColor, bool isDark) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(18.0),
      child: InkWell(
        borderRadius: BorderRadius.circular(18.0),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const FeedbackScreen())),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18.0),
            border: Border.all(color: lineColor),
            color: isDark ? Colors.white.withValues(alpha: 0.02) : Colors.white.withValues(alpha: 0.55),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline_rounded, size: 18, color: muted),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Need help or have a suggestion?',
                  style: TextStyle(fontSize: 12.8, fontWeight: FontWeight.w600, color: muted),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'FEEDBACK',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5, color: gold),
              ),
              Icon(Icons.chevron_right_rounded, size: 18, color: gold),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVerseCard(Color cardColor, Color gold, Color textColor, Color muted, bool isDark) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 20.0),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24.0),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.06) : gold.withValues(alpha: 0.10),
        ),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 18.0,
                  offset: const Offset(0, 8),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildOrnament(gold),
          const SizedBox(height: 14),
          Text(
            '"Bless the LORD, O my soul; and all that is within me, bless his holy name."',
            textAlign: TextAlign.center,
            style: TextStyle(fontFamily: 'Georgia', fontSize: 16.0, height: 1.68, color: textColor),
          ),
          const SizedBox(height: 10),
          Text(
            '— Psalm 103:1',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 11.5, fontStyle: FontStyle.italic, color: muted, letterSpacing: 0.3),
          ),
        ],
      ),
    );
  }

  Widget _buildOrnament(Color gold) {
    Widget rule() => Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  gold.withValues(alpha: 0),
                  gold.withValues(alpha: 0.55),
                  gold.withValues(alpha: 0),
                ],
              ),
            ),
          ),
        );
    return SizedBox(
      width: 130,
      child: Row(
        children: [
          rule(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Icon(Icons.star, size: 8, color: gold),
          ),
          rule(),
        ],
      ),
    );
  }

  List<String> _findMatchingLines(String text, String query) {
    if (query.isEmpty) return [];
    final lines = text.split('\n');
    return lines.where((line) => line.toLowerCase().contains(query.toLowerCase())).toList();
  }

  String _toSentenceCase(String? text) {
    if (text == null || text.isEmpty) return '';
    if (text.contains(RegExp(r'[0-9]'))) {
      return text[0].toUpperCase() + text.substring(1);
    }
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  TextSpan _highlightSearchTerm(String text, String searchTerm) {
    final TextStyle defaultStyle = TextStyle(color: Colors.grey[600]);
    final TextStyle highlightStyle = const TextStyle(
      fontWeight: FontWeight.bold,
      backgroundColor: Colors.yellow,
      color: Colors.black,
    );
    if (searchTerm.isEmpty || text.isEmpty) {
      return TextSpan(text: text, style: defaultStyle);
    }
    final lowerCaseText = text.toLowerCase();
    final lowerCaseSearchTerm = searchTerm.toLowerCase();
    final List<TextSpan> spans = [];
    int start = 0;
    while (start < text.length) {
      final indexOfHighlight = lowerCaseText.indexOf(lowerCaseSearchTerm, start);
      if (indexOfHighlight < 0) {
        spans.add(TextSpan(text: text.substring(start), style: defaultStyle));
        break;
      }
      if (indexOfHighlight > start) {
        spans.add(TextSpan(text: text.substring(start, indexOfHighlight), style: defaultStyle));
      }
      final endIndex = indexOfHighlight + searchTerm.length;
      spans.add(TextSpan(text: text.substring(indexOfHighlight, endIndex), style: highlightStyle));
      start = endIndex;
    }
    return TextSpan(children: spans);
  }
}
