// lib/main.dart
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:ui';

// --- ADDED: Firebase Imports ---
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_options.dart'; // Ensure this file exists and is configured

// Your App Imports
import 'screens/home_screen.dart';
import 'screens/scripture_inbox_screen.dart';
import 'screens/settings_screen.dart';
import 'services/message_store.dart';
import 'services/notification_service.dart';
import 'services/song_service.dart';
import 'package:tkbk/utils/route_observer.dart' as utils; // Ensure path is correct
import 'state/settings_state.dart';
import 'state/favorites_state.dart';

// --- ADDED: Firebase Analytics Instances ---
final FirebaseAnalytics analytics = FirebaseAnalytics.instance;
final FirebaseAnalyticsObserver analyticsObserver =
    FirebaseAnalyticsObserver(analytics: analytics);
// --- End Analytics Instances ---

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // --- ADDED: Firebase Initialization with Error Handling ---
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    if (Firebase.apps.isNotEmpty) {
      PlatformDispatcher.instance.onError = (error, stack) {
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
        return true;
      };
      FlutterError.onError = (errorDetails) {
        FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
      };
      // Must be registered here (top-level function, before runApp) so FCM
      // can invoke it in a background isolate.
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
      notificationService.initialize();
       print("Firebase initialized successfully. Crashlytics handlers configured.");
    } else {
      print("Firebase.apps is empty after initialization attempt (unexpected).");
    }
  } catch (e, s) {
    print("FATAL: Failed to initialize Firebase: $e\nStack trace:\n$s");
  }
  // --- End Firebase Initialization ---


  // --- MODIFIED: Data Loading with Error Handling ---
  try {
    await Future.wait([
      songService.loadSongs(),
      settingsState.loadSettings(),
      favoritesState.loadFavorites(),
      messageStore.load(),
    ]);
    print("Initial app data loaded successfully.");
  } catch (e, s) {
    print("Error loading initial app data: $e");
    if (Firebase.apps.isNotEmpty) {
      FirebaseCrashlytics.instance.recordError(
        e, s, reason: 'Failed to load initial app data', fatal: false,);
    }
  }
  // --- End Data Loading ---

  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: settingsState.themeMode,
      builder: (context, mode, child) {
        return ValueListenableBuilder<String>(
          valueListenable: settingsState.selectedFont,
          builder: (context, selectedFont, child) {
            String? fontFamily = (selectedFont != 'Default') ? selectedFont : null;

            ThemeData generateThemeData(Brightness brightness) {
              final baseTheme = ThemeData(
                brightness: brightness,
                colorScheme: ColorScheme.fromSeed(
                    seedColor: Colors.blue, brightness: brightness),
                useMaterial3: true,
              );
              return baseTheme.copyWith(
                textTheme: baseTheme.textTheme.apply(fontFamily: fontFamily),
                appBarTheme: baseTheme.appBarTheme.copyWith(
                  backgroundColor: Colors.indigo[900],
                  foregroundColor: Colors.white,
                  elevation: 4.0,
                ),
                // --- Bottom Navigation Bar Theme (indicatorColor line REMOVED) ---
                bottomNavigationBarTheme: BottomNavigationBarThemeData(
                    selectedItemColor: Colors.blue,
                    unselectedItemColor: Colors.grey,
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    // indicatorColor: Colors.transparent, // <<<--- THIS LINE IS NOW REMOVED
                    type: BottomNavigationBarType.fixed,
                    selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
                 ),
                // --- END ---
              );
            }

            return MaterialApp(
              navigatorKey: notificationService.navigatorKey,
              scaffoldMessengerKey: notificationService.scaffoldMessengerKey,
              navigatorObservers: [utils.routeObserver, analyticsObserver], // Added analyticsObserver
              title: 'APATANI BIISI KHETA',
              theme: generateThemeData(Brightness.light),
              darkTheme: generateThemeData(Brightness.dark),
              themeMode: mode,
              home: const MainScreen(),
              debugShowCheckedModeBanner: false,
              routes: {
                '/home': (context) => const MainScreen(initialIndex: 1),
                '/settings': (context) => const MainScreen(initialIndex: 2),
              },
            );
          },
        );
      },
    );
  }
}

// --- MainScreen Widget and State (Includes RouteAware for Analytics) ---
class MainScreen extends StatefulWidget {
  final int initialIndex;
  // Tab order: 0 = Scripture, 1 = Home (default), 2 = Settings.
  const MainScreen({super.key, this.initialIndex = 1});
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with RouteAware { // Added RouteAware
  int _selectedIndex = 1;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

 // --- ADDED: Methods for RouteAware ---
  @override
  void didChangeDependencies() {
      super.didChangeDependencies();
      final modalRoute = ModalRoute.of(context);
      if (modalRoute != null) {
          if (modalRoute is PageRoute<dynamic>) {
            utils.routeObserver.subscribe(this, modalRoute);
          }
          _logScreenView(_selectedIndex); // Initial log
      }
  }

  @override
  void dispose() {
      utils.routeObserver.unsubscribe(this);
      super.dispose();
  }

  @override
  void didPopNext() {
      _logScreenView(_selectedIndex); // Log when returning
  }

  @override
  void didPush() {
      // Optional: Log when pushed if needed for specific tracking
      // _logScreenView(_selectedIndex);
  }
 // --- End RouteAware Methods ---


  // --- ADDED: Screen View Logging Function ---
  void _logScreenView(int index) {
     if (Firebase.apps.isEmpty) {
       print("Firebase not ready, skipping analytics screen log.");
       return;
     }
     String screenName;
     switch (index) {
        case 0: screenName = 'ScriptureScreen'; break;
        case 1: screenName = 'HomeScreen'; break;
        case 2: screenName = 'SettingsScreen'; break;
        default: screenName = 'UnknownScreen_Index$index';
     }
     analytics.logScreenView( screenName: screenName, screenClass: screenName );
     print("Analytics: Logged screen view: $screenName");
  }
  // --- End Logging Function ---


  // Static list of screens — order matches the bottom nav tabs.
  static const List<Widget> _widgetOptions = <Widget>[
    ScriptureInboxScreen(),
    HomeScreen(),
    SettingsScreen(),
  ];

  // Function called when a tab is tapped
  void _onItemTapped(int index) {
    setState(() { _selectedIndex = index; });
    _logScreenView(index); // Log screen view on tab change
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final baseColor = Theme.of(context).scaffoldBackgroundColor;
    final Color shadowColor = isDarkMode ? Colors.black54 : Colors.grey.shade400;
    final Color highlightColor = isDarkMode ? Colors.grey.shade800 : Colors.white;
    final Color secondShadowColor = isDarkMode ? Colors.black45 : Colors.grey.shade300;

    return Scaffold(
      body: IndexedStack(
          index: _selectedIndex,
          children: _widgetOptions,
        ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: baseColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
          boxShadow: [
            BoxShadow( color: highlightColor, offset: const Offset(-1, -1), blurRadius: 3, spreadRadius: 0,),
            BoxShadow( color: shadowColor, offset: const Offset(2, 2), blurRadius: 6, spreadRadius: 1,),
            BoxShadow( color: secondShadowColor, offset: const Offset(3, 3), blurRadius: 8, spreadRadius: 1,),
          ],
        ),
        child: SafeArea( // Added SafeArea
           bottom: true,
           child: ValueListenableBuilder<int>(
             valueListenable: messageStore.unreadCount,
             builder: (context, unread, _) => BottomNavigationBar(
               items: <BottomNavigationBarItem>[
                 BottomNavigationBarItem(
                   icon: _ScriptureTabIcon(unread: unread),
                   label: 'Scripture',
                 ),
                 const BottomNavigationBarItem( icon: Icon(Icons.home), label: 'Home', ),
                 const BottomNavigationBarItem( icon: Icon(Icons.settings), label: 'Settings', ),
               ],
               currentIndex: _selectedIndex,
               onTap: _onItemTapped,
               // Use theme settings
               type: Theme.of(context).bottomNavigationBarTheme.type ?? BottomNavigationBarType.fixed,
               backgroundColor: Colors.transparent, // Keep transparent
               elevation: 0, // Keep 0
               selectedItemColor: Theme.of(context).bottomNavigationBarTheme.selectedItemColor,
               unselectedItemColor: Theme.of(context).bottomNavigationBarTheme.unselectedItemColor,
               selectedLabelStyle: Theme.of(context).bottomNavigationBarTheme.selectedLabelStyle,
               unselectedLabelStyle: Theme.of(context).bottomNavigationBarTheme.unselectedLabelStyle,
               // *** indicatorColor is no longer explicitly set here OR in the theme data ***
            ),
          ),
        ),
      ),
    );
  }
}

// The Scripture tab's open-book icon, with a gold unread-count badge.
class _ScriptureTabIcon extends StatelessWidget {
  final int unread;
  const _ScriptureTabIcon({required this.unread});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        const Icon(Icons.menu_book),
        if (unread > 0)
          Positioned(
            right: -6,
            top: -4,
            child: Container(
              padding: const EdgeInsets.all(3),
              constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
              decoration: const BoxDecoration(
                color: Color(0xFFD8B25A),
                shape: BoxShape.circle,
              ),
              child: Text(
                unread > 9 ? '9+' : '$unread',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF1A237E),
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  height: 1.0,
                ),
              ),
            ),
          ),
      ],
    );
  }
}