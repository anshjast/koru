import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class CalorieTrackerScreen extends StatefulWidget {
  const CalorieTrackerScreen({super.key});

  @override
  State<CalorieTrackerScreen> createState() => _CalorieTrackerScreenState();
}

class _CalorieTrackerScreenState extends State<CalorieTrackerScreen> {
  final Color accentColor = const Color(0xFFFF9F0A);

  int dailyGoal = 2000;
  int proteinGoal = 150;
  int carbsGoal = 250;
  int fatsGoal = 70;

  String? get currentUid => FirebaseAuth.instance.currentUser?.uid;

  CollectionReference get _userDailyLog => FirebaseFirestore.instance
      .collection('users')
      .doc(currentUid)
      .collection('dailyLog');

  CollectionReference get _userMealLibrary => FirebaseFirestore.instance
      .collection('users')
      .doc(currentUid)
      .collection('meals');

  Future<void> _logToDailyIntake(Map<String, dynamic> meal) async {
    if (currentUid == null) return;
    await _userDailyLog.add({
      'name': meal['name'],
      'calories': (meal['calories'] as num? ?? 0).toInt(),
      'protein': (meal['protein'] as num? ?? 0).toInt(),
      'carbs': (meal['carbs'] as num? ?? 0).toInt(),
      'fats': (meal['fats'] as num? ?? 0).toInt(),
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  void _showLibraryPickDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0D0D0F),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (context) => StreamBuilder<QuerySnapshot>(
        stream: _userMealLibrary.orderBy('name').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator(color: Color(0xFFFF9F0A)));
          return ListView.builder(
            padding: const EdgeInsets.all(24),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final doc = snapshot.data!.docs[index];
              final meal = doc.data() as Map<String, dynamic>;
              return ListTile(
                onTap: () {
                  _logToDailyIntake(meal);
                  Navigator.pop(context);
                },
                title: Text(meal['name'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                subtitle: Text("${meal['calories']} kcal", style: const TextStyle(color: Colors.white38)),
                trailing: Icon(Icons.add_circle_outline, color: accentColor),
              );
            },
          );
        },
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

    final now = DateTime.now();
    final startOfToday = DateTime(now.year, now.month, now.day);

    return Scaffold(
      backgroundColor: const Color(0xFF08080A),
      floatingActionButton: FloatingActionButton(
        backgroundColor: accentColor,
        onPressed: _showLibraryPickDialog,
        child: const Icon(Icons.add, color: Colors.black),
      ),
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
                color: accentColor.withOpacity(0.08),
              ),
            ),
          ),
          SafeArea(
            child: StreamBuilder<QuerySnapshot>(
              stream: _userDailyLog
                  .where('timestamp', isGreaterThanOrEqualTo: startOfToday)
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                int totalKcal = 0;
                int totalPro = 0;
                int totalCarb = 0;
                int totalFat = 0;

                if (snapshot.hasData) {
                  for (var doc in snapshot.data!.docs) {
                    final data = doc.data() as Map<String, dynamic>;
                    totalKcal += (data['calories'] as num? ?? 0).toInt();
                    totalPro += (data['protein'] as num? ?? 0).toInt();
                    totalCarb += (data['carbs'] as num? ?? 0).toInt();
                    totalFat += (data['fats'] as num? ?? 0).toInt();
                  }
                }

                int remaining = dailyGoal - totalKcal;
                if (remaining < 0) remaining = 0;

                return Column(
                  children: [
                    _buildHeader(context),
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        children: [
                          _buildMainDonut(remaining, totalKcal),
                          const SizedBox(height: 32),
                          _buildQuickStats(totalKcal),
                          const SizedBox(height: 32),
                          _buildMacroSection(totalPro, totalCarb, totalFat),
                          const SizedBox(height: 32),
                          const Text("TODAY'S ENTRIES",
                              style: TextStyle(color: Colors.white38, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
                          const SizedBox(height: 16),
                          _buildDailyLogList(snapshot),
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
    );
  }

  Widget _buildDailyLogList(AsyncSnapshot<QuerySnapshot> snapshot) {
    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Text("No meals logged today", style: TextStyle(color: Colors.white12, fontSize: 13)),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: snapshot.data!.docs.length,
      itemBuilder: (context, index) {
        final doc = snapshot.data!.docs[index];
        final log = doc.data() as Map<String, dynamic>;

        return Dismissible(
          key: Key(doc.id),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            decoration: BoxDecoration(
              color: Colors.redAccent.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.delete_outline, color: Colors.redAccent),
          ),
          onDismissed: (direction) {
            _userDailyLog.doc(doc.id).delete();
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF121214),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.05)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(log['name'].toString().toUpperCase(),
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 0.5)),
                    const SizedBox(height: 4),
                    Text("${log['protein']}g P • ${log['carbs']}g C • ${log['fats']}g F",
                        style: const TextStyle(color: Colors.white24, fontSize: 11)),
                  ],
                ),
                Text("+${log['calories']} kcal",
                    style: TextStyle(color: accentColor, fontWeight: FontWeight.w900, fontSize: 14)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.05),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
                ),
              ),
              const SizedBox(width: 20),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("NUTRITION", style: TextStyle(color: Colors.white38, fontSize: 11, letterSpacing: 1.5, fontWeight: FontWeight.w900)),
                  Text("CALORIE LOG", style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
                ],
              ),
            ],
          ),
          IconButton(
            icon: Icon(Icons.tune_rounded, color: accentColor),
            onPressed: () => _showEditGoalsDialog(),
          ),
        ],
      ),
    );
  }

  void _showEditGoalsDialog() {
    final kcalController = TextEditingController(text: dailyGoal.toString());
    final proController = TextEditingController(text: proteinGoal.toString());
    final carbController = TextEditingController(text: carbsGoal.toString());
    final fatController = TextEditingController(text: fatsGoal.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0D0D0F),
        insetPadding: const EdgeInsets.symmetric(horizontal: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
          side: BorderSide(color: accentColor.withOpacity(0.3)),
        ),
        title: const Text("ADJUST TARGETS",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 2, fontSize: 16)),
        content: SizedBox(
          width: MediaQuery.of(context).size.width,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildEditField("Daily Calorie Goal", Icons.bolt_rounded, kcalController, accentColor),
                const SizedBox(height: 24),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text("MACRO TARGETS (g)",
                      style: TextStyle(color: Colors.white24, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
                ),
                const SizedBox(height: 16),
                _buildEditField("Protein Goal (g)", Icons.fitness_center, proController, Colors.blueAccent),
                const SizedBox(height: 12),
                _buildEditField("Carbs Goal (g)", Icons.grain, carbController, Colors.greenAccent),
                const SizedBox(height: 12),
                _buildEditField("Fats Goal (g)", Icons.invert_colors, fatController, Colors.redAccent),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("CANCEL", style: TextStyle(color: Colors.white38, fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: accentColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              setState(() {
                dailyGoal = int.tryParse(kcalController.text) ?? dailyGoal;
                proteinGoal = int.tryParse(proController.text) ?? proteinGoal;
                carbsGoal = int.tryParse(carbController.text) ?? carbsGoal;
                fatsGoal = int.tryParse(fatController.text) ?? fatsGoal;
              });
              Navigator.pop(context);
            },
            child: const Text("UPDATE", style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );
  }

  Widget _buildEditField(String label, IconData icon, TextEditingController controller, Color color) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white38, fontSize: 10),
        prefixIcon: Icon(icon, color: color, size: 18),
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Colors.white10)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: color.withOpacity(0.5))),
      ),
    );
  }

  Widget _buildMainDonut(int remaining, int consumed) {
    return SizedBox(
      height: 220,
      child: Stack(
        alignment: Alignment.center,
        children: [
          PieChart(
            PieChartData(
              startDegreeOffset: 270,
              sectionsSpace: 0,
              centerSpaceRadius: 85,
              sections: [
                PieChartSectionData(color: accentColor, value: consumed.toDouble(), radius: 12, showTitle: false),
                PieChartSectionData(color: Colors.white.withOpacity(0.05), value: (dailyGoal - consumed).toDouble().clamp(0, dailyGoal.toDouble()), radius: 12, showTitle: false),
              ],
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("$remaining", style: const TextStyle(color: Colors.white, fontSize: 42, fontWeight: FontWeight.w900, letterSpacing: -1)),
              const Text("KCAL LEFT", style: TextStyle(color: Colors.white38, fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 2)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats(int totalEaten) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: const Color(0xFF121214), borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.white.withOpacity(0.05))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Row(children: [Icon(Icons.restaurant, color: Color(0xFFFF9F0A), size: 20), SizedBox(width: 16), Text("TOTAL EATEN", style: TextStyle(color: Colors.white38, fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1))]),
          Text("$totalEaten", style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }

  Widget _buildMacroSection(int pro, int carb, int fat) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: const Color(0xFF121214), borderRadius: BorderRadius.circular(30), border: Border.all(color: accentColor.withOpacity(0.1))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("MACRONUTRIENTS", style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 1)),
          const SizedBox(height: 24),
          _buildMacroRow("PROTEIN", pro / proteinGoal, Colors.blueAccent, "${pro} / ${proteinGoal}g"),
          const SizedBox(height: 16),
          _buildMacroRow("CARBS", carb / carbsGoal, Colors.greenAccent, "${carb} / ${carbsGoal}g"),
          const SizedBox(height: 16),
          _buildMacroRow("FATS", fat / fatsGoal, Colors.redAccent, "${fat} / ${fatsGoal}g"),
        ],
      ),
    );
  }

  Widget _buildMacroRow(String title, double progress, Color color, String amount) {
    return Column(
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(title, style: const TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.w900)), Text(amount, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold))]),
        const SizedBox(height: 8),
        ClipRRect(borderRadius: BorderRadius.circular(10), child: LinearProgressIndicator(value: progress.clamp(0.0, 1.0), backgroundColor: Colors.white.withOpacity(0.05), color: color, minHeight: 6)),
      ],
    );
  }
}