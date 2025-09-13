// lib/screens/big_3_entry_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:koru/screens/dashboard_screen.dart';

// Ensure the class name here is spelled exactly like this
class Big3EntryScreen extends StatefulWidget {
  const Big3EntryScreen({super.key});

  @override
  State<Big3EntryScreen> createState() => _Big3EntryScreenState();
}

class _Big3EntryScreenState extends State<Big3EntryScreen> {
  final _priority1Controller = TextEditingController();
  final _priority2Controller = TextEditingController();
  final _priority3Controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Set Your Intention'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'What are your three main priorities for today?',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _priority1Controller,
                decoration: const InputDecoration(labelText: 'Priority 1'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _priority2Controller,
                decoration: const InputDecoration(labelText: 'Priority 2'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _priority3Controller,
                decoration: const InputDecoration(labelText: 'Priority 3'),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _savePrioritiesAndNavigate,
                child: const Text('Begin Today'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _savePrioritiesAndNavigate() {
    final String priority1 = _priority1Controller.text;
    final String priority2 = _priority2Controller.text;
    final String priority3 = _priority3Controller.text;

    if (priority1.isNotEmpty || priority2.isNotEmpty || priority3.isNotEmpty) {
      FirebaseFirestore.instance.collection('big3').add({
        'priority1': priority1,
        'priority2': priority2,
        'priority3': priority3,
        'timestamp': Timestamp.now(),
      });

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const DashboardScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please set at least one priority.')),
      );
    }
  }
}