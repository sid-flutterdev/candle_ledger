import 'package:candle_ledger/screen/signin_screen.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:get/get.dart';

class ScreenSplash extends StatefulWidget {
  const ScreenSplash({super.key});

  @override
  State<ScreenSplash> createState() => _ScreenSplashState();
}

class _ScreenSplashState extends State<ScreenSplash> {
  @override
  void initState() {
    super.initState();

    // Navigate after 2 seconds
    Timer(const Duration(seconds: 2), () {
      Get.offAll(() => ScreenSignIn()); // go to main screen
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0F1A),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 🔥 Logo (replace with your asset)
            Image.asset(
              'assets/logo.png', // add your logo here
              width: 120,
            ),

            const SizedBox(height: 20),

            // App Name
            const Text(
              "Candle Ledger",
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            // Subtitle
            const Text(
              "Track • Analyze • Grow",
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
