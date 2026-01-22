import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:table_calendar/table_calendar.dart';

class AvoidScreen extends StatefulWidget {
  const AvoidScreen({super.key});

  @override
  State<AvoidScreen> createState() => _AvoidScreenState();
}

class _AvoidScreenState extends State<AvoidScreen> {
  final _avoidCollection = FirebaseFirestore.instance.collection('avoidHabits');

  final Color primaryAccent = Colors.redAccent;
  final Color obsidianBg = const Color(0xFF08080A);
  final Color glassBg = const Color(0xFF121214);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: obsidianBg,
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
                color: primaryAccent.withOpacity(0.08),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: _avoidCollection.snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const Center(
                          child: Text('NO PROTOCOLS DEFINED',
                              style: TextStyle(color: Colors.white10, fontWeight: FontWeight.w900, letterSpacing: 2)),
                        );
                      }

                      var habits = snapshot.data!.docs;

                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        itemCount: habits.length,
                        itemBuilder: (context, index) {
                          var habit = habits[index];
                          String habitText = habit['text'];
                          List<DateTime> successDays = (habit['successDays'] as List<dynamic>)
                              .map((ts) => (ts as Timestamp).toDate())
                              .toList();

                          return Container(
                            margin: const EdgeInsets.only(bottom: 24),
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: glassBg,
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(color: Colors.white.withOpacity(0.05)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(habitText.toUpperCase(),
                                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 1)),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.close_rounded, color: Colors.white10, size: 20),
                                      onPressed: () => _showDeleteConfirmation(habit.id),
                                    ),
                                  ],
                                ),
                                const Divider(height: 30, color: Colors.white10),
                                _buildCalendar(habit.id, successDays),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryAccent,
        onPressed: _showAddHabitDialog,
        child: const Icon(Icons.add_moderator_rounded, color: Colors.black),
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
              Text("RESTRICTION PROTOCOL", style: TextStyle(color: Colors.white38, fontSize: 11, letterSpacing: 1.5, fontWeight: FontWeight.w900)),
              Text("AVOIDANCE", style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
            ],
          ),
          const Spacer(),
          Icon(Icons.do_not_disturb_on_rounded, color: primaryAccent),
        ],
      ),
    );
  }

  Widget _buildCalendar(String docId, List<DateTime> successDays) {
    return TableCalendar(
      firstDay: DateTime.utc(2020, 1, 1),
      lastDay: DateTime.now().add(const Duration(days: 365)),
      focusedDay: DateTime.now(),
      calendarFormat: CalendarFormat.month,
      headerVisible: true,
      daysOfWeekHeight: 30,
      headerStyle: HeaderStyle(
        formatButtonVisible: false,
        titleCentered: true,
        titleTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        leftChevronIcon: Icon(Icons.chevron_left, color: primaryAccent),
        rightChevronIcon: Icon(Icons.chevron_right, color: primaryAccent),
      ),
      daysOfWeekStyle: const DaysOfWeekStyle(
        weekdayStyle: TextStyle(color: Colors.white24, fontSize: 12),
        weekendStyle: TextStyle(color: Colors.white24, fontSize: 12),
      ),
      calendarStyle: CalendarStyle(
        defaultTextStyle: const TextStyle(color: Colors.white),
        weekendTextStyle: const TextStyle(color: Colors.white),
        outsideDaysVisible: false,
        selectedDecoration: BoxDecoration(
          color: primaryAccent,
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: primaryAccent.withOpacity(0.5), blurRadius: 10)],
        ),
        todayDecoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          shape: BoxShape.circle,
        ),
      ),
      selectedDayPredicate: (day) => successDays.any((successDay) => isSameDay(successDay, day)),
      onDaySelected: (selectedDay, focusedDay) {
        final isAlreadySuccessful = successDays.any((d) => isSameDay(d, selectedDay));
        if (isAlreadySuccessful) {
          _avoidCollection.doc(docId).update({'successDays': FieldValue.arrayRemove([Timestamp.fromDate(selectedDay)])});
        } else {
          _avoidCollection.doc(docId).update({'successDays': FieldValue.arrayUnion([Timestamp.fromDate(selectedDay)])});
        }
      },
    );
  }

  void _showAddHabitDialog() {
    final textController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: glassBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28), side: BorderSide(color: primaryAccent.withOpacity(0.2))),
        title: const Text("NEW RESTRICTION", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16)),
        content: TextField(
          controller: textController,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: "e.g., Mindless scrolling",
            hintStyle: const TextStyle(color: Colors.white10),
            filled: true,
            fillColor: Colors.white.withOpacity(0.03),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCEL', style: TextStyle(color: Colors.white24))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: primaryAccent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            onPressed: () {
              if (textController.text.trim().isNotEmpty) {
                _avoidCollection.add({'text': textController.text.trim(), 'successDays': []});
                Navigator.pop(context);
              }
            },
            child: const Text('DEPLOY', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(String docId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: glassBg,
        title: const Text("REMOVE PROTOCOL?", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("CANCEL", style: TextStyle(color: Colors.white24))),
          TextButton(onPressed: () { _avoidCollection.doc(docId).delete(); Navigator.pop(context); },
              child: Text("DELETE", style: TextStyle(color: primaryAccent))),
        ],
      ),
    );
  }
}