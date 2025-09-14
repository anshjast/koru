// lib/screens/meals_library_screen.dart
import 'package:flutter/material.dart';

class MealsLibraryScreen extends StatelessWidget {
  const MealsLibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('My Meals'),
        backgroundColor: Colors.black,
      ),
      body: const Center(child: Text('Meals Library UI will go here.')),
    );
  }
}