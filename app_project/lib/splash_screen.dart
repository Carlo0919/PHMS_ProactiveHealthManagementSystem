import 'dart:async';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Move navigation into initState so it runs only once
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacementNamed(context, '/disclaimer');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // background color
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Your GIF
            SizedBox(
              width: 150,
              height: 150,
              child: Image.asset('assets/heart_animation.gif'), // <-- change the path
            ),
            const SizedBox(height: 20),
            // App Name
            const Text(
              'PHMS',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
