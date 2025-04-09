// lib/main.dart
import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/settings_screen.dart';
import 'services/song_service.dart';
// Assuming route_observer.dart exists in lib/utils/
// If not, you need to create it and define 'routeObserver' there.
import 'package:tkbk/utils/route_observer.dart' as utils;

// Define the observer globally (or ensure it's defined in the imported file)
// final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>(); // Example definition

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await songService.loadSongs(); // Load songs via service
  runApp(const MyApp()); // Can use const MyApp() now
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key); // Use const constructor

  @override
  Widget build(BuildContext context) {
    return MaterialApp( // Can use const if theme/darkTheme were const
      title: 'APATANI BIISI KHETA',
      theme: ThemeData(
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue, brightness: Brightness.light),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
           backgroundColor: Colors.blue,
           foregroundColor: Colors.white,
         ),
         bottomNavigationBarTheme: const BottomNavigationBarThemeData(
           selectedItemColor: Colors.blue,
           unselectedItemColor: Colors.grey,
         ),
      ),
      darkTheme: ThemeData(
         brightness: Brightness.dark,
         colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue, brightness: Brightness.dark),
         useMaterial3: true,
      ),
      themeMode: ThemeMode.system,
      home: const MainScreen(),
      debugShowCheckedModeBanner: false,
      // Pass the imported (or globally defined) routeObserver
      navigatorObservers: [utils.routeObserver],
    );
  }
}

// MainScreen manages the Bottom Navigation Bar state
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  // Screens controlled by the bottom bar
  static const List<Widget> _widgetOptions = <Widget>[
    HomeScreen(),       // Index 0
    SettingsScreen(),   // Index 1
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Body displays the selected screen from the list
      body: IndexedStack( // Use IndexedStack to preserve state of screens
         index: _selectedIndex,
         children: _widgetOptions,
       ),
      // Bottom navigation bar setup
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        // Recommended for few items: ensures labels are always visible
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}

// Ensure route_observer.dart exists in lib/utils/ and defines:
// final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();