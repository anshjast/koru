import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:koru/widgets/gradient_card.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  final _checklistCollection = FirebaseFirestore.instance.collection('powerDownSequence');
  final _vitalsCollection = FirebaseFirestore.instance.collection('dailyVitals');
  final String _todayId = DateFormat('yyyy-MM-dd').format(DateTime.now());

  void _showAddTaskDialog() {
    final textController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Task'),
        content: TextField(
          controller: textController,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'e.g., "Tidy workspace"'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final String text = textController.text.trim();
              if (text.isNotEmpty) {
                _checklistCollection.add({'task': text, 'order': 99}); // Add with a high order number
              }
              Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Schedule'),
        backgroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddTaskDialog,
            tooltip: 'Add new task',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            GradientCard(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Text(
                      "Power Down Sequence",
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Your repeatable checklist to win the evening.',
                      textAlign: TextAlign.center,
                    ),
                    const Divider(height: 30),
                    _buildChecklist(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChecklist() {
    return StreamBuilder<DocumentSnapshot>(
      // Listen to today's document in dailyVitals to get completed tasks
      stream: _vitalsCollection.doc(_todayId).snapshots(),
      builder: (context, vitalsSnapshot) {
        final completedTasks = vitalsSnapshot.hasData && vitalsSnapshot.data!.exists
            ? List<String>.from((vitalsSnapshot.data!.data() as Map<String, dynamic>)['completedTasks'] ?? [])
            : <String>[];

        return StreamBuilder<QuerySnapshot>(
          // Listen to the tasks themselves in the powerDownSequence collection
          stream: _checklistCollection.orderBy('order').snapshots(),
          builder: (context, checklistSnapshot) {
            if (checklistSnapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            }
            if (!checklistSnapshot.hasData || checklistSnapshot.data!.docs.isEmpty) {
              return const Center(
                child: Text('No tasks yet. Tap the + icon to add one!'),
              );
            }

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: checklistSnapshot.data!.docs.length,
              itemBuilder: (context, index) {
                var doc = checklistSnapshot.data!.docs[index];
                String taskText = doc['task'];
                bool isChecked = completedTasks.contains(doc.id);

                return CheckboxListTile(
                  title: Text(taskText),
                  value: isChecked,
                  onChanged: (bool? value) {
                    if (value == true) {
                      // Add the task ID to the completed list for today
                      _vitalsCollection.doc(_todayId).set({
                        'completedTasks': FieldValue.arrayUnion([doc.id])
                      }, SetOptions(merge: true));
                    } else {
                      // Remove the task ID from the completed list
                      _vitalsCollection.doc(_todayId).set({
                        'completedTasks': FieldValue.arrayRemove([doc.id])
                      }, SetOptions(merge: true));
                    }
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}

