import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rxdart/rxdart.dart';
import 'package:confetti/confetti.dart';

class GoalsScreen extends StatefulWidget {
  const GoalsScreen({super.key});

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  final Color primaryAccent = Colors.purpleAccent;
  final Color obsidianBg = const Color(0xFF08080A);
  final Color glassBg = const Color(0xFF121214);

  late ConfettiController _confettiController;

  String? get currentUid => FirebaseAuth.instance.currentUser?.uid;

  CollectionReference get _ootyCollection => FirebaseFirestore.instance
      .collection('users')
      .doc(currentUid)
      .collection('ooty');

  CollectionReference get _dailyObjectives => FirebaseFirestore.instance
      .collection('users')
      .doc(currentUid)
      .collection('dailyObjectives');

  CollectionReference get _weeklyObjectives => FirebaseFirestore.instance
      .collection('users')
      .doc(currentUid)
      .collection('weeklyObjectives');

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 1));
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  void _confirmComplete(BuildContext context, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: glassBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28), side: BorderSide(color: primaryAccent.withOpacity(0.2))),
        title: const Text("MISSION COMPLETE?", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16)),
        content: const Text("Accomplishing this will update your mission power-bars.", style: TextStyle(color: Colors.white38, fontSize: 13)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("NOT YET", style: TextStyle(color: Colors.white24))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: primaryAccent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            onPressed: () { Navigator.pop(context); onConfirm(); },
            child: const Text("CONFIRM", style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: glassBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28), side: const BorderSide(color: Colors.redAccent, width: 0.5)),
        title: const Text("ABORT MISSION?", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w900, fontSize: 16)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("CANCEL", style: TextStyle(color: Colors.white24))),
          TextButton(onPressed: () { Navigator.pop(context); onConfirm(); }, child: const Text("DELETE", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w900))),
        ],
      ),
    );
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
      backgroundColor: obsidianBg,
      body: Stack(
        children: [
          Positioned(
            top: -100,
            right: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(shape: BoxShape.circle, color: primaryAccent.withOpacity(0.08)),
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              colors: [primaryAccent, Colors.white, Colors.deepPurple],
            ),
          ),
          SafeArea(
            child: StreamBuilder<List<QuerySnapshot>>(
              stream: CombineLatestStream.list([
                _dailyObjectives.snapshots(),
                _weeklyObjectives.snapshots(),
              ]),
              builder: (context, snapshot) {
                double dailyProgress = 0;
                double weeklyProgress = 0;

                if (snapshot.hasData) {
                  var dailyDocs = snapshot.data![0].docs;
                  var weeklyDocs = snapshot.data![1].docs;

                  if (dailyDocs.isNotEmpty) {
                    dailyProgress = dailyDocs.where((d) => d['isDone'] == true).length / dailyDocs.length;
                  }
                  if (weeklyDocs.isNotEmpty) {
                    weeklyProgress = weeklyDocs.where((d) => d['isDone'] == true).length / weeklyDocs.length;
                  }
                }

                return Column(
                  children: [
                    _buildDualPowerHeader(dailyProgress, weeklyProgress),
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        children: [
                          _buildOotySection(),
                          const SizedBox(height: 32),
                          _buildObjectiveSection(title: "DAILY MISSIONS", collection: _dailyObjectives, isDaily: true),
                          const SizedBox(height: 32),
                          _buildObjectiveSection(title: "WEEKLY MISSIONS", collection: _weeklyObjectives, isDaily: false),
                          const SizedBox(height: 100),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryAccent,
        onPressed: _showAddObjectiveChoiceDialog,
        child: const Icon(Icons.add_rounded, color: Colors.black, size: 32),
      ),
    );
  }

  Widget _buildDualPowerHeader(double daily, double weekly) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 25, 24, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("GOALS HUB", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
              Icon(Icons.bolt_rounded, color: primaryAccent),
            ],
          ),
          const SizedBox(height: 20),
          _buildMiniProgressBar("DAILY LOAD", daily),
          const SizedBox(height: 12),
          _buildMiniProgressBar("WEEKLY LOAD", weekly),
        ],
      ),
    );
  }

  Widget _buildMiniProgressBar(String label, double progress) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(color: Colors.white24, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1)),
            Text("${(progress * 100).toInt()}%", style: TextStyle(color: primaryAccent, fontSize: 9, fontWeight: FontWeight.w900)),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          height: 4,
          width: double.infinity,
          decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(10)),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: progress,
            child: Container(
              decoration: BoxDecoration(
                color: primaryAccent,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [BoxShadow(color: primaryAccent.withOpacity(0.3), blurRadius: 8, spreadRadius: 1)],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOotySection() {
    return StreamBuilder<DocumentSnapshot>(
      stream: _ootyCollection.doc('main').snapshots(),
      builder: (context, snapshot) {
        bool exists = snapshot.hasData && snapshot.data!.exists;
        var data = exists ? snapshot.data!.data() as Map<String, dynamic> : {};
        String ootyText = data['text'] ?? "NO PRIMARY OBJECTIVE DEPLOYED";
        if (data['isDone'] ?? false) return const SizedBox.shrink();

        return _buildGlassContainer(
          title: "ONE OBJECTIVE THIS YEAR",
          accent: primaryAccent,
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(ootyText.toUpperCase(), style: TextStyle(color: exists ? Colors.white : Colors.white10, fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 0.5)),
            trailing: exists ? _buildActionButtons(
              onDone: () => _confirmComplete(context, () {
                _ootyCollection.doc('main').set({'isDone': true}, SetOptions(merge: true));
                _confettiController.play();
              }),
              onDelete: () => _confirmDelete(context, () => _ootyCollection.doc('main').delete()),
            ) : Icon(Icons.add_moderator_rounded, color: primaryAccent.withOpacity(0.2)),
            onTap: () => _showGoalDialog(collection: _ootyCollection, isOoty: true, docId: 'main', currentText: exists ? ootyText : null),
          ),
        );
      },
    );
  }

  Widget _buildObjectiveSection({required String title, required CollectionReference collection, required bool isDaily}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(color: Colors.white24, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 2)),
        const SizedBox(height: 16),
        StreamBuilder<QuerySnapshot>(
          stream: collection.where('isDone', isEqualTo: false).orderBy('timestamp').snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return const SizedBox.shrink();
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                var doc = snapshot.data!.docs[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  decoration: BoxDecoration(color: glassBg, borderRadius: BorderRadius.circular(22), border: Border.all(color: Colors.white.withOpacity(0.05))),
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(isDaily ? Icons.today : Icons.view_week, color: primaryAccent.withOpacity(0.3), size: 18),
                    title: Text(doc['text'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                    trailing: _buildActionButtons(
                      onDone: () => _confirmComplete(context, () {
                        collection.doc(doc.id).update({'isDone': true});
                        _confettiController.play();
                      }),
                      onDelete: () => _confirmDelete(context, () => collection.doc(doc.id).delete()),
                    ),
                    onTap: () => _showGoalDialog(collection: collection, docId: doc.id, currentText: doc['text']),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildActionButtons({required VoidCallback onDone, required VoidCallback onDelete}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(icon: Icon(Icons.check_circle_outline, color: primaryAccent.withOpacity(0.5)), onPressed: onDone, visualDensity: VisualDensity.compact),
        IconButton(icon: const Icon(Icons.delete_outline, color: Colors.white10), onPressed: onDelete, visualDensity: VisualDensity.compact),
      ],
    );
  }

  Widget _buildGlassContainer({required String title, required Color accent, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [accent.withOpacity(0.15), accent.withOpacity(0.02)]),
        border: Border.all(color: accent.withOpacity(0.2), width: 1.5),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: TextStyle(color: accent, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
        const SizedBox(height: 12),
        child,
      ]),
    );
  }

  void _showAddObjectiveChoiceDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: glassBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28), side: const BorderSide(color: Colors.white10)),
        title: const Text('NEW MISSION', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16)),
        actions: [
          TextButton(onPressed: () { Navigator.pop(context); _showGoalDialog(collection: _dailyObjectives); }, child: Text('DAILY', style: TextStyle(color: primaryAccent, fontWeight: FontWeight.w900))),
          ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: primaryAccent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), onPressed: () { Navigator.pop(context); _showGoalDialog(collection: _weeklyObjectives); }, child: const Text('WEEKLY', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900))),
        ],
      ),
    );
  }

  void _showGoalDialog({required CollectionReference collection, bool isOoty = false, String? docId, String? currentText}) {
    final textController = TextEditingController(text: currentText);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: glassBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28), side: BorderSide(color: primaryAccent.withOpacity(0.2))),
        title: Text(isOoty ? "SET OOTY" : "LOG MISSION", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16)),
        content: TextField(
          controller: textController,
          autofocus: true,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          decoration: InputDecoration(
            hintText: "Objective details...",
            hintStyle: const TextStyle(color: Colors.white10),
            filled: true,
            fillColor: Colors.white.withOpacity(0.03),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: const BorderSide(color: Colors.white10)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCEL', style: TextStyle(color: Colors.white24))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: primaryAccent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            onPressed: () {
              final String text = textController.text.trim();
              if (currentUid != null && text.isNotEmpty) {
                if (isOoty) {
                  collection.doc('main').set({'text': text, 'isDone': false, 'timestamp': Timestamp.now()}, SetOptions(merge: true));
                } else if (docId == null) {
                  collection.add({'text': text, 'isDone': false, 'timestamp': Timestamp.now()});
                } else {
                  collection.doc(docId).update({'text': text});
                }
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