// lib/screens/water_intake_screen.dart
import 'package:flutter/material.dart';

class WaterIntakeScreen extends StatelessWidget {
  const WaterIntakeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Water Intake'),
        backgroundColor: Colors.black,
      ),
      body: const Center(child: Text('Water Intake UI will go here.')),
    );
  }
}