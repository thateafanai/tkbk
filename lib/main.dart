// lib/main.dart
import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/settings_screen.dart';
import 'services/song_service.dart';
import 'package:tkbk/utils/route_observer.dart' as utils;
import 'state/settings_state.dart'; // Import the settings state

void main() async {
  // REQUIRED: Ensures bindings are ready before async calls like SharedPreferences
  WidgetsFlutterBinding.ensureInitialized();

  // Load songs AND settings before running the app
  await Future.wait([
      songService.loadSongs(),
      settingsState.loadSettings(), // Call the load method here
  ]);

  // Now run the app
  runApp(MyApp());
}

// ... Keep the rest of your main.dart (MyApp, MainScreen, helpers) AS IS ...
// (The code for MyApp using ValueListenableBuilders, etc., looks correct)

// Helper function to safely apply font size factor
TextStyle? _applyFontSizeFactor(TextStyle? style, double factor) {
  if (style?.fontSize == null) return style; // Don't modify if base size is null
  // Use a small tolerance for floating point comparison
  if ((factor - 1.0).abs() < 0.01) return style; // Avoid unnecessary changes
  return style!.copyWith(fontSize: style.fontSize! * factor);
}

// Helper function to create an adjusted TextTheme
TextTheme createAdjustedTextTheme(TextTheme base, double factor) {
  return TextTheme(
    displayLarge: _applyFontSizeFactor(base.displayLarge, factor),
    displayMedium: _applyFontSizeFactor(base.displayMedium, factor),
    displaySmall: _applyFontSizeFactor(base.displaySmall, factor),
    headlineLarge: _applyFontSizeFactor(base.headlineLarge, factor),
    headlineMedium: _applyFontSizeFactor(base.headlineMedium, factor),
    headlineSmall: _applyFontSizeFactor(base.headlineSmall, factor),
    titleLarge: _applyFontSizeFactor(base.titleLarge, factor),
    titleMedium: _applyFontSizeFactor(base.titleMedium, factor),
    titleSmall: _applyFontSizeFactor(base.titleSmall, factor),
    bodyLarge: _applyFontSizeFactor(base.bodyLarge, factor),
    bodyMedium: _applyFontSizeFactor(base.bodyMedium, factor),
    bodySmall: _applyFontSizeFactor(base.bodySmall, factor),
    labelLarge: _applyFontSizeFactor(base.labelLarge, factor),
    labelMedium: _applyFontSizeFactor(base.labelMedium, factor),
    labelSmall: _applyFontSizeFactor(base.labelSmall, factor),
  );
}


class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Listen to theme mode changes
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: settingsState.themeMode,
      builder: (context, mode, child) {
        // Listen to font size changes
        return ValueListenableBuilder<double>(
          valueListenable: settingsState.fontSize,
          builder: (context, fontSize, child) {
            // Listen to font selection changes
            return ValueListenableBuilder<String>(
              valueListenable: settingsState.selectedFont,
              builder: (context, selectedFont, child) {
                String? fontFamily;
                if (selectedFont != 'Default') {
                  fontFamily = selectedFont;
                }

                // Function to create ThemeData with adjusted font size and family
                ThemeData generateThemeData(Brightness brightness) {
                  final baseTheme = ThemeData(
                    brightness: brightness,
                    colorScheme: ColorScheme.fromSeed(
                      seedColor: Colors.blue,
                      brightness: brightness,
                    ),
                    useMaterial3: true,
                  );

                  // Create adjusted text theme safely
                  final adjustedTextTheme = createAdjustedTextTheme(
                      baseTheme.textTheme, fontSize / 16.0); // Base size 16.0

                  return baseTheme.copyWith(
                    textTheme: adjustedTextTheme.apply(fontFamily: fontFamily), // Apply font family here
                    appBarTheme: baseTheme.appBarTheme.copyWith(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                    bottomNavigationBarTheme: baseTheme.bottomNavigationBarTheme.copyWith(
                      selectedItemColor: Colors.blue,
                      unselectedItemColor: Colors.grey,
                    ),
                  );
                }

                return MaterialApp(
                  navigatorObservers: [utils.routeObserver],
                  title: 'APATANI BIISI KHETA',
                  theme: generateThemeData(Brightness.light), // Generate light theme
                  darkTheme: generateThemeData(Brightness.dark), // Generate dark theme
                  themeMode: mode, // Use the theme mode from the notifier
                  home: const MainScreen(),
                  debugShowCheckedModeBanner: false,
                  routes: {
                    '/home': (context) => const MainScreen(initialIndex: 0), // Set index to 0 for Home
                    '/settings': (context) => const MainScreen(initialIndex: 1), // Set index to 1 for Settings
                  },
                );
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