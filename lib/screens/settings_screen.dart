// lib/screens/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:tkbk/widgets/custom_header.dart'; // Ensure this path is correct
import '../state/settings_state.dart';          // Ensure this path is correct and settingsState is accessible
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final List<String> _fontOptions = ['Default', 'Roboto', 'Lato', 'Open Sans'];
  String _appName = '';
  String _version = '';
  String _buildNumber = '';

  @override
  void initState() {
    super.initState();
    _loadPackageInfo();
  }

  // Fetches package information like version number.
  Future<void> _loadPackageInfo() async {
    try {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      if (mounted) { // Check if the widget is still in the tree
        setState(() {
          _appName = packageInfo.appName;
          _version = packageInfo.version;
          _buildNumber = packageInfo.buildNumber;
        });
      }
    } catch (e) {
      print("Error loading package info: $e");
      if (mounted) {
        setState(() { _version = 'N/A'; _buildNumber = ''; });
      }
    }
  }

  // Helper Function to launch a URL using the url_launcher package.
  // Takes a Uri object as input.
  Future<void> _launchUrl(Uri url) async {
     try {
       // Check if the device can handle the URL scheme (http, https, etc.)
       if (await canLaunchUrl(url)) {
         // Launch the URL in an external application (usually the browser or app store)
         await launchUrl(url, mode: LaunchMode.externalApplication);
       } else {
         print('Could not launch ${url.toString()}');
         // Show a snackbar message if the URL can't be launched
         if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not open link: ${url.toString()}')));
       }
     } catch(e) {
       // Catch potential errors during URL launching
       print('Error launching URL: $e');
       if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error opening link: $e')));
     }
   }

  // Helper widget to create styled section titles.
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

  // Helper function to toggle the screen wakelock.
  // Updates the state via settingsState and uses the WakelockPlus package.
  Future<void> _toggleWakelock(bool enable) async {
     settingsState.setKeepScreenAwake(enable); // Update your app's state
     try {
       await WakelockPlus.toggle(enable: enable);
       print("Wakelock ${enable ? 'enabled' : 'disabled'}");
     }
     catch(e) {
       print("Error setting Wakelock: $e");
       // Show error and revert state if Wakelock fails
       if(mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not control screen awake state.')));
       settingsState.setKeepScreenAwake(!enable); // Revert state on error
     }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    // Define URLs for easier management
    final Uri playStoreUrl = Uri.parse('https://play.google.com/store/apps/details?id=com.thatea.tkbk'); // Replace with your actual package ID
    final Uri policyUrl = Uri.parse('https://thateafanai.github.io/tkbk/privacy_policy.html'); // Replace with your actual policy URL

    return Scaffold(
      // Use your custom header in the appBar slot
      appBar: const CustomHeader(title: 'Settings', showBackButton: false),
      body: ListView( // Use ListView for scrollable content
           padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
           children: [
             // --- DISPLAY Section ---
             _buildSectionTitle(context, 'DISPLAY'),
             // Keep Screen Awake Setting
             ValueListenableBuilder<bool>(
               valueListenable: settingsState.keepScreenAwake,
               builder: (context, isAwake, child) => Card(
                 child: ListTile(
                   leading: Icon(isAwake ? Icons.lightbulb : Icons.lightbulb_outline),
                   title: const Text('Keep Screen Awake'),
                   subtitle: const Text('Prevents screen from sleeping'),
                   trailing: Switch(value: isAwake, onChanged: (bool value) => _toggleWakelock(value)),
                 )
               ),
             ),
             const SizedBox(height: 8),
             // Font Selection Setting
             ValueListenableBuilder<String>(
               valueListenable: settingsState.selectedFont,
               builder: (context, font, child) => Card(
                 child: ListTile(
                   leading: const Icon(Icons.font_download_outlined),
                   title: const Text('Font'),
                   trailing: DropdownButton<String>(
                     value: font,
                     underline: Container(), // Hide default underline
                     icon: const Icon(Icons.arrow_drop_down),
                     items: _fontOptions.map<DropdownMenuItem<String>>((String value) {
                       return DropdownMenuItem<String>(value: value, child: Text(value));
                     }).toList(),
                     onChanged: (String? newValue) {
                       if (newValue != null) settingsState.setSelectedFont(newValue);
                     }
                   )
                 )
               ),
             ),
             const SizedBox(height: 8),
             // Font Size Setting
             ValueListenableBuilder<double>(
               valueListenable: settingsState.fontSize,
               builder: (context, size, child) => Card(
                 child: Padding(
                   padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                   child: Column(
                     crossAxisAlignment: CrossAxisAlignment.start,
                     children: [
                       Text('Font Size (${size.toStringAsFixed(0)})', style: textTheme.titleMedium),
                       Slider(
                         value: size,
                         min: 12.0,
                         max: 24.0,
                         divisions: 12, // Creates steps between min and max
                         label: size.toStringAsFixed(0), // Label shown during sliding
                         onChanged: (double value) => settingsState.setFontSize(value),
                       ),
                     ],
                   ),
                 ),
               )
             ),
             const SizedBox(height: 8),
             // Theme Selection Setting
             ValueListenableBuilder<ThemeMode>(
               valueListenable: settingsState.themeMode,
               builder: (context, mode, child) => Card(
                 child: Padding(
                   padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                   child: Column(
                     crossAxisAlignment: CrossAxisAlignment.start,
                     children: [
                       Text('Theme', style: textTheme.titleMedium),
                       RadioListTile<ThemeMode>(title: const Text('Light'), value: ThemeMode.light, groupValue: mode, onChanged: (v){if(v!=null)settingsState.setThemeMode(v);}),
                       RadioListTile<ThemeMode>(title: const Text('Dark'), value: ThemeMode.dark, groupValue: mode, onChanged: (v){if(v!=null)settingsState.setThemeMode(v);}),
                       RadioListTile<ThemeMode>(title: const Text('System Default'), value: ThemeMode.system, groupValue: mode, onChanged: (v){if(v!=null)settingsState.setThemeMode(v);}),
                     ],
                   ),
                 ),
               )
             ),

             // --- ABOUT Section ---
             const SizedBox(height: 24), // Add spacing before the divider
             const Divider(),
             _buildSectionTitle(context, 'ABOUT'),
             Card(
               child: Column(
                 mainAxisSize: MainAxisSize.min, // Prevent card from taking full height
                 children: [
                   ListTile(
                     dense: true,
                     title: Text('Version', style: textTheme.titleSmall),
                     trailing: Text(_version.isEmpty ? 'Loading...' : '$_version+$_buildNumber'), // Show loading or version
                   ),
                   const Divider(height: 1, indent: 16, endIndent: 16), // Divider inside the card
                   ListTile(
                     dense: true,
                     title: Text('Developed by', style: textTheme.titleSmall),
                     subtitle: const Text('Thatea Fanai'),
                   ),
                   const Divider(height: 1, indent: 16, endIndent: 16),
                   ListTile(
                     dense: true,
                     title: Text('Published by', style: textTheme.titleSmall),
                     subtitle: const Text('Apatani Baptist Association, Ziro \nLower Subansiri District, Arunachal Pradesh.'),
                   ),
                   const Divider(height: 1, indent: 16, endIndent: 16),
                   // Privacy Policy Link
                   ListTile(
                     dense: true,
                     title: Text('Privacy Policy', style: textTheme.titleSmall),
                     trailing: const Icon(Icons.launch_outlined, size: 18, color: Colors.blue),
                     onTap: () => _launchUrl(policyUrl), // Launch URL on tap
                   ),
                   const Divider(height: 1, indent: 16, endIndent: 16),
                   // Rate App Link
                   ListTile(
                     dense: true,
                     title: Text('Rate this app', style: textTheme.titleSmall),
                     trailing: const Icon(Icons.star_outline, size: 20, color: Colors.amber),
                     onTap: () => _launchUrl(playStoreUrl), // Launch URL on tap
                   ),
                 ],
               ),
             ),
              const SizedBox(height: 16), // Add some padding at the bottom
           ],
         ),
    );
  }
}