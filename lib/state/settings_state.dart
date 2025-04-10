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

  // --- Placeholder for future font selection ---
  // final ValueNotifier<String> fontFamily = ValueNotifier('Default');
  // void setFontFamily(String newFont) {
  //   if (fontFamily.value != newFont) {
  //     fontFamily.value = newFont;
  //     // TODO: Persist this setting & apply font
  //   }
  // }
}

// Global instance for easy access
final settingsState = SettingsState.instance;