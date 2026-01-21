import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:koru/screens/avoid_screen.dart';
import 'package:koru/screens/diet_screen.dart';
import 'package:koru/screens/goals_screen.dart';
import 'package:koru/screens/schedule_screen.dart';
import 'package:koru/screens/tasks_screen.dart';
import 'package:koru/screens/train_screen.dart';
import 'package:koru/widgets/glow_plus_button.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final List<Map<String, dynamic>> cards = [
    {"title": "Today's Focus", "icon": Icons.center_focus_strong, "gradient": [Colors.blue, Colors.purple]},
    {"title": "Train", "icon": Icons.fitness_center, "gradient": [Colors.teal, Colors.cyan]},
    {"title": "Goals", "icon": Icons.flag, "gradient": [Colors.deepPurple, Colors.pink]},
    {"title": "Diet", "icon": Icons.restaurant_menu, "gradient": [Colors.orange, Colors.red]},
    {"title": "Schedule", "icon": Icons.watch_later, "gradient": [Colors.indigo, Colors.cyan]},
    {"title": "Skills", "icon": Icons.construction, "gradient": [Colors.grey, Colors.blueGrey]},
    {"title": "Avoid", "icon": Icons.do_not_disturb_on, "gradient": [Colors.red, Colors.pink]},
    {"title": "Upgrade", "icon": Icons.spa, "gradient": [Colors.amber, Colors.red]},
  ];

  final CollectionReference _tasksCollection = FirebaseFirestore.instance.collection('tasks');
  final CollectionReference _historyCollection = FirebaseFirestore.instance.collection('taskHistory');

  void _navigateToScreen(String title) {
    Widget? screen;
    switch (title) {
      case 'Train': screen = const TrainScreen(); break;
      case 'Goals': screen = const GoalsScreen(); break;
      case 'Avoid': screen = const AvoidScreen(); break;
      case 'Diet': screen = const DietScreen(); break;
      case 'Schedule': screen = const ScheduleScreen(); break;
    }

    if (screen != null) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => screen!));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$title screen is not yet built.')),
      );
    }
  }

  void _showEditDialog(DocumentSnapshot task) {
    final TextEditingController editController = TextEditingController(text: task['name']);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text("Edit Task", style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: editController,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.red)),
            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              task.reference.update({'name': editController.text});
              Navigator.pop(context);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 40),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.red),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      "Koru",
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.settings, color: Colors.white),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 180,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemBuilder: (context, index) {
                  final card = cards[index];
                  return GestureDetector(
                    onTap: () => _navigateToScreen(card["title"]),
                    child: Container(
                      width: 150,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: List<Color>.from(card["gradient"])),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Container(
                        margin: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(9),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(card["icon"], color: Colors.white, size: 40),
                            const SizedBox(height: 12),
                            Text(
                              card["title"],
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 16),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
                separatorBuilder: (context, index) => const SizedBox(width: 12),
                itemCount: cards.length,
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _tasksCollection.orderBy('createdAt').snapshots(),
                builder: (context, taskSnapshot) {
                  if (!taskSnapshot.hasData) return const Center(child: CircularProgressIndicator());

                  final tasks = taskSnapshot.data!.docs;
                  final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

                  return SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        children: [
                          _buildProgressHeader(tasks, today),
                          const SizedBox(height: 16),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: tasks.length,
                            itemBuilder: (context, index) {
                              return _buildTaskItem(tasks[index], today);
                            },
                          ),
                          const SizedBox(height: 80),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.black,
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildBottomNavItem(icon: Icons.bar_chart, label: "Stats"),
              _buildBottomNavItem(icon: Icons.person, label: "Profile"),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: GlowPlusButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const TasksScreen()),
          );
        },
      ),
    );
  }

  Widget _buildProgressHeader(List<QueryDocumentSnapshot> tasks, String today) {
    return StreamBuilder<QuerySnapshot>(
      stream: _historyCollection
          .where('date', isEqualTo: today)
          .where('completed', isEqualTo: true)
          .snapshots(),
      builder: (context, historySnapshot) {
        int completedCount = historySnapshot.hasData ? historySnapshot.data!.docs.length : 0;
        double progress = tasks.isNotEmpty ? completedCount / tasks.length : 0;

        return Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Daily Progress", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                Text(
                  "$completedCount/${tasks.length} completed",
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey.shade800,
              color: Colors.green,
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTaskItem(DocumentSnapshot task, String today) {
    final taskData = task.data() as Map<String, dynamic>;
    final taskId = task.id;

    return StreamBuilder<QuerySnapshot>(
      stream: _historyCollection
          .where('taskId', isEqualTo: taskId)
          .where('date', isEqualTo: today)
          .limit(1)
          .snapshots(),
      builder: (context, historySnapshot) {
        bool isDone = false;
        DocumentSnapshot? historyDoc;
        if (historySnapshot.hasData && historySnapshot.data!.docs.isNotEmpty) {
          historyDoc = historySnapshot.data!.docs.first;
          isDone = (historyDoc.data() as Map<String, dynamic>)['completed'] ?? false;
        }

        return Container(
          margin: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: isDone ? Colors.green.withOpacity(0.1) : Colors.grey.shade900,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isDone ? Colors.green.withOpacity(0.3) : Colors.grey.shade700,
            ),
          ),
          child: ListTile(
            onTap: () {
              if (isDone && historyDoc != null) {
                historyDoc.reference.delete();
              } else {
                _historyCollection.add({
                  'taskId': taskId,
                  'date': today,
                  'completed': true,
                });
              }
            },
            onLongPress: () => _showEditDialog(task),
            leading: Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDone ? Colors.green : Colors.transparent,
                border: Border.all(color: isDone ? Colors.green : Colors.grey, width: 2),
              ),
              child: isDone ? const Icon(Icons.check, size: 14, color: Colors.black) : null,
            ),
            title: Text(
              taskData['name'] ?? 'Unnamed Task',
              style: TextStyle(
                color: isDone ? Colors.grey : Colors.white,
                decoration: isDone ? TextDecoration.lineThrough : null,
              ),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
              onPressed: () => _tasksCollection.doc(taskId).delete(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomNavItem({required IconData icon, required String label}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.grey),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }
}