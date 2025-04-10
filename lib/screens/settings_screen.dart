// lib/screens/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:tkbk/widgets/custom_header.dart';
import '../state/settings_state.dart'; // Import the settings state

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isAlwaysOn = false;
  final List<String> _fontOptions = ['Default', 'Roboto', 'Lato', 'Open Sans'];

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final currentThemeMode = settingsState.themeMode.value;
    final currentFontSize = settingsState.fontSize.value;
    final currentSelectedFont = settingsState.selectedFont.value; // Get the current selected font from state

    return Scaffold(
      body: Column(
        children: [
          const CustomHeader(title: 'Settings'), // Use the custom header
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                // --- DISPLAY Section ---
                Text(
                  'DISPLAY',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 8),
                Card( // Always On
                  child: ListTile(
                    leading: const Icon(Icons.lightbulb_outline),
                    title: const Text('Always On Display'),
                    trailing: Switch(
                      value: _isAlwaysOn,
                      onChanged: (bool value) {
                        setState(() {
                          _isAlwaysOn = value;
                          ScaffoldMessenger.of(context).showSnackBar(
                             const SnackBar(
                               content: Text('Always On Display cannot be controlled by this app.'),
                               duration: Duration(seconds: 2)
                             )
                          );
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                Card( // Font Selection
                  child: ListTile(
                    leading: const Icon(Icons.font_download_outlined),
                    title: const Text('Font'),
                    trailing: DropdownButton<String>(
                      value: currentSelectedFont, // Use the value from settingsState
                      underline: Container(),
                      icon: const Icon(Icons.arrow_drop_down),
                      items: _fontOptions.map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          settingsState.setSelectedFont(newValue); // Update the selected font in settingsState
                           ScaffoldMessenger.of(context).showSnackBar(
                             const SnackBar(content: Text('Global font application pending.'), duration: Duration(seconds: 1))
                          );
                        }
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                Card( // Font Size
                  child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Font Size (${currentFontSize.toStringAsFixed(0)})', style: textTheme.titleMedium),
                          Slider(
                            value: currentFontSize,
                            min: 12.0,
                            max: 24.0,
                            divisions: 12,
                            label: currentFontSize.toStringAsFixed(0),
                            onChanged: (double value) {
                              settingsState.setFontSize(value);
                            },
                          ),
                        ],
                      ),
                    ),
                ),
                const SizedBox(height: 8),

                Card( // Theme Selection
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Theme', style: textTheme.titleMedium),
                        RadioListTile<ThemeMode>(
                          title: const Text('Light'),
                          value: ThemeMode.light,
                          groupValue: currentThemeMode,
                          onChanged: (ThemeMode? value) {
                            if (value != null) {
                              settingsState.setThemeMode(value);
                            }
                          },
                        ),
                        RadioListTile<ThemeMode>(
                          title: const Text('Dark'),
                          value: ThemeMode.dark,
                          groupValue: currentThemeMode,
                          onChanged: (ThemeMode? value) {
                            if (value != null) {
                              settingsState.setThemeMode(value);
                            }
                          },
                        ),
                        RadioListTile<ThemeMode>(
                          title: const Text('System Default'),
                          value: ThemeMode.system,
                          groupValue: currentThemeMode,
                          onChanged: (ThemeMode? value) {
                            if (value != null) {
                              settingsState.setThemeMode(value);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 16),

                // --- ABOUT Section ---
                Text(
                  'ABOUT',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 8),

                Card( // Card for About info
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                          ListTile(
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                            title: Text('Version', style: textTheme.titleSmall),
                            trailing: const Text('1.0.0'),
                          ),
                        const Divider(height: 1),
                          ListTile(
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                            title: Text('Developed by', style: textTheme.titleSmall),
                            subtitle: const Text('Thatea Fanai'),
                          ),
                        const Divider(height: 1),
                          ListTile(
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                            title: Text('Published by', style: textTheme.titleSmall),
                            subtitle: const Text('Apatani Baptist Association, Ziro \nLower Subansiri District, Arunachal Pradesh.'),
                          ),
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