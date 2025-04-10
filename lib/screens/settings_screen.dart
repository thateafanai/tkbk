// lib/screens/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:tkbk/widgets/custom_header.dart';
import '../state/settings_state.dart'; // Import the settings state
// Import wakelock - ensure you ran 'flutter pub add wakelock_plus'
import 'package:wakelock_plus/wakelock_plus.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Removed local _isAlwaysOn state
  final List<String> _fontOptions = ['Default', 'Roboto', 'Lato', 'Open Sans'];

  @override
  void initState() {
    super.initState();
    // Optionally sync wakelock state when screen initializes
    // WakelockPlus.enabled.then((isEnabled) {
    //   if (mounted && settingsState.keepScreenAwake.value != isEnabled) {
    //      // Keep state consistent if wakelock was disabled externally
    //      settingsState.setKeepScreenAwake(isEnabled);
    //   }
    // });
  }


  // --- Helper to build Settings Section Titles ---
  Widget _buildSectionTitle(BuildContext context, String title) {
     return Padding(
       padding: const EdgeInsets.only(top: 16.0, bottom: 8.0), // Add top padding
       child: Text(
         title,
         style: Theme.of(context).textTheme.titleMedium?.copyWith(
               fontWeight: FontWeight.bold,
               color: Theme.of(context).colorScheme.primary,
             ),
       ),
     );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    // Note: We will now use ValueListenableBuilders for values that change

    return Scaffold(
      body: Column(
        children: [
          const CustomHeader(title: 'Settings'), // Use the custom header
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                // --- DISPLAY Section ---
                _buildSectionTitle(context, 'DISPLAY'),

                // --- Keep Screen Awake (Replaces Always On) ---
                ValueListenableBuilder<bool>(
                  valueListenable: settingsState.keepScreenAwake, // Listen to keepScreenAwake state
                  builder: (context, isAwake, child) {
                    return Card(
                      child: ListTile(
                        leading: Icon(isAwake ? Icons.lightbulb : Icons.lightbulb_outline),
                        title: const Text('Keep Screen Awake'),
                        subtitle: const Text('Prevents screen from sleeping while app is open'),
                        trailing: Switch(
                          value: isAwake, // Use value from state notifier
                          onChanged: (bool value) async {
                            settingsState.setKeepScreenAwake(value); // Update the state
                            // Apply the setting immediately using wakelock_plus
                            try {
                               await WakelockPlus.toggle(enable: value);
                               print("Wakelock ${value ? 'enabled' : 'disabled'}");
                            } catch(e) {
                               print("Error setting Wakelock: $e");
                               // Optionally show error SnackBar
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Could not control screen awake state.'))
                               );
                               // Revert state if setting failed
                               settingsState.setKeepScreenAwake(!value);
                            }
                          },
                        ),
                      ),
                    );
                  }
                ),
                const SizedBox(height: 8),

                // --- Font Selection ---
                ValueListenableBuilder<String>(
                  valueListenable: settingsState.selectedFont, // Listen to font state
                  builder: (context, currentSelectedFont, child) {
                    return Card(
                      child: ListTile(
                        leading: const Icon(Icons.font_download_outlined),
                        title: const Text('Font'),
                        trailing: DropdownButton<String>(
                          value: currentSelectedFont, // Use value from state notifier
                          underline: Container(),
                          icon: const Icon(Icons.arrow_drop_down),
                          items: _fontOptions.map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem(value: value, child: Text(value));
                          }).toList(),
                          onChanged: (String? newValue) {
                            if (newValue != null) {
                              settingsState.setSelectedFont(newValue); // Update state
                              // No SnackBar needed, change should apply via main.dart listener
                            }
                          },
                        ),
                      ),
                    );
                  }
                ),
                const SizedBox(height: 8),

                // --- Font Size ---
                ValueListenableBuilder<double>(
                  valueListenable: settingsState.fontSize, // Listen to font size state
                  builder: (context, currentFontSize, child) {
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Font Size (${currentFontSize.toStringAsFixed(0)})',
                              style: textTheme.titleMedium
                            ),
                            Slider(
                              value: currentFontSize, // Use value from state notifier
                              min: 12.0,
                              max: 24.0,
                              divisions: 12,
                              label: currentFontSize.toStringAsFixed(0),
                              onChanged: (double value) {
                                settingsState.setFontSize(value); // Update state
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                ),
                const SizedBox(height: 8),

                // --- Theme Selection ---
                ValueListenableBuilder<ThemeMode>(
                  valueListenable: settingsState.themeMode, // Listen to theme state
                  builder: (context, currentThemeMode, child) {
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Theme', style: textTheme.titleMedium),
                            RadioListTile<ThemeMode>(
                              title: const Text('Light'),
                              value: ThemeMode.light,
                              groupValue: currentThemeMode, // Use value from state notifier
                              onChanged: (ThemeMode? value) {
                                if (value != null) settingsState.setThemeMode(value);
                              },
                            ),
                            RadioListTile<ThemeMode>(
                              title: const Text('Dark'),
                              value: ThemeMode.dark,
                              groupValue: currentThemeMode,
                              onChanged: (ThemeMode? value) {
                                if (value != null) settingsState.setThemeMode(value);
                              },
                            ),
                            RadioListTile<ThemeMode>(
                              title: const Text('System Default'),
                              value: ThemeMode.system,
                              groupValue: currentThemeMode,
                              onChanged: (ThemeMode? value) {
                                if (value != null) settingsState.setThemeMode(value);
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                ),

                // --- ABOUT Section ---
                const SizedBox(height: 24),
                const Divider(),
                _buildSectionTitle(context, 'ABOUT'),
                Card( // About Info Card
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                         ListTile(dense: true, contentPadding: EdgeInsets.zero, title: Text('Version', style: textTheme.titleSmall), trailing: const Text('1.0.0')),
                         const Divider(height: 1),
                         ListTile(dense: true, contentPadding: EdgeInsets.zero, title: Text('Developed by', style: textTheme.titleSmall), subtitle: const Text('Thatea Fanai')),
                         const Divider(height: 1),
                         ListTile(dense: true, contentPadding: EdgeInsets.zero, title: Text('Published by', style: textTheme.titleSmall), subtitle: const Text('Apatani Baptist Association, Ziro \nLower Subansiri District, Arunachal Pradesh.')),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Ensure you have a state/settings_state.dart file that looks something like this:
/*
import 'package:flutter/material.dart';
// Import shared_preferences if you want to save/load settings

// Define default values
const double defaultFontSize = 16.0;
const String defaultFont = 'Default';
const ThemeMode defaultThemeMode = ThemeMode.system;
const bool defaultKeepScreenAwake = false;

class SettingsState {
  // Private constructor for singleton pattern
  SettingsState._privateConstructor() {
    // TODO: Load saved settings from SharedPreferences here
    // Example:
    // _loadSettings();
  }

  // Singleton instance
  static final SettingsState instance = SettingsState._privateConstructor();

  // ValueNotifiers hold the state and notify listeners
  final ValueNotifier<ThemeMode> themeMode = ValueNotifier(defaultThemeMode);
  final ValueNotifier<double> fontSize = ValueNotifier(defaultFontSize);
  final ValueNotifier<String> selectedFont = ValueNotifier(defaultFont);
  final ValueNotifier<bool> keepScreenAwake = ValueNotifier(defaultKeepScreenAwake);

  // Methods to update state (and potentially save to SharedPreferences)
  void setThemeMode(ThemeMode mode) {
    if (themeMode.value != mode) {
      themeMode.value = mode;
      // TODO: Save 'mode' to SharedPreferences
      // Example: _saveThemeMode(mode);
    }
  }

  void setFontSize(double size) {
     // Add clamping or validation if needed
     final clampedSize = size.clamp(12.0, 24.0); // Example clamp
    if (fontSize.value != clampedSize) {
      fontSize.value = clampedSize;
      // TODO: Save 'clampedSize' to SharedPreferences
    }
  }

  void setSelectedFont(String font) {
    if (selectedFont.value != font) {
      selectedFont.value = font;
      // TODO: Save 'font' to SharedPreferences
    }
  }

   void setKeepScreenAwake(bool awake) {
    if (keepScreenAwake.value != awake) {
      keepScreenAwake.value = awake;
      // TODO: Save 'awake' to SharedPreferences
    }
  }

  // --- Example loading/saving with shared_preferences (Add shared_preferences package) ---
  /*
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    themeMode.value = ThemeMode.values[prefs.getInt('themeMode') ?? defaultThemeMode.index];
    fontSize.value = prefs.getDouble('fontSize') ?? defaultFontSize;
    selectedFont.value = prefs.getString('selectedFont') ?? defaultFont;
    keepScreenAwake.value = prefs.getBool('keepScreenAwake') ?? defaultKeepScreenAwake;
  }

  Future<void> _saveThemeMode(ThemeMode mode) async {
     final prefs = await SharedPreferences.getInstance();
     prefs.setInt('themeMode', mode.index);
  }
  // Add similar save methods for fontSize, selectedFont, keepScreenAwake
  */

}

// Global instance accessible throughout the app
final settingsState = SettingsState.instance;
*/