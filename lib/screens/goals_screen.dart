// lib/screens/goals_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:koru/widgets/gradient_card.dart';
import 'package:koru/widgets/confirm_action_toggle.dart';

class GoalsScreen extends StatefulWidget {
  const GoalsScreen({super.key});

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  // Firestore collections for each goal type
  final _ootyCollection = FirebaseFirestore.instance.collection('ooty');
  final _monthlyObjectives = FirebaseFirestore.instance.collection('monthlyObjectives');
  final _weeklyObjectives = FirebaseFirestore.instance.collection('weeklyObjectives');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Goals'),
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildOotySection(),
          const Divider(height: 40),
          _buildObjectiveSection(
            title: "Monthly Objectives",
            collection: _monthlyObjectives,
          ),
          const Divider(height: 40),
          _buildObjectiveSection(
            title: "Weekly Objectives",
            collection: _weeklyObjectives,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddObjectiveChoiceDialog,
        child: const Icon(Icons.add),
        tooltip: 'Add Objective',
      ),
    );
  }

  // Widget to build the OOTY section
  Widget _buildOotySection() {
    return StreamBuilder<DocumentSnapshot>(
      stream: _ootyCollection.doc('main').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || !snapshot.data!.exists) {
          // Display a prompt if the OOTY hasn't been set yet
          return GradientCard(
            child: ListTile(
              title: const Text('OOTY', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text("Tap to set your One Objective This Year..."),
              onTap: () => _showGoalDialog(collection: _ootyCollection, isOoty: true),
            ),
          );
        }

        var data = snapshot.data!.data() as Map<String, dynamic>;
        String ootyText = data['text'] ?? "No text found.";
        bool isDone = data['isDone'] ?? false;

        // If the OOTY is marked as done, don't show it
        if (isDone) {
          return const SizedBox.shrink(); // Return an empty widget
        }

        return GradientCard(
          child: ListTile(
            title: const Text('OOTY', style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(ootyText),
            trailing: ConfirmActionToggle(
              onDoneConfirmed: () => _ootyCollection.doc('main').set({'isDone': true}, SetOptions(merge: true)),
              onDeleteConfirmed: () => _ootyCollection.doc('main').delete(),
            ),
            onTap: () => _showGoalDialog(collection: _ootyCollection, isOoty: true, docId: 'main', currentText: ootyText),
          ),
        );
      },
    );
  }

  // A reusable widget to build the monthly and weekly objective lists
  Widget _buildObjectiveSection({required String title, required CollectionReference collection}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        StreamBuilder<QuerySnapshot>(
          // Query filters out any objectives already marked as 'done'
          stream: collection.where('isDone', isEqualTo: false).orderBy('timestamp').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Card(
                  child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Center(child: Text('No active objectives. Add one!'))));
            }
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                var doc = snapshot.data!.docs[index];
                String text = doc['text'];

                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    title: Text(text),
                    trailing: ConfirmActionToggle(
                      onDoneConfirmed: () => collection.doc(doc.id).update({'isDone': true}),
                      onDeleteConfirmed: () => collection.doc(doc.id).delete(),
                    ),
                    onTap: () => _showGoalDialog(collection: collection, docId: doc.id, currentText: text),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }

  // Dialog to choose between adding a weekly or monthly objective
  void _showAddObjectiveChoiceDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Objective'),
        content: const Text('Which type of objective would you like to add?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showGoalDialog(collection: _weeklyObjectives);
            },
            child: const Text('Weekly'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showGoalDialog(collection: _monthlyObjectives);
            },
            child: const Text('Monthly'),
          ),
        ],
      ),
    );
  }

  // A reusable dialog for adding or editing any goal
  void _showGoalDialog({required CollectionReference collection, bool isOoty = false, String? docId, String? currentText}) {
    final textController = TextEditingController(text: currentText);
    String title = isOoty ? "Set Your OOTY" : (docId == null ? "Add Objective" : "Edit Objective");

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: textController,
          autofocus: true,
          decoration: const InputDecoration(hintText: "Enter your goal..."),
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
                if (isOoty) {
                  collection.doc('main').set({'text': text, 'isDone': false}, SetOptions(merge: true));
                } else if (docId == null) {
                  collection.add({'text': text, 'isDone': false, 'timestamp': Timestamp.now()});
                } else {
                  collection.doc(docId).update({'text': text});
                }
                Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
