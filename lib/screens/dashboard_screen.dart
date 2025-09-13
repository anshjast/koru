import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // This stream gets the latest Big 3 entry
    final Stream<QuerySnapshot> prioritiesStream = FirebaseFirestore.instance
        .collection('big3')
        .orderBy('timestamp', descending: true)
        .limit(1) // We only want the most recent one
        .snapshots();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Koru Dashboard'),
        centerTitle: true,
      ),
      body: ListView( // Use a ListView for future scrolling
        padding: const EdgeInsets.all(16.0),
        children: [
          // Widget to display Today's Focus
          const Text(
            "Today's Focus",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          StreamBuilder<QuerySnapshot>(
            stream: prioritiesStream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Text('No priorities found.');
              }

              var latestEntry = snapshot.data!.docs.first;
              String p1 = latestEntry['priority1'];
              String p2 = latestEntry['priority2'];
              String p3 = latestEntry['priority3'];

              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (p1.isNotEmpty) Text('1. $p1', style: const TextStyle(fontSize: 16)),
                      if (p2.isNotEmpty) const SizedBox(height: 8),
                      if (p2.isNotEmpty) Text('2. $p2', style: const TextStyle(fontSize: 16)),
                      if (p3.isNotEmpty) const SizedBox(height: 8),
                      if (p3.isNotEmpty) Text('3. $p3', style: const TextStyle(fontSize: 16)),
                    ],
                  ),
                ),
              );
            },
          ),

          // We will add the other module widgets here later
          const Divider(height: 40),
          const Center(child: Text('Other modules will go here...')),

        ],
      ),
    );
  }
}