// lib/screens/train_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:koru/widgets/animated_emoji_button.dart';
import 'package:koru/widgets/animated_muscle_chip.dart';
import 'package:koru/widgets/gradient_button.dart';
import 'package:koru/widgets/gradient_card.dart';

class TrainScreen extends StatefulWidget {
  const TrainScreen({super.key});

  @override
  State<TrainScreen> createState() => _TrainScreenState();
}

class _TrainScreenState extends State<TrainScreen> {
  int? _energyLevel;
  final List<String> _selectedMuscleGroups = [];
  final List<String> _muscleGroups = [
    'Chest', 'Back', 'Legs', 'Arms', 'Biceps', 'Triceps', 'Shoulders', 'Core', 'Cardio'
  ];

  void _saveEnergyLevel() {
    if (_energyLevel != null) {
      final String todayId = DateFormat('yyyy-MM-dd').format(DateTime.now());
      FirebaseFirestore.instance.collection('dailyVitals').doc(todayId).set({
        'energyLevel': _energyLevel,
        'timestamp': Timestamp.now(),
      }, SetOptions(merge: true));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Energy level saved!')),
      );
    }
  }

  void _saveTrainedMuscles() {
    if (_selectedMuscleGroups.isNotEmpty) {
      final String todayId = DateFormat('yyyy-MM-dd').format(DateTime.now());
      FirebaseFirestore.instance.collection('dailyVitals').doc(todayId).set({
        'trainedMuscles': _selectedMuscleGroups,
        'lastTrainedTimestamp': Timestamp.now(),
      }, SetOptions(merge: true));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Trained muscles logged!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Train'),
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          GradientCard(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const Text("Morning Check-in", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text('How is your energy level today?'),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildEmoji(1, '😞'),
                      _buildEmoji(2, '😐'),
                      _buildEmoji(3, '🙂'),
                      _buildEmoji(4, '😊'),
                      _buildEmoji(5, '🤩'),
                    ],
                  ),
                  const SizedBox(height: 20),
                  GradientButton(
                    text: 'Save Energy Level',
                    onPressed: _energyLevel == null ? null : _saveEnergyLevel,
                  )
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          GradientCard(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const Text("Log Today's Training", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text('What muscle group(s) did you train today?'),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 8.0,
                    alignment: WrapAlignment.center,
                    children: _muscleGroups.map((muscle) {
                      return AnimatedMuscleChip(
                        label: muscle,
                        isSelected: _selectedMuscleGroups.contains(muscle),
                        onSelected: (bool selected) {
                          setState(() {
                            if (selected) {
                              _selectedMuscleGroups.add(muscle);
                            } else {
                              _selectedMuscleGroups.remove(muscle);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  GradientButton(
                    text: 'Log Trained Muscles',
                    onPressed: _selectedMuscleGroups.isEmpty ? null : _saveTrainedMuscles,
                  )
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          GradientCard(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Column(
                children: [
                  const Text("Tracking & Vitals", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ListTile(
                    leading: const Icon(Icons.directions_walk),
                    title: const Text('Steps Today'),
                    subtitle: const Text('Google Fit not yet connected'),
                    onTap: () {},
                  ),
                  ListTile(
                    leading: const Icon(Icons.monitor_weight),
                    title: const Text('Body Measurements'),
                    subtitle: const Text('Log your weight, etc.'),
                    trailing: const Icon(Icons.add),
                    onTap: () {
                      print('Log body measurements tapped!');
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // This helper method is now correctly inside the class
  Widget _buildEmoji(int value, String emoji) {
    return AnimatedEmojiButton(
      emoji: emoji,
      isSelected: _energyLevel == value,
      onTap: () {
        setState(() {
          _energyLevel = value;
        });
      },
    );
  }
} // <-- THIS WAS THE MISSING BRACE