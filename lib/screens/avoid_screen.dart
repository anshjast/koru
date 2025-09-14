import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:koru/widgets/gradient_card.dart';
import 'package:table_calendar/table_calendar.dart';

class AvoidScreen extends StatefulWidget {
  const AvoidScreen({super.key});

  @override
  State<AvoidScreen> createState() => _AvoidScreenState();
}

class _AvoidScreenState extends State<AvoidScreen> {
  final _avoidCollection = FirebaseFirestore.instance.collection('avoidHabits');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Avoid'),
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _avoidCollection.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'No habits to avoid yet.\nAdd one to get started!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18),
              ),
            );
          }

          var habits = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: habits.length,
            itemBuilder: (context, index) {
              var habit = habits[index];
              String habitText = habit['text'];
              List<DateTime> successDays = (habit['successDays'] as List<dynamic>)
                  .map((ts) => (ts as Timestamp).toDate())
                  .toList();

              return GradientCard(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      ListTile(
                        title: Text(habitText, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                          onPressed: () => _avoidCollection.doc(habit.id).delete(),
                        ),
                      ),
                      const SizedBox(height: 10),
                      _buildCalendar(habit.id, successDays),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddHabitDialog,
        child: const Icon(Icons.add),
        tooltip: 'Add Habit to Avoid',
      ),
    );
  }

  Widget _buildCalendar(String docId, List<DateTime> successDays) {
    return TableCalendar(
      firstDay: DateTime.utc(2020, 1, 1),
      lastDay: DateTime.now().add(const Duration(days: 365)),
      focusedDay: DateTime.now(),
      calendarFormat: CalendarFormat.month,
      headerStyle: const HeaderStyle(
        formatButtonVisible: false,
        titleCentered: true,
      ),
      calendarStyle: CalendarStyle(
        // Style for the successful days
        selectedDecoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          shape: BoxShape.circle,
        ),
        todayDecoration: BoxDecoration(
          color: Colors.grey[700],
          shape: BoxShape.circle,
        ),
      ),
      selectedDayPredicate: (day) {
        return successDays.any((successDay) => isSameDay(successDay, day));
      },
      onDaySelected: (selectedDay, focusedDay) {
        setState(() {
          final isAlreadySuccessful = successDays.any((d) => isSameDay(d, selectedDay));

          if (isAlreadySuccessful) {
            _avoidCollection.doc(docId).update({
              'successDays': FieldValue.arrayRemove([Timestamp.fromDate(selectedDay)])
            });
          } else {
            _avoidCollection.doc(docId).update({
              'successDays': FieldValue.arrayUnion([Timestamp.fromDate(selectedDay)])
            });
          }
        });
      },
    );
  }
  void _showAddHabitDialog() {
    final textController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Add Habit to Avoid"),
        content: TextField(
          controller: textController,
          autofocus: true,
          decoration: const InputDecoration(hintText: "e.g., Mindless scrolling"),
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
                _avoidCollection.add({
                  'text': text,
                  'successDays': [],
                });
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}
