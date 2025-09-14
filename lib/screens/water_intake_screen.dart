// lib/screens/water_intake_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:koru/screens/water_history_screen.dart'; // <-- Import the new screen
import 'package:liquid_progress_indicator_v2/liquid_progress_indicator.dart';

class WaterIntakeScreen extends StatefulWidget {
  const WaterIntakeScreen({super.key});

  @override
  State<WaterIntakeScreen> createState() => _WaterIntakeScreenState();
}

class _WaterIntakeScreenState extends State<WaterIntakeScreen> {
  final _waterLogCollection = FirebaseFirestore.instance.collection('waterLog');
  final int _dailyTarget = 2000;
  final int _drinkAmount = 250;

  void _addWaterEntry() {
    _waterLogCollection.add({
      'amount': _drinkAmount,
      'timestamp': Timestamp.now(),
    });
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final startOfToday = DateTime(now.year, now.month, now.day);
    final endOfToday = startOfToday.add(const Duration(days: 1));

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Water Intake'),
        backgroundColor: Colors.black,
        elevation: 0,
        // --- ADDED HISTORY BUTTON ---
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const WaterHistoryScreen()),
              );
            },
            tooltip: 'View History',
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _waterLogCollection
            .where('timestamp', isGreaterThanOrEqualTo: startOfToday)
            .where('timestamp', isLessThan: endOfToday)
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          int totalIntake = 0;
          if (snapshot.hasData) {
            for (var doc in snapshot.data!.docs) {
              totalIntake += (doc['amount'] as num).toInt();
            }
          }

          double progress = totalIntake / _dailyTarget;
          if (progress > 1.0) progress = 1.0;

          return Column(
            children: [
              Expanded(
                flex: 3,
                child: Center(
                  child: SizedBox(
                    width: 250,
                    height: 250,
                    child: LiquidCircularProgressIndicator(
                      value: progress,
                      valueColor: AlwaysStoppedAnimation(Colors.blue.shade300),
                      backgroundColor: Colors.grey[850],
                      borderColor: Colors.blue.shade800,
                      borderWidth: 5.0,
                      direction: Axis.vertical,
                      center: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '$totalIntake / $_dailyTarget ml',
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const Text(
                            'Daily Drink Target',
                            style: TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                child: IconButton(
                  icon: const Icon(Icons.local_drink, size: 50),
                  onPressed: _addWaterEntry,
                  tooltip: 'Add $_drinkAmount ml',
                ),
              ),
              const Text("Today's Records", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const Divider(indent: 32, endIndent: 32),
              Expanded(
                flex: 2,
                child: snapshot.hasData && snapshot.data!.docs.isNotEmpty
                    ? ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    var doc = snapshot.data!.docs[index];
                    var timestamp = (doc['timestamp'] as Timestamp).toDate();
                    var amount = doc['amount'];

                    return ListTile(
                      leading: const Icon(Icons.access_time),
                      title: Text(DateFormat.jm().format(timestamp)),
                      trailing: Text('$amount ml', style: const TextStyle(fontWeight: FontWeight.bold)),
                    );
                  },
                )
                    : const Center(child: Text('No water logged yet today.')),
              ),
            ],
          );
        },
      ),
    );
  }
}

