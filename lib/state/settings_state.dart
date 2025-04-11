// lib/state/settings_state.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart'; // For kDebugMode

// --- Define Keys for SharedPreferences ---
const String _themeModeKey = 'themeMode';
const String _fontSizeKey = 'fontSize';
const String _selectedFontKey = 'selectedFont';
const String _keepScreenAwakeKey = 'keepScreenAwake';

// --- Define Default Values ---
const double defaultFontSize = 16.0; // Base size for calculations
const String defaultFont = 'Default';
const ThemeMode defaultThemeMode = ThemeMode.system;
const bool defaultKeepScreenAwake = false;

class SettingsState {
  SettingsState._privateConstructor();
  static final SettingsState instance = SettingsState._privateConstructor();

  // ValueNotifiers
  final ValueNotifier<ThemeMode> themeMode = ValueNotifier(defaultThemeMode);
  final ValueNotifier<double> fontSize = ValueNotifier(defaultFontSize);
  final ValueNotifier<String> selectedFont = ValueNotifier(defaultFont);
  final ValueNotifier<bool> keepScreenAwake = ValueNotifier(defaultKeepScreenAwake);

  // Getter for font size factor (useful for direct application)
  double get fontSizeFactor => (fontSize.value <= 0 ? defaultFontSize : fontSize.value) / defaultFontSize;

  // Initialization Method
  Future<void> loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final themeIndex = prefs.getInt(_themeModeKey);
      themeMode.value = themeIndex != null && themeIndex >= 0 && themeIndex < ThemeMode.values.length
                         ? ThemeMode.values[themeIndex]
                         : defaultThemeMode;
      fontSize.value = prefs.getDouble(_fontSizeKey) ?? defaultFontSize;
      selectedFont.value = prefs.getString(_selectedFontKey) ?? defaultFont;
      keepScreenAwake.value = prefs.getBool(_keepScreenAwakeKey) ?? defaultKeepScreenAwake;

      if (kDebugMode) {
        print('Settings Loaded: Theme=${themeMode.value}, Font Size=${fontSize.value}, Font=${selectedFont.value}, Keep Awake=${keepScreenAwake.value}');
      }

    } catch (e) {
       if (kDebugMode) { print("Error loading settings: $e"); }
       // Reset to defaults on error
       themeMode.value = defaultThemeMode;
       fontSize.value = defaultFontSize;
       selectedFont.value = defaultFont;
       keepScreenAwake.value = defaultKeepScreenAwake;
    }
  }

  // --- Update and Save Methods ---
  Future<void> setThemeMode(ThemeMode mode) async {
    if (themeMode.value != mode) {
      themeMode.value = mode;
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt(_themeModeKey, mode.index);
      } catch (e) { if (kDebugMode) { print("Error saving theme mode: $e"); } }
    }
  }

  Future<void> setFontSize(double size) async {
     final clampedSize = size.clamp(12.0, 24.0); // Apply clamping
    // Use tolerance for comparing doubles
    if ((fontSize.value - clampedSize).abs() > 0.01) {
      fontSize.value = clampedSize;
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setDouble(_fontSizeKey, clampedSize);
      } catch (e) { if (kDebugMode) { print("Error saving font size: $e"); } }
    }
  }

  Future<void> setSelectedFont(String font) async {
    // Add validation if needed
    if (selectedFont.value != font) {
      selectedFont.value = font;
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_selectedFontKey, font);
      } catch (e) { if (kDebugMode) { print("Error saving selected font: $e"); } }
    }
  }

   Future<void> setKeepScreenAwake(bool awake) async {
    if (keepScreenAwake.value != awake) {
      keepScreenAwake.value = awake;
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool(_keepScreenAwakeKey, awake);
      } catch (e) { if (kDebugMode) { print("Error saving keep screen awake: $e"); } }
    }
  }
}

// Global instance
final settingsState = SettingsState.instance;