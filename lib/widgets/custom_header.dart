// lib/widgets/custom_header.dart
import 'package:flutter/material.dart';

class CustomHeader extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton; // Flag to control back button visibility
  final List<Widget>? actions; // Optional actions (like in SongDetailScreen)

  const CustomHeader({
    Key? key,
    required this.title,
    this.showBackButton = false, // Default to false
    this.actions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Color darkBlue = Colors.indigo[900]!;
    // Check if theme is dark to adjust icon color if needed
    // final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    // final Color iconColor = isDarkMode ? Colors.white : Colors.white; // Keep white for dark blue bg

    return Container(
      decoration: BoxDecoration(
        color: darkBlue,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 2, blurRadius: 5, offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 10, // Status bar padding + extra
        bottom: 20.0,
        // Adjust horizontal padding based on presence of buttons
        left: showBackButton ? 8.0 : 16.0,
        right: (actions != null && actions!.isNotEmpty) ? 8.0 : 16.0,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Title (adjust padding if both buttons are present)
          Center(
            child: Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: (showBackButton && (actions != null && actions!.isNotEmpty))
                               ? 45.0 // More padding if back and actions exist
                               : (showBackButton || (actions != null && actions!.isNotEmpty))
                                 ? 45.0 // Padding if only one side has button(s)
                                 : 0   // No padding if title is alone
              ),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
          // Back Button (if enabled)
          if (showBackButton)
            Positioned(
              left: 0,
              top: 0, // Align to top within padding area
              bottom: 0,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white), // White icon
                tooltip: 'Back',
                onPressed: () {
                  // Standard back navigation action
                  Navigator.maybePop(context);
                },
              ),
            ),
          // Actions (if enabled)
          if (actions != null && actions!.isNotEmpty)
            Positioned(
              right: 0,
              top: 0, // Align to top within padding area
              bottom: 0,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: actions!,
              ),
            ),
        ],
      ),
    );
  }

  // Estimate preferred size based on padding and typical AppBar height
  @override
  Size get preferredSize => const Size.fromHeight(50.0 + 20.0 + 10.0); // top_padding + bottom_padding + buffer
}