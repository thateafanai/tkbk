// lib/screens/feedback_screen.dart
import 'package:flutter/material.dart';
import 'package:tkbk/widgets/custom_header.dart';
import 'package:url_launcher/url_launcher.dart';

class FeedbackScreen extends StatelessWidget {
  const FeedbackScreen({super.key});

  Future<void> _launchWhatsApp() async {
    const String phoneNumber = '9774912873';
    const String message = 'Hi... Greetings to you, I have some feedback for the Apatani Biisi Kheta App..';
    final String encodedMessage = Uri.encodeComponent(message);
    final Uri whatsappUri = Uri.parse('https://wa.me/$phoneNumber?text=$encodedMessage');

    try {
      if (await canLaunchUrl(whatsappUri)) {
        await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
      } else {
        print('Could not launch WhatsApp URL: $whatsappUri');
      }
    } catch (e) {
      print('Could not launch WhatsApp: $e');
    }
  }

  void _shareApp(BuildContext context) {
    const String playStoreLink = 'YOUR_PLAY_STORE_LINK_HERE'; // Placeholder

    if (playStoreLink == 'YOUR_PLAY_STORE_LINK_HERE') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Share link will be added soon!'),
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      print('Sharing link: $playStoreLink');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sharing function to be implemented.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final textTheme = Theme.of(context).textTheme;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final baseColor = Theme.of(context).scaffoldBackgroundColor; // Use the scaffold background color

    // Define shadow and highlight colors based on the theme
    final Color shadowColor = isDarkMode ? Colors.black54 : Colors.grey.shade400;
    final Color highlightColor = isDarkMode ? Colors.grey.shade800 : Colors.white;
    final Color secondShadowColor = isDarkMode ? Colors.black45 : Colors.grey.shade300; // A slightly lighter shadow

    return Scaffold(
      body: Column(
        children: [
          const CustomHeader(title: 'Feedback'),
          Expanded(
            child: SafeArea(
              top: false, // The CustomHeader already handles top padding
              bottom: false,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 24.0),
                      child: Image.asset(
                        'assets/logo.png',
                        height: 100,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.error_outline,
                            size: 50,
                            color: Colors.red,
                          );
                        },
                      ),
                    ),
                    Text(
                      'Do you need assistance\nor\nhave any suggestions to share?',
                      textAlign: TextAlign.center,
                      style: textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'We would love to hear your feedback on this application. As it is still in its early stage, there may be some missing features or functionality. We welcome your suggestions and encourage you to reach out to us anytime.',
                      textAlign: TextAlign.center,
                      style: textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[700],
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 40),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                            textStyle: const TextStyle(fontSize: 16),
                          ),
                          onPressed: () => _shareApp(context),
                          child: const Text('SHARE'),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                            textStyle: const TextStyle(fontSize: 16),
                          ),
                          onPressed: _launchWhatsApp,
                          child: const Text('WHATSAPP'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container( // Wrap BottomNavigationBar with Container
        decoration: BoxDecoration(
          color: baseColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(15)), // Optional rounded corners
          boxShadow: [
            // Subtle top highlight
            BoxShadow(
              color: highlightColor,
              offset: const Offset(-1, -1),
              blurRadius: 3,
              spreadRadius: 0,
            ),
            // Primary bottom shadow
            BoxShadow(
              color: shadowColor,
              offset: const Offset(2, 2),
              blurRadius: 6,
              spreadRadius: 1,
            ),
            // Secondary, softer bottom shadow for more depth
            BoxShadow(
              color: secondShadowColor,
              offset: const Offset(3, 3),
              blurRadius: 8,
              spreadRadius: 1,
            ),
          ],
        ),
        child: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
          currentIndex: 0, // Keep it at 0 as there's no state to track here directly
          onTap: (index) {
            if (index == 0) {
              // Navigate to Home
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              } else {
                Navigator.pushReplacementNamed(context, '/home'); // Or however you navigate to Home
              }
            } else if (index == 1) {
              // Navigate to Settings
              Navigator.pushReplacementNamed(context, '/settings'); // Assuming you have a route named '/settings'
            }
          },
          selectedItemColor: Theme.of(context).bottomNavigationBarTheme.selectedItemColor ?? Colors.blue,
          unselectedItemColor: Theme.of(context).bottomNavigationBarTheme.unselectedItemColor ?? Colors.grey,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent, // Make the BottomNavigationBar background transparent
          elevation: 0, // Remove default elevation
        ),
      ),
    );
  }
}