// lib/state/settings_state.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// --- Define Keys for SharedPreferences ---
const String _themeModeKey = 'themeMode';
const String _fontSizeKey = 'fontSize';
const String _selectedFontKey = 'selectedFont';
const String _keepScreenAwakeKey = 'keepScreenAwake';

// --- Define Default Values ---
const double defaultFontSize = 16.0;
const String defaultFont = 'Default';
const ThemeMode defaultThemeMode = ThemeMode.system;
const bool defaultKeepScreenAwake = false;

class SettingsState {
  // Private constructor for singleton pattern
  SettingsState._privateConstructor();

  // Singleton instance
  static final SettingsState instance = SettingsState._privateConstructor();

  // --- ValueNotifiers hold the state and notify listeners ---
  final ValueNotifier<ThemeMode> themeMode = ValueNotifier(defaultThemeMode);
  final ValueNotifier<double> fontSize = ValueNotifier(defaultFontSize);
  final ValueNotifier<String> selectedFont = ValueNotifier(defaultFont);
  final ValueNotifier<bool> keepScreenAwake = ValueNotifier(defaultKeepScreenAwake);

  // --- Initialization Method (Call this from main.dart) ---
  Future<void> loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Load ThemeMode (use index for saving/loading enum)
      final themeIndex = prefs.getInt(_themeModeKey);
      themeMode.value = themeIndex != null && themeIndex >= 0 && themeIndex < ThemeMode.values.length
                         ? ThemeMode.values[themeIndex]
                         : defaultThemeMode;

      // Load FontSize
      fontSize.value = prefs.getDouble(_fontSizeKey) ?? defaultFontSize;

      // Load SelectedFont
      selectedFont.value = prefs.getString(_selectedFontKey) ?? defaultFont;

      // Load KeepScreenAwake
      keepScreenAwake.value = prefs.getBool(_keepScreenAwakeKey) ?? defaultKeepScreenAwake;

    } catch (e) {
       print("Error loading settings: $e");
       // Keep default values if loading fails
    }
  }


  // --- Methods to update state AND save to SharedPreferences ---
  Future<void> setThemeMode(ThemeMode mode) async {
    if (themeMode.value != mode) {
      themeMode.value = mode;
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt(_themeModeKey, mode.index); // Save enum index
      } catch (e) {
        print("Error saving theme mode: $e");
      }
    }
  }

  Future<void> setFontSize(double size) async {
     final clampedSize = size.clamp(12.0, 24.0); // Apply clamping
    if ((fontSize.value - clampedSize).abs() > 0.01) { // Use tolerance for double comparison
      fontSize.value = clampedSize;
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setDouble(_fontSizeKey, clampedSize);
      } catch (e) {
        print("Error saving font size: $e");
      }
    }
  }

  Future<void> setSelectedFont(String font) async {
    // Ensure the font is one of the valid options if needed
    // const List<String> _fontOptions = ['Default', 'Roboto', 'Lato', 'Open Sans'];
    // if (!_fontOptions.contains(font)) font = defaultFont; // Example validation

    if (selectedFont.value != font) {
      selectedFont.value = font;
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_selectedFontKey, font);
      } catch (e) {
        print("Error saving selected font: $e");
      }
    }
  }

   Future<void> setKeepScreenAwake(bool awake) async {
    if (keepScreenAwake.value != awake) {
      keepScreenAwake.value = awake;
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool(_keepScreenAwakeKey, awake);
      } catch (e) {
        print("Error saving keep screen awake: $e");
      }
    }
  }
}

// Global instance accessible throughout the app
final settingsState = SettingsState.instance;