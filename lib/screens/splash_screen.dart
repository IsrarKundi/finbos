import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../controllers/splash_controller.dart';
import 'webview_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final SplashController _controller = SplashController();

  @override
  void initState() {
    super.initState();
    
    // Set status bar style for cyan splash screen
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Color(0xFF4DDAFA), // Match splash cyan color
        statusBarIconBrightness: Brightness.dark, // Dark icons on light background
        statusBarBrightness: Brightness.light,
      ),
    );
    
    _navigateToHome();
  }

  void _navigateToHome() {
    _controller.navigateAfterDelay(() {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const WebViewScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Top 60% with cyan color
          Expanded(
            flex: 70,
            child: Container(
              width: double.infinity,
              color: const Color(0xFF4DDAFA),
              child: const Center(
                child: Text(
                  'Finbos',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    letterSpacing: 2,
                  ),
                ),
              ),
            ),
          ),
          // Bottom 40% with black color
          Expanded(
            flex: 30,
            child: Container(
              width: double.infinity,
              color: Colors.black,
              child: const Center(
                child: Text(
                  'Finance with AI',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
