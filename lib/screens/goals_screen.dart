import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/rxdart.dart';
import 'package:confetti/confetti.dart';

class GoalsScreen extends StatefulWidget {
  const GoalsScreen({super.key});

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  final _ootyCollection = FirebaseFirestore.instance.collection('ooty');
  final _monthlyObjectives = FirebaseFirestore.instance.collection('monthlyObjectives');
  final _weeklyObjectives = FirebaseFirestore.instance.collection('weeklyObjectives');

  final Color primaryAccent = Colors.purpleAccent;
  final Color obsidianBg = const Color(0xFF08080A);
  final Color glassBg = const Color(0xFF121214);

  late ConfettiController _confettiController;

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
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              colors: [primaryAccent, Colors.white, Colors.deepPurple],
              maxBlastForce: 20,
              minBlastForce: 5,
              emissionFrequency: 0.05,
              numberOfParticles: 20,
              gravity: 0.1,
            ),
          ),
          SafeArea(
            child: StreamBuilder<List<QuerySnapshot>>(
              stream: CombineLatestStream.list([
                _monthlyObjectives.snapshots(),
                _weeklyObjectives.snapshots(),
              ]),
              builder: (context, snapshot) {
                int totalActive = 0;
                int totalCompleted = 0;

                if (snapshot.hasData) {
                  for (var querySnap in snapshot.data!) {
                    for (var doc in querySnap.docs) {
                      if (doc['isDone'] == true) {
                        totalCompleted++;
                      } else {
                        totalActive++;
                      }
                    }
                  }
                }

                double progress = (totalActive + totalCompleted) == 0
                    ? 0
                    : totalCompleted / (totalActive + totalCompleted);

                return Column(
                  children: [
                    _buildPowerHeader(progress),
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        children: [
                          _buildOotySection(),
                          const SizedBox(height: 32),
                          _buildObjectiveSection(
                            title: "ACTIVE MISSIONS",
                            collection: _monthlyObjectives,
                            isMonthly: true,
                          ),
                          _buildObjectiveSection(
                            title: "",
                            collection: _weeklyObjectives,
                            isMonthly: false,
                          ),
                          const SizedBox(height: 32),
                          _buildHistorySection(),
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

  Widget _buildPowerHeader(double progress) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 25, 24, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("GOALS HUB",
                  style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
              Icon(Icons.bolt_rounded, color: primaryAccent),
            ],
          ),
          const SizedBox(height: 15),
          Container(
            height: 6,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(10),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress,
              child: Container(
                decoration: BoxDecoration(
                  color: primaryAccent,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(color: primaryAccent.withOpacity(0.5), blurRadius: 10, spreadRadius: 1),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOotySection() {
    return StreamBuilder<DocumentSnapshot>(
      stream: _ootyCollection.doc('main').snapshots(),
      builder: (context, snapshot) {
        bool exists = snapshot.hasData && snapshot.data!.exists;
        var data = exists ? snapshot.data!.data() as Map<String, dynamic> : {};
        String ootyText = data['text'] ?? "NO PRIMARY OBJECTIVE DEPLOYED";
        bool isDone = data['isDone'] ?? false;

        if (isDone) return const SizedBox.shrink();

        return _buildGlassContainer(
          title: "ONE OBJECTIVE THIS YEAR",
          accent: primaryAccent,
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(ootyText.toUpperCase(),
                style: TextStyle(
                    color: exists ? Colors.white : Colors.white10,
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                    letterSpacing: 0.5
                )),
            trailing: exists ? _buildActionButtons(
              onDone: () {
                _ootyCollection.doc('main').set({'isDone': true}, SetOptions(merge: true));
                _confettiController.play();
              },
              onDelete: () => _ootyCollection.doc('main').delete(),
            ) : Icon(Icons.add_moderator_rounded, color: primaryAccent.withOpacity(0.2)),
            onTap: () => _showGoalDialog(collection: _ootyCollection, isOoty: true, docId: 'main', currentText: exists ? ootyText : null),
          ),
        );
      },
    );
  }

  Widget _buildObjectiveSection({required String title, required CollectionReference collection, required bool isMonthly}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title.isNotEmpty) ...[
          Text(title, style: const TextStyle(color: Colors.white24, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 2)),
          const SizedBox(height: 16),
        ],
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
                  decoration: BoxDecoration(
                    color: glassBg,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: Colors.white.withOpacity(0.05)),
                  ),
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(isMonthly ? Icons.calendar_month : Icons.view_week, color: primaryAccent.withOpacity(0.3), size: 18),
                    title: Text(doc['text'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                    trailing: _buildActionButtons(
                      onDone: () {
                        collection.doc(doc.id).update({'isDone': true});
                        _confettiController.play();
                      },
                      onDelete: () => collection.doc(doc.id).delete(),
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
        IconButton(
          icon: Icon(Icons.check_circle_outline, color: primaryAccent.withOpacity(0.5)),
          onPressed: onDone,
          visualDensity: VisualDensity.compact,
        ),
        IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.white10),
          onPressed: onDelete,
          visualDensity: VisualDensity.compact,
        ),
      ],
    );
  }

  Widget _buildHistorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("COMPLETED MISSIONS", style: TextStyle(color: Colors.white10, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 2)),
        const SizedBox(height: 16),
        StreamBuilder<List<QuerySnapshot>>(
          stream: CombineLatestStream.list([
            _monthlyObjectives.where('isDone', isEqualTo: true).snapshots(),
            _weeklyObjectives.where('isDone', isEqualTo: true).snapshots(),
          ]),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const SizedBox.shrink();
            List<QueryDocumentSnapshot> allDone = [];
            for (var snap in snapshot.data!) {
              allDone.addAll(snap.docs);
            }
            if (allDone.isEmpty) return const SizedBox.shrink();

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: allDone.length,
              itemBuilder: (context, index) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.02),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    title: Text(allDone[index]['text'], style: const TextStyle(color: Colors.white24, decoration: TextDecoration.lineThrough, fontSize: 13)),
                    leading: const Icon(Icons.check_circle_outline, color: Colors.white10, size: 16),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildGlassContainer({required String title, required Color accent, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [accent.withOpacity(0.15), accent.withOpacity(0.02)],
        ),
        border: Border.all(color: accent.withOpacity(0.2), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(color: accent, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
          const SizedBox(height: 12),
          child,
        ],
      ),
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
          TextButton(
            onPressed: () { Navigator.pop(context); _showGoalDialog(collection: _weeklyObjectives); },
            child: Text('WEEKLY', style: TextStyle(color: primaryAccent, fontWeight: FontWeight.w900)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: primaryAccent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            onPressed: () { Navigator.pop(context); _showGoalDialog(collection: _monthlyObjectives); },
            child: const Text('MONTHLY', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900)),
          ),
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
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide(color: primaryAccent.withOpacity(0.5))),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCEL', style: TextStyle(color: Colors.white24))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: primaryAccent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            onPressed: () {
              final String text = textController.text.trim();
              if (text.isNotEmpty) {
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