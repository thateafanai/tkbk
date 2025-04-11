// lib/screens/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:tkbk/widgets/custom_header.dart';
import '../state/settings_state.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
// Import the package info plus package
import 'package:package_info_plus/package_info_plus.dart'; // <-- Import PackageInfo

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final List<String> _fontOptions = ['Default', 'Roboto', 'Lato', 'Open Sans'];

  // --- State variables for package info ---
  String _appName = ''; // Initialize empty
  String _version = '';
  String _buildNumber = '';
  // --- End package info state ---

  @override
  void initState() {
    super.initState();
    // Load package info when the screen initializes
    _loadPackageInfo();
  }

  // --- Function to load package info ---
  Future<void> _loadPackageInfo() async {
    try {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      if (mounted) { // Check if the widget is still mounted
        setState(() {
          _appName = packageInfo.appName;
          _version = packageInfo.version;
          _buildNumber = packageInfo.buildNumber;
        });
      }
    } catch (e) {
       print("Error loading package info: $e");
       if (mounted) {
         setState(() { // Show error in UI if loading fails
           _version = 'N/A';
           _buildNumber = '';
         });
       }
    }
  }
  // --- End function ---

  // --- Helper to build Settings Section Titles ---
  Widget _buildSectionTitle(BuildContext context, String title) {
     return Padding(
       padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
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

    return Scaffold(
      // Keep your structure with CustomHeader in body
      body: Column(
        children: [
          // Use CustomHeader WITHOUT back button for this main screen
          const CustomHeader(title: 'Settings', showBackButton: false),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                // --- DISPLAY Section ---
                _buildSectionTitle(context, 'DISPLAY'),
                ValueListenableBuilder<bool>( // Keep Awake
                  valueListenable: settingsState.keepScreenAwake,
                  builder: (context, isAwake, child) {
                    return Card( child: ListTile(
                        leading: Icon(isAwake ? Icons.lightbulb : Icons.lightbulb_outline),
                        title: const Text('Keep Screen Awake'),
                        subtitle: const Text('Prevents screen from sleeping'),
                        trailing: Switch(
                          value: isAwake,
                          onChanged: (bool value) async {
                            settingsState.setKeepScreenAwake(value);
                            try {
                               await WakelockPlus.toggle(enable: value);
                            } catch(e) {
                               print("Error setting Wakelock: $e");
                               ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not control screen awake state.')));
                               settingsState.setKeepScreenAwake(!value); // revert
                            }
                          },
                        ),
                      ),
                    );
                  }
                ),
                const SizedBox(height: 8),
                ValueListenableBuilder<String>( // Font Selection
                  valueListenable: settingsState.selectedFont,
                  builder: (context, currentSelectedFont, child) {
                    return Card( child: ListTile(
                        leading: const Icon(Icons.font_download_outlined),
                        title: const Text('Font'),
                        trailing: DropdownButton<String>(
                          value: currentSelectedFont,
                          underline: Container(),
                          icon: const Icon(Icons.arrow_drop_down),
                          items: _fontOptions.map<DropdownMenuItem<String>>((String v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
                          onChanged: (String? v) { if (v != null) settingsState.setSelectedFont(v); },
                        ),
                      ),
                    );
                  }
                ),
                const SizedBox(height: 8),
                ValueListenableBuilder<double>( // Font Size Slider
                  valueListenable: settingsState.fontSize,
                  builder: (context, currentFontSize, child) {
                    return Card( child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Font Size (${currentFontSize.toStringAsFixed(0)})', style: textTheme.titleMedium),
                            Slider(
                              value: currentFontSize, min: 12.0, max: 24.0, divisions: 12,
                              label: currentFontSize.toStringAsFixed(0),
                              onChanged: (double v) => settingsState.setFontSize(v),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                ),
                const SizedBox(height: 8),
                ValueListenableBuilder<ThemeMode>( // Theme Selection
                  valueListenable: settingsState.themeMode,
                  builder: (context, currentThemeMode, child) {
                    return Card( child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Theme', style: textTheme.titleMedium),
                            RadioListTile<ThemeMode>(title: const Text('Light'), value: ThemeMode.light, groupValue: currentThemeMode, onChanged: (v) {if(v!=null) settingsState.setThemeMode(v);}),
                            RadioListTile<ThemeMode>(title: const Text('Dark'), value: ThemeMode.dark, groupValue: currentThemeMode, onChanged: (v) {if(v!=null) settingsState.setThemeMode(v);}),
                            RadioListTile<ThemeMode>(title: const Text('System Default'), value: ThemeMode.system, groupValue: currentThemeMode, onChanged: (v) {if(v!=null) settingsState.setThemeMode(v);}),
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
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                         // --- MODIFIED VERSION ListTile ---
                         ListTile(
                           dense: true, contentPadding: EdgeInsets.zero,
                           title: Text('Version', style: textTheme.titleSmall),
                           // Display dynamic version + build number from state
                           trailing: Text(_version.isEmpty ? 'Loading...' : '$_version+$_buildNumber'),
                         ),
                         // --- END MODIFIED ---
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