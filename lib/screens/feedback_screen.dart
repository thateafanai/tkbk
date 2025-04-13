// lib/screens/feedback_screen.dart
import 'package:flutter/material.dart';
import 'package:tkbk/widgets/custom_header.dart'; // Import the updated custom header
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
// Import Settings and Home if needed for bottom nav routes (keep if using named routes)
// import 'settings_screen.dart';
// import 'home_screen.dart';


class FeedbackScreen extends StatelessWidget {
  const FeedbackScreen({super.key});

  // --- Your _launchWhatsApp and _shareApp functions remain the same ---
  Future<void> _launchWhatsApp() async {
    const String phoneNumber = '9774912873';
    const String message = 'Hi... Greetings to you, I have some feedback for the Apatani Biisi Kheta App..';
    final String encodedMessage = Uri.encodeComponent(message);
    final Uri whatsappUri = Uri.parse('https://wa.me/$phoneNumber?text=$encodedMessage');
    try {
      if (await canLaunchUrl(whatsappUri)) {
        await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
      } else { print('Could not launch WhatsApp URL: $whatsappUri'); }
    } catch (e) { print('Could not launch WhatsApp: $e'); }
  }

  void _shareApp(BuildContext context) {
    const String playStoreLink = 'https://play.google.com/store/apps/details?id=com.thatea.tkbk'; // Your internal test link
    Share.share(
      'Check out the Apatani Biisi Kheta App! You can become a tester and help us improve it by joining our internal testing program here: $playStoreLink',
    );
  }
  // --- End of your functions ---

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    // --- Neumorphic styling variables for Bottom Nav ---
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final baseColor = Theme.of(context).scaffoldBackgroundColor;
    final Color shadowColor = isDarkMode ? Colors.black54 : Colors.grey.shade400;
    final Color highlightColor = isDarkMode ? Colors.grey.shade800 : Colors.white;
    final Color secondShadowColor = isDarkMode ? Colors.black45 : Colors.grey.shade300;
    // --- End Neumorphic styling variables ---

    return Scaffold(
      // Use CustomHeader in appBar slot for correct status bar handling & back button
      appBar: const CustomHeader(
          title: 'Feedback',
          showBackButton: true // Enable back button
      ),
      body: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding( // Logo
                padding: const EdgeInsets.only(bottom: 24.0, top: 16.0),
                child: Image.asset('assets/logo.png', height: 100,
                  errorBuilder: (context, error, stackTrace) {
                     return const Icon(Icons.error_outline, size: 50, color: Colors.red);
                   },
                ),
              ),
              Text( // Heading
                'Do you need assistance\nor\nhave any suggestions to share?',
                textAlign: TextAlign.center,
                style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),
              Text( // Paragraph
                'We would love to hear your feedback on this application. As it is still in its early stage, there may be some missing features or functionality. We welcome your suggestions and encourage you to reach out to us anytime.',
                textAlign: TextAlign.center,
                style: textTheme.bodyMedium?.copyWith(color: Colors.grey[700], height: 1.4),
              ),
              const SizedBox(height: 60),
              Padding( // Buttons Row
                padding: const EdgeInsets.only(bottom: 32.0, left: 8.0, right: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                     ElevatedButton(
                       style: ElevatedButton.styleFrom(backgroundColor: Colors.black, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12), textStyle: const TextStyle(fontSize: 14)),
                       onPressed: () => _shareApp(context),
                       child: const Text('SHARE'),
                     ),
                     ElevatedButton(
                       style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12), textStyle: const TextStyle(fontSize: 14)),
                       onPressed: _launchWhatsApp,
                       child: const Text('WHATSAPP'),
                     ),
                  ],
                ),
              ),
            ],
          ),
        ),
      // --- Bottom Navigation Bar with corrected onTap logic ---
       bottomNavigationBar: Container(
         decoration: BoxDecoration(
           color: baseColor,
           borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
           boxShadow: [
             BoxShadow(color: highlightColor, offset: const Offset(-1, -1), blurRadius: 3, spreadRadius: 0),
             BoxShadow(color: shadowColor, offset: const Offset(2, 2), blurRadius: 6, spreadRadius: 1),
             BoxShadow(color: secondShadowColor, offset: const Offset(3, 3), blurRadius: 8, spreadRadius: 1),
           ],
         ),
         child: SafeArea(
           child: BottomNavigationBar(
             items: const <BottomNavigationBarItem>[
               BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
               BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
             ],
             // Set initial index? Or get from current route? For simplicity, keep 0.
             // If you came from Settings->Feedback, this will incorrectly show Home selected.
             // Removing this custom bottom bar is the cleanest solution.
             currentIndex: 0,
             onTap: (index) {
           if (index == 0) {
             // Home Button: Pop everything until the first screen (MainScreen)
             Navigator.of(context).popUntil((route) => route.isFirst);
             // We assume MainScreen will default to showing HomeScreen (index 0)
             // If not, we might need a way to tell MainScreen to switch index.
           } else if (index == 1) {
             // Settings Button: Pop back to MainScreen first, THEN navigate to /settings
             Navigator.of(context).popUntil((route) => route.isFirst);
             // Use a microtask delay to allow the pop to complete before pushing
             Future.microtask(() {
                // Try navigating using the root navigator after popping
                Navigator.of(context, rootNavigator: true).pushReplacementNamed('/settings');
             });
           }
         },
             selectedItemColor: Theme.of(context).bottomNavigationBarTheme.selectedItemColor ?? Colors.blue,
             unselectedItemColor: Theme.of(context).bottomNavigationBarTheme.unselectedItemColor ?? Colors.grey,
             type: BottomNavigationBarType.fixed,
             backgroundColor: Colors.transparent,
             elevation: 0,
              selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
           ),
         ),
       ),
    );
  }
}