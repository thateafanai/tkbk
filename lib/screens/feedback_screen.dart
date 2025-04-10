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

  void _onBottomNavItemTapped(BuildContext context, int index) {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final textTheme = Theme.of(context).textTheme;

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
      bottomNavigationBar: BottomNavigationBar(
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
        currentIndex: 0,
        onTap: (index) => _onBottomNavItemTapped(context, index),
        selectedItemColor: Theme.of(context).bottomNavigationBarTheme.selectedItemColor ?? Colors.blue,
        unselectedItemColor: Theme.of(context).bottomNavigationBarTheme.unselectedItemColor ?? Colors.grey,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}