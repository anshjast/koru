// lib/screens/avoid_screen.dart

import 'package:flutter/material.dart';

class AvoidScreen extends StatelessWidget {
  const AvoidScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Avoid'),
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: const Center(
        child: Text('"Avoid" module UI will be built here.'),
      ),
    );
  }
}