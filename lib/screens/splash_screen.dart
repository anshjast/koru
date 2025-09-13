import 'dart:async'; // FIX #1: Was 'dart.async', now 'dart:async'
import 'package:flutter/material.dart';
import 'package:koru/screens/big_3_entry_screen.dart'; // FIX #2: Added this missing import

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
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const Big3EntryScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Koru',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 20),
            CircularProgressIndicator(
              color: Theme.of(context).primaryColor,
            ),
          ],
        ),
      ),
    );
  }
}