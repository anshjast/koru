import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:koru/screens/avoid_screen.dart';
import 'package:koru/screens/diet_screen.dart';
import 'package:koru/screens/goals_screen.dart';
import 'package:koru/screens/schedule_screen.dart';
import 'package:koru/screens/skills_screen.dart';
import 'package:koru/screens/tasks_screen.dart';
import 'package:koru/screens/train_screen.dart';
import 'package:koru/widgets/glow_plus_button.dart';
import 'package:koru/screens/stats_screen.dart';
import 'package:koru/screens/account_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final List<Map<String, dynamic>> cards = [
    {"title": "TRAIN", "icon": Icons.fitness_center, "color": const Color(0xFF03DAC6)},
    {"title": "GOALS", "icon": Icons.flag, "color": Colors.purpleAccent},
    {"title": "DIET", "icon": Icons.restaurant_menu, "color": Colors.orangeAccent},
    {"title": "SCHEDULE", "icon": Icons.watch_later, "color": Colors.blueAccent},
    {"title": "SKILLS", "icon": Icons.construction, "color": Colors.amberAccent},
    {"title": "AVOID", "icon": Icons.do_not_disturb_on, "color": Colors.redAccent},
  ];

  String? get currentUid => FirebaseAuth.instance.currentUser?.uid;

  CollectionReference get _tasksCollection => FirebaseFirestore.instance
      .collection('users')
      .doc(currentUid)
      .collection('tasks');

  CollectionReference get _historyCollection => FirebaseFirestore.instance
      .collection('users')
      .doc(currentUid)
      .collection('taskHistory');

  void _navigateToScreen(String title) {
    Widget? screen;
    switch (title) {
      case 'TRAIN': screen = const TrainScreen(); break;
      case 'GOALS': screen = const GoalsScreen(); break;
      case 'AVOID': screen = const AvoidScreen(); break;
      case 'DIET': screen = const DietScreen(); break;
      case 'SCHEDULE': screen = const ScheduleScreen(); break;
      case 'SKILLS': screen = const SkillsScreen(); break;
    }
    if (screen != null) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => screen!));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (currentUid == null) {
      return const Scaffold(
        backgroundColor: Color(0xFF08080A),
        body: Center(child: Text("ACCESS DENIED: PLEASE LOGIN", style: TextStyle(color: Colors.white24))),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF08080A),
      body: Stack(
        children: [
          Positioned(
            top: -100,
            right: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFBB86FC).withOpacity(0.08),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                const SizedBox(height: 20),
                _buildModernCardList(),
                const SizedBox(height: 30),
                Expanded(child: _buildScrollableContent()),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: GlowPlusButton(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const TasksScreen())),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance.collection('users').doc(currentUid).snapshots(),
            builder: (context, snapshot) {
              String name = "USER";
              if (snapshot.hasData && snapshot.data!.exists) {
                var data = snapshot.data!.data() as Map<String, dynamic>;
                name = data['name'] ?? "USER";
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Welcome back,", style: TextStyle(color: Colors.white38, fontSize: 13)),
                  Text(name.toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: 2)),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildModernCardList() {
    return SizedBox(
      height: 165,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemCount: cards.length,
        separatorBuilder: (context, index) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          final card = cards[index];
          final color = card["color"] as Color;
          return GestureDetector(
            onTap: () => _navigateToScreen(card["title"]),
            child: Container(
              width: 135,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [color.withOpacity(0.15), color.withOpacity(0.02)],
                ),
                border: Border.all(color: color.withOpacity(0.25), width: 1.5),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(card["icon"], color: color, size: 34),
                  const SizedBox(height: 14),
                  Text(card["title"], style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.2)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildScrollableContent() {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    return StreamBuilder<QuerySnapshot>(
      stream: _tasksCollection.orderBy('createdAt').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator(color: Color(0xFFBB86FC), strokeWidth: 2));
        final tasks = snapshot.data!.docs;

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProgressHeader(tasks, today),
              const SizedBox(height: 28),
              const Text("DAILY OBJECTIVES", style: TextStyle(color: Colors.white24, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
              const SizedBox(height: 16),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: tasks.length,
                itemBuilder: (context, index) => _buildNeonTaskItem(tasks[index], today),
              ),
              const SizedBox(height: 100),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProgressHeader(List<QueryDocumentSnapshot> tasks, String today) {
    return StreamBuilder<QuerySnapshot>(
      stream: _historyCollection.where('date', isEqualTo: today).where('completed', isEqualTo: true).snapshots(),
      builder: (context, historySnapshot) {
        int completedCount = historySnapshot.hasData ? historySnapshot.data!.docs.length : 0;
        double progress = tasks.isNotEmpty ? completedCount / tasks.length : 0;
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF0F0F12),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.white.withOpacity(0.04)),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Consistency Score", style: TextStyle(color: Colors.white70, fontSize: 15, fontWeight: FontWeight.w600)),
                  Text("${(progress * 100).toInt()}%", style: const TextStyle(color: Color(0xFFBB86FC), fontWeight: FontWeight.w900, fontSize: 18)),
                ],
              ),
              const SizedBox(height: 18),
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.white.withOpacity(0.05),
                  color: const Color(0xFFBB86FC),
                  minHeight: 10,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNeonTaskItem(DocumentSnapshot task, String today) {
    final taskData = task.data() as Map<String, dynamic>;
    final taskId = task.id;

    return StreamBuilder<QuerySnapshot>(
      stream: _historyCollection.where('taskId', isEqualTo: taskId).where('date', isEqualTo: today).limit(1).snapshots(),
      builder: (context, historySnapshot) {
        bool isDone = historySnapshot.hasData && historySnapshot.data!.docs.isNotEmpty;
        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          decoration: BoxDecoration(
            color: const Color(0xFF0F0F12),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: isDone ? const Color(0xFFBB86FC).withOpacity(0.4) : Colors.white.withOpacity(0.05)),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            onTap: () {
              if (isDone) {
                historySnapshot.data!.docs.first.reference.delete();
              } else {
                _historyCollection.add({'taskId': taskId, 'date': today, 'completed': true});
              }
            },
            leading: Icon(isDone ? Icons.check_circle_rounded : Icons.radio_button_off_rounded, color: isDone ? const Color(0xFFBB86FC) : Colors.white24, size: 26),
            title: Text(
              taskData['name'] ?? '',
              style: TextStyle(color: isDone ? Colors.white38 : Colors.white, fontSize: 15, decoration: isDone ? TextDecoration.lineThrough : null),
            ),
            trailing: IconButton(icon: const Icon(Icons.close_rounded, color: Colors.white10, size: 20), onPressed: () => _tasksCollection.doc(taskId).delete()),
          ),
        );
      },
    );
  }

  Widget _buildBottomBar() {
    return Container(
      height: 95,
      decoration: const BoxDecoration(
        color: Color(0xFF08080A),
        border: Border(top: BorderSide(color: Colors.white10, width: 0.8)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildBottomNavItem(
            icon: Icons.bar_chart_rounded,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const StatsScreen())),
          ),
          const SizedBox(width: 48),
          _buildBottomNavItem(
            icon: Icons.person_outline_rounded,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AccountScreen())),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavItem({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Icon(icon, color: Colors.white24, size: 30),
    );
  }
}