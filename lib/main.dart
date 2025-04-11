// lib/main.dart
import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/settings_screen.dart';
import 'services/song_service.dart';
import 'package:tkbk/utils/route_observer.dart' as utils;
import 'state/settings_state.dart'; // Import the settings state
import 'state/favorites_state.dart'; // Import FavoritesState

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Future.wait([
      songService.loadSongs(),
      settingsState.loadSettings(),
      favoritesState.loadFavorites(),
  ]);
  runApp(const MyApp());
}

// --- REMOVED Font Size Helper Functions ---
// TextStyle? _applyFontSizeFactor(...) { ... }
// TextTheme createAdjustedTextTheme(...) { ... }
// --- END REMOVED ---

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Listen to theme mode changes
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: settingsState.themeMode,
      builder: (context, mode, child) {
        // Listen ONLY to font FAMILY changes here
        return ValueListenableBuilder<String>(
          valueListenable: settingsState.selectedFont,
          builder: (context, selectedFont, child) {
            String? fontFamily;
            if (selectedFont != 'Default') {
              fontFamily = selectedFont;
            }

            // Function to create ThemeData
            ThemeData generateThemeData(Brightness brightness) {
              final baseTheme = ThemeData(
                brightness: brightness,
                colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue, brightness: brightness),
                useMaterial3: true,
              );
              // Apply ONLY font family globally
              return baseTheme.copyWith(
                textTheme: baseTheme.textTheme.apply(fontFamily: fontFamily),
                appBarTheme: baseTheme.appBarTheme.copyWith(
                  backgroundColor: Colors.indigo[900], // Consistent Header Color
                  foregroundColor: Colors.white,
                  elevation: 4.0, // Add elevation to custom header via AppBar theme
                ),
                // --- MODIFIED/ADDED Bottom Navigation Bar Theme ---
                bottomNavigationBarTheme: baseTheme.bottomNavigationBarTheme.copyWith(
                  selectedItemColor: Colors.blue, // Or theme primary
                  unselectedItemColor: Colors.grey,
                  // *** HIDE the indicator ***
                  // Make background transparent if using neumorphic container wrapper
                  backgroundColor: Colors.transparent,
                  elevation: 0, // Remove default elevation if using container
                ),
                // --- END MODIFICATION ---
              );
            }

            return MaterialApp(
              navigatorObservers: [utils.routeObserver],
              title: 'APATANI BIISI KHETA',
              theme: generateThemeData(Brightness.light), // Generate light theme
              darkTheme: generateThemeData(Brightness.dark), // Generate dark theme
              themeMode: mode,
              home: const MainScreen(),
              debugShowCheckedModeBanner: false,
              routes: {
                 '/home': (context) => const MainScreen(initialIndex: 0),
                 '/settings': (context) => const MainScreen(initialIndex: 1),
               },
            );
          },
        );
      },
    );
  }
}

// --- MainScreen Widget remains the same ---
class MainScreen extends StatefulWidget {
  final int initialIndex;
  const MainScreen({super.key, this.initialIndex = 0}); // Optional initialIndex, default to 0
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex; // Set initial index from widget property
  }

  static const List<Widget> _widgetOptions = <Widget>[
    HomeScreen(),
    SettingsScreen(),
  ];
  void _onItemTapped(int index) {
    setState(() { _selectedIndex = index; });
  }
  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final baseColor = Theme.of(context).scaffoldBackgroundColor; // Use the scaffold background color

    // Define shadow and highlight colors based on the theme
    final Color shadowColor = isDarkMode ? Colors.black54 : Colors.grey.shade400;
    final Color highlightColor = isDarkMode ? Colors.grey.shade800 : Colors.white;
    final Color secondShadowColor = isDarkMode ? Colors.black45 : Colors.grey.shade300; // A slightly lighter shadow

    return Scaffold(
      body: IndexedStack( // Use IndexedStack to preserve state
          index: _selectedIndex,
          children: _widgetOptions,
        ),
      bottomNavigationBar: Container( // Wrap BottomNavigationBar with Container
        decoration: BoxDecoration(
          color: baseColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(15)), // Optional rounded corners
          boxShadow: [
            // Subtle top highlight
            BoxShadow(
              color: highlightColor,
              offset: const Offset(-1, -1),
              blurRadius: 3,
              spreadRadius: 0,
            ),
            // Primary bottom shadow
            BoxShadow(
              color: shadowColor,
              offset: const Offset(2, 2),
              blurRadius: 6,
              spreadRadius: 1,
            ),
            // Secondary, softer bottom shadow for more depth
            BoxShadow(
              color: secondShadowColor,
              offset: const Offset(3, 3),
              blurRadius: 8,
              spreadRadius: 1,
            ),
          ],
        ),
        child: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem( icon: Icon(Icons.home), label: 'Home', ),
            BottomNavigationBarItem( icon: Icon(Icons.settings), label: 'Settings', ),
          ],
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent, // Make the BottomNavigationBar background transparent
          elevation: 0, // Remove default elevation
          selectedItemColor: Theme.of(context).bottomNavigationBarTheme.selectedItemColor,
          unselectedItemColor: Theme.of(context).bottomNavigationBarTheme.unselectedItemColor,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold), // Optional style
        ),
      ),
    );
  }
}