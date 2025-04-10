// lib/state/settings_state.dart
import 'package:flutter/material.dart';

class SettingsState {
  // Private constructor for singleton pattern
  SettingsState._privateConstructor();

  // Singleton instance
  static final SettingsState instance = SettingsState._privateConstructor();

  // ValueNotifiers to hold and notify about changes
  final ValueNotifier<ThemeMode> themeMode = ValueNotifier(ThemeMode.system);
  final ValueNotifier<double> fontSize = ValueNotifier(16.0); // Default font size
  final ValueNotifier<String> selectedFont = ValueNotifier('Default'); // Add for font selection

  // --- Methods to update settings ---

  void setThemeMode(ThemeMode newMode) {
    if (themeMode.value != newMode) {
      themeMode.value = newMode;
      // TODO: Persist this setting using SharedPreferences or similar
    }
  }

  void setFontSize(double newSize) {
    if (fontSize.value != newSize) {
      fontSize.value = newSize;
       // TODO: Persist this setting
    }
  }

  // --- Method to update font selection ---
  void setSelectedFont(String newFont) {
    if (selectedFont.value != newFont) {
      selectedFont.value = newFont;
      // TODO: Persist this setting & apply font
    }
  }
}

// Global instance for easy access
final settingsState = SettingsState.instance;