import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  final _checklistCollection = FirebaseFirestore.instance.collection('powerDownSequence');
  final _vitalsCollection = FirebaseFirestore.instance.collection('dailyVitals');
  final String _todayId = DateFormat('yyyy-MM-dd').format(DateTime.now());

  final Color primaryAccent = Colors.blueAccent;
  final Color obsidianBg = const Color(0xFF08080A);
  final Color glassBg = const Color(0xFF121214);

  Timer? _timer;
  String _timeRemaining = "00:00:00";
  double _dayProgress = 1.0;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final now = DateTime.now();
      final midnight = DateTime(now.year, now.month, now.day + 1);
      final totalSecondsInDay = 86400;

      final difference = midnight.difference(now);
      final secondsRemaining = difference.inSeconds;

      if (mounted) {
        setState(() {
          _timeRemaining = _formatDuration(difference);
          _dayProgress = secondsRemaining / totalSecondsInDay;
        });
      }
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String hours = twoDigits(duration.inHours);
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    String seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$hours:$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: obsidianBg,
      body: Stack(
        children: [
          Positioned(
            top: -100,
            left: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: primaryAccent.withOpacity(0.08),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    children: [
                      _buildCountdownCard(),
                      const SizedBox(height: 32),
                      const Text("TERMINAL CHECKLIST",
                          style: TextStyle(color: Colors.white24, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 2)),
                      const SizedBox(height: 16),
                      _buildChecklist(),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryAccent,
        onPressed: _showAddTaskDialog,
        child: const Icon(Icons.add_task_rounded, color: Colors.black),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 25),
      child: Row(
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("SYSTEM ROUTINE", style: TextStyle(color: Colors.white38, fontSize: 11, letterSpacing: 1.5, fontWeight: FontWeight.w900)),
              Text("POWER DOWN", style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
            ],
          ),
          const Spacer(),
          Icon(Icons.settings_power_rounded, color: primaryAccent),
        ],
      ),
    );
  }

  Widget _buildCountdownCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        color: glassBg,
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("TIME UNTIL SYSTEM RESET", style: TextStyle(color: primaryAccent, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
          const SizedBox(height: 16),
          Text(_timeRemaining,
              style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold, letterSpacing: 4, fontFamily: 'monospace')),
          const SizedBox(height: 20),
          Container(
            height: 4,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(10),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: _dayProgress.clamp(0.0, 1.0),
              child: Container(
                decoration: BoxDecoration(
                  color: primaryAccent,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(color: primaryAccent.withOpacity(0.4), blurRadius: 10, spreadRadius: 1),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Text("DEPLETING DAILY RESOURCE...",
              style: TextStyle(color: Colors.white10, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
        ],
      ),
    );
  }

  Widget _buildChecklist() {
    return StreamBuilder<DocumentSnapshot>(
      stream: _vitalsCollection.doc(_todayId).snapshots(),
      builder: (context, vitalsSnapshot) {
        final completedTasks = vitalsSnapshot.hasData && vitalsSnapshot.data!.exists
            ? List<String>.from((vitalsSnapshot.data!.data() as Map<String, dynamic>)['completedTasks'] ?? [])
            : <String>[];

        return StreamBuilder<QuerySnapshot>(
          stream: _checklistCollection.orderBy('order').snapshots(),
          builder: (context, checklistSnapshot) {
            if (!checklistSnapshot.hasData || checklistSnapshot.data!.docs.isEmpty) {
              return const Center(child: Text("NO ROUTINE CONFIGURED", style: TextStyle(color: Colors.white10, fontWeight: FontWeight.bold)));
            }

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: checklistSnapshot.data!.docs.length,
              itemBuilder: (context, index) {
                var doc = checklistSnapshot.data!.docs[index];
                bool isChecked = completedTasks.contains(doc.id);

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: glassBg,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: isChecked ? primaryAccent.withOpacity(0.3) : Colors.white.withOpacity(0.05)),
                  ),
                  child: CheckboxListTile(
                    activeColor: primaryAccent,
                    checkColor: Colors.black,
                    title: Text(doc['task'],
                        style: TextStyle(color: isChecked ? Colors.white38 : Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                    value: isChecked,
                    onChanged: (bool? value) {
                      if (value == true) {
                        _vitalsCollection.doc(_todayId).set({'completedTasks': FieldValue.arrayUnion([doc.id])}, SetOptions(merge: true));
                      } else {
                        _vitalsCollection.doc(_todayId).set({'completedTasks': FieldValue.arrayRemove([doc.id])}, SetOptions(merge: true));
                      }
                    },
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  void _showAddTaskDialog() {
    final textController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: glassBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28), side: BorderSide(color: primaryAccent.withOpacity(0.2))),
        title: const Text('ADD ROUTINE STEP', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16)),
        content: TextField(
          controller: textController,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: "Enter task name...",
            hintStyle: const TextStyle(color: Colors.white10),
            filled: true,
            fillColor: Colors.white.withOpacity(0.03),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('ABORT', style: TextStyle(color: Colors.white24))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: primaryAccent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            onPressed: () {
              if (textController.text.isNotEmpty) {
                _checklistCollection.add({'task': textController.text.trim(), 'order': 99});
                Navigator.pop(context);
              }
            },
            child: const Text('DEPLOY', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );
  }
}