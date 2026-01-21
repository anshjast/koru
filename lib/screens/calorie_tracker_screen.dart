import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';

class CalorieTrackerScreen extends StatefulWidget {
  const CalorieTrackerScreen({super.key});

  @override
  State<CalorieTrackerScreen> createState() => _CalorieTrackerScreenState();
}

class _CalorieTrackerScreenState extends State<CalorieTrackerScreen> {
  final Color accentColor = const Color(0xFFFF9F0A);
  final int dailyGoal = 2000;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final startOfToday = DateTime(now.year, now.month, now.day);

    return Scaffold(
      backgroundColor: const Color(0xFF08080A),
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
              stream: FirebaseFirestore.instance
                  .collection('dailyLog')
                  .where('timestamp', isGreaterThanOrEqualTo: startOfToday)
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

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Row(
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
    );
  }

  Widget _buildMainDonut(int remaining, int consumed) {
    double progress = consumed / dailyGoal;
    if (progress > 1.0) progress = 1.0;

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
                PieChartSectionData(
                  color: accentColor,
                  value: consumed.toDouble(),
                  radius: 12,
                  showTitle: false,
                ),
                PieChartSectionData(
                  color: Colors.white.withOpacity(0.05),
                  value: (dailyGoal - consumed).toDouble().clamp(0, dailyGoal.toDouble()),
                  radius: 12,
                  showTitle: false,
                ),
              ],
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "$remaining",
                style: const TextStyle(color: Colors.white, fontSize: 42, fontWeight: FontWeight.w900, letterSpacing: -1),
              ),
              const Text(
                "KCAL LEFT",
                style: TextStyle(color: Colors.white38, fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 2),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats(int totalEaten) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF121214),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Row(
            children: [
              Icon(Icons.restaurant, color: Color(0xFFFF9F0A), size: 20),
              SizedBox(width: 16),
              Text("TOTAL EATEN", style: TextStyle(color: Colors.white38, fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1)),
            ],
          ),
          Text("$totalEaten", style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }

  Widget _buildMacroSection(int pro, int carb, int fat) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF121214),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: accentColor.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("MACRONUTRIENTS", style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 1)),
          const SizedBox(height: 24),
          _buildMacroRow("PROTEIN", pro / 150, Colors.blueAccent, "${pro}g"),
          const SizedBox(height: 16),
          _buildMacroRow("CARBS", carb / 250, Colors.greenAccent, "${carb}g"),
          const SizedBox(height: 16),
          _buildMacroRow("FATS", fat / 70, Colors.redAccent, "${fat}g"),
        ],
      ),
    );
  }

  Widget _buildMacroRow(String title, double progress, Color color, String amount) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: const TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.w900)),
            Text(amount, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            backgroundColor: Colors.white.withOpacity(0.05),
            color: color,
            minHeight: 6,
          ),
        ),
      ],
    );
  }
}