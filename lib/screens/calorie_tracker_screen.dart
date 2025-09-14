// lib/screens/calorie_tracker_screen.dart
import 'package:flutter/material.dart';

class CalorieTrackerScreen extends StatelessWidget {
  const CalorieTrackerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Daily Calorie Measurer'),
        backgroundColor: Colors.black,
      ),
      body: const Center(child: Text('Calorie Tracker UI will go here.')),
    );
  }
}