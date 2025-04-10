// lib/main.dart
import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/settings_screen.dart';
import 'services/song_service.dart';
import 'package:tkbk/utils/route_observer.dart' as utils;
import 'state/settings_state.dart'; // Import the settings state

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await songService.loadSongs();
  // TODO: Load saved settings from SharedPreferences here
  runApp(MyApp());
}

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
      builder: (_, mode, __) {
        // *** Add for Debugging Theme (Optional) ***
        // print("MyApp rebuilding with ThemeMode: $mode");
        // Listen to font size changes
        return ValueListenableBuilder<double>(
          valueListenable: settingsState.fontSize,
          builder: (_, fontSize, __) {
            // *** Add for Debugging Font Size (Optional) ***
            // print("MyApp rebuilding with FontSize: $fontSize");
            // final factor = fontSize / 16.0;
            // print("Calculated Factor: $factor");

            // Function to create ThemeData with adjusted font size
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

              // *** Add for Debugging Font Size (Optional) ***
              // print("Base bodyMedium size: ${baseTheme.textTheme.bodyMedium?.fontSize}");
              // print("Adjusted bodyMedium size: ${adjustedTextTheme.bodyMedium?.fontSize}");

              return baseTheme.copyWith(
                textTheme: adjustedTextTheme, // Use the safely adjusted theme
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
            );
          },
        );
      },
    );
  }
}

// --- MainScreen Widget remains the same ---
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  static const List<Widget> _widgetOptions = <Widget>[
    HomeScreen(),
    SettingsScreen(),
  ];
  void _onItemTapped(int index) {
    setState(() { _selectedIndex = index; });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack( // Use IndexedStack to preserve state
         index: _selectedIndex,
         children: _widgetOptions,
       ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem( icon: Icon(Icons.home), label: 'Home', ),
          BottomNavigationBarItem( icon: Icon(Icons.settings), label: 'Settings', ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).bottomNavigationBarTheme.selectedItemColor,
        unselectedItemColor: Theme.of(context).bottomNavigationBarTheme.unselectedItemColor,
      ),
    );
  }
}