import 'dart:async';
import 'package:flutter/material.dart';
import 'onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const OnboardingScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF5D3FD3), // Deep purple color from the image
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 400,),
            Text(
              "Kutuku", // Changed to "Kutuku" as in the image
              style: TextStyle(
                fontSize: 32, // Adjusted font size
                fontWeight: FontWeight.bold,
                color: Colors.white, // White font color
              ),
            ),
            SizedBox(height: 8), // Add some spacing
            Text(
              "Any shopping just from home.", // Tagline from the image
              style: TextStyle(
                fontSize: 16,
                color: Colors.white70, // Slightly less opaque white for the tagline
              ),
            ),
            Spacer(), // Pushes the version text to the bottom
            Padding(
              padding: EdgeInsets.only(bottom: 20.0), // Padding from the bottom
              child: Text(
                "Version 0.0.1", // Version text from the image
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white54, // Less opaque white for the version
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}