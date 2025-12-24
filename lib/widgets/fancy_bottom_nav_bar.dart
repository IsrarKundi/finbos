import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

class FancyBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTabChange;

  const FancyBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onTabChange,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: true,
      child: Container(
        margin: const EdgeInsets.fromLTRB(10, 0, 10, 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              blurRadius: 20,
              color: Colors.black.withOpacity(0.1),
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 7),
          child: GNav(
            rippleColor: Colors.blueAccent.withOpacity(0.1),
            hoverColor: Colors.blueAccent.withOpacity(0.05),
            gap: 6,
            activeColor: Colors.white,
            iconSize: 22,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            duration: const Duration(milliseconds: 500),
            tabBackgroundColor: const Color.fromARGB(255, 0, 199, 244),
            color: const Color.fromARGB(255, 0, 199, 244),
            tabBorderRadius: 30,
            tabs: const [
              GButton(icon: Icons.dashboard_rounded, text: 'Home'),
              GButton(icon: Icons.receipt_long_rounded, text: 'Transactions'),
              GButton(icon: Icons.psychology_rounded, text: 'AI'),
              GButton(icon: Icons.settings_rounded, text: 'Settings'),
            ],
            selectedIndex: selectedIndex,
            onTabChange: onTabChange,
          ),
        ),
      ),
    );
  }
}
