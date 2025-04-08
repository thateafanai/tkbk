// lib/main.dart
import 'package:flutter/material.dart';
import 'screens/home_screen.dart'; // Import home screen
import 'screens/settings_screen.dart'; // Import settings screen
import 'services/song_service.dart'; // Import the song service
// Import AllSongsScreen

// The main function that runs the app
void main() async { // Add 'async' here
  // Add this line: Ensures Flutter bindings are ready before async operations
  WidgetsFlutterBinding.ensureInitialized();
  // Add this line: Calls the loadSongs function and waits for it to complete
  await songService.loadSongs();
  // Now run the app
  runApp(const MyApp());
}

// This widget is the root of your application.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // MaterialApp provides core app structure and theming
    return MaterialApp(
      title: 'APATANI BIISI KHETA', // Your app title
      theme: ThemeData( // Configuration for the light theme
        brightness: Brightness.light,
        // Using a color scheme based on blue for light theme
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue, brightness: Brightness.light),
        useMaterial3: true, // Use the newer Material Design 3 styles
        // Optional: Customize App Bar theme for light mode
        appBarTheme: const AppBarTheme(
           backgroundColor: Colors.blue, // Example color
           foregroundColor: Colors.white, // Text/icon color on app bar
         ),
         // Optional: Customize Bottom Navigation Bar theme for light mode
         bottomNavigationBarTheme: const BottomNavigationBarThemeData(
           selectedItemColor: Colors.blue,
           unselectedItemColor: Colors.grey,
         ),
      ),
      darkTheme: ThemeData( // Configuration for the dark theme
         brightness: Brightness.dark,
         // Using a color scheme based on blue for dark theme
         colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue, brightness: Brightness.dark),
         useMaterial3: true, // Use Material Design 3 for dark theme too
         // Optional: Customize App Bar theme for dark mode
         // appBarTheme: const AppBarTheme( ... ), // Can define separately if needed
         // Optional: Customize Bottom Navigation Bar theme for dark mode
         // bottomNavigationBarTheme: BottomNavigationBarThemeData( ... )
      ),
      // Starts with the theme based on the user's device settings (light/dark)
      // We can add a setting to override this later
      themeMode: ThemeMode.system,
      // The first screen shown when the app starts
      home: const MainScreen(),
      // Hide the "debug" banner in the top-right corner
      debugShowCheckedModeBanner: false,
    );
  }
}

// This widget manages the state for the Bottom Navigation Bar
// It determines whether to show the HomeScreen or SettingsScreen
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  // This variable keeps track of which tab is currently selected
  // 0 corresponds to the first tab (Home), 1 to the second (Settings)
  int _selectedIndex = 0;

  // This list holds the actual screen widgets that the BottomNavigationBar will switch between.
  static const List<Widget> _widgetOptions = <Widget>[
    HomeScreen(),       // Revert back to HomeScreen
    SettingsScreen(),   // Keep SettingsScreen as the second tab
  ];

  // This function is called when a bottom navigation bar item is tapped.
  void _onItemTapped(int index) {
    // setState() tells Flutter that the state has changed and the UI needs to rebuild.
    setState(() {
      _selectedIndex = index; // Update the selected index to the tapped item's index
    });
  }

  @override
  Widget build(BuildContext context) {
    // Scaffold provides the basic app layout structure (app bar, body, bottom bar, etc.)
    return Scaffold(
      // The main content area of the screen.
      // It displays the widget from _widgetOptions corresponding to the currently selected index.
      body: Center( // Using Center just ensures the placeholder content is centered
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      // The bottom navigation bar itself.
      bottomNavigationBar: BottomNavigationBar(
        // The list of items (tabs) to display in the bar.
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home), // The icon for the tab
            label: 'Home',         // The text label for the tab
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings), // Icon for the second tab
            label: 'Settings',        // Label for the second tab
          ),
        ],
        currentIndex: _selectedIndex, // Tells the bar which item is currently active (highlighted)
        // Optional: You can uncomment and change the color if you like
        // selectedItemColor: Theme.of(context).colorScheme.primary,
        // Function that gets called when a tab is tapped. We defined _onItemTapped above.
        onTap: _onItemTapped,
        // Defines the behavior of labels when selected/unselected. Can be useful on smaller screens.
        // type: BottomNavigationBarType.fixed, // Ensures labels are always visible
      ),
    );
  }
}