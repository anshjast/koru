// lib/screens/calorie_tracker_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:koru/widgets/calorie_dialog.dart'; // <-- Import the new reusable dialog

class CalorieTrackerScreen extends StatefulWidget {
  const CalorieTrackerScreen({super.key});

  @override
  State<CalorieTrackerScreen> createState() => _CalorieTrackerScreenState();
}

class _CalorieTrackerScreenState extends State<CalorieTrackerScreen> {
  final _calorieLogCollection = FirebaseFirestore.instance.collection('calorieLog');

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final startOfToday = DateTime(now.year, now.month, now.day);
    final endOfToday = startOfToday.add(const Duration(days: 1));

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Daily Calories'),
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _calorieLogCollection
            .where('timestamp', isGreaterThanOrEqualTo: startOfToday)
            .where('timestamp', isLessThan: endOfToday)
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'No calories logged for today.\nTap the + button to add an entry!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          int totalCalories = 0;
          for (var doc in snapshot.data!.docs) {
            totalCalories += (doc['calories'] as num).toInt();
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Text(
                      'Total for Today',
                      style: TextStyle(fontSize: 18, color: Colors.white70),
                    ),
                    Text(
                      '$totalCalories kcal',
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(),
              Expanded(
                child: ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    var doc = snapshot.data!.docs[index];
                    var data = doc.data() as Map<String, dynamic>;

                    return ListTile(
                      title: Text(data['item']),
                      trailing: Text('${data['calories']} kcal'),
                      onTap: () => showCalorieDialog(context: context, doc: doc),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showCalorieDialog(context: context),
        child: const Icon(Icons.add),
        tooltip: 'Add Entry',
      ),
    );
  }
}

