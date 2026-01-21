import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  final Color primaryColor = const Color(0xFF00BFA5);
  final Color secondaryColor = const Color(0xFFFF9F0A);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF08080A),
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('dailyVitals')
              .orderBy('timestamp', descending: false)
              .snapshots(),
          builder: (context, snapshot) {
            List<FlSpot> weightSpots = [];
            double currentWeight = 60.0; // Default baseline

            if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
              final docs = snapshot.data!.docs;
              for (int i = 0; i < docs.length; i++) {
                final data = docs[i].data() as Map<String, dynamic>;
                if (data.containsKey('weight')) {
                  double val = double.tryParse(data['weight'].toString()) ?? 60.0;
                  weightSpots.add(FlSpot(i.toDouble(), val));
                  currentWeight = val;
                }
              }
            }

            // Fallback if no data yet
            if (weightSpots.isEmpty) {
              weightSpots = [const FlSpot(0, 60)];
            }

            return ListView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              children: [
                _buildHeader(context),
                _buildRadarCard(),
                const SizedBox(height: 24),
                _buildWeightLineChart(weightSpots),
                const SizedBox(height: 24),
                _buildWeightSummaryCard(currentWeight),
                const SizedBox(height: 100),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 25),
      child: Row(
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("ANALYTICS", style: TextStyle(color: Colors.white38, fontSize: 11, letterSpacing: 1.5, fontWeight: FontWeight.w900)),
              Text("BODY STATS", style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
            ],
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.05)),
            child: const Icon(Icons.insights_rounded, color: Colors.white, size: 18),
          ),
        ],
      ),
    );
  }

  Widget _buildRadarCard() {
    return _buildGlassContainer(
      title: "CAPABILITY MATRIX",
      child: AspectRatio(
        aspectRatio: 1.3,
        child: RadarChart(
          RadarChartData(
            radarShape: RadarShape.circle,
            getTitle: (index, angle) {
              const labels = ['POWER', 'STAMINA', 'LEGS', 'CORE', 'AGILITY', 'RECOVERY'];
              return RadarChartTitle(text: labels[index], angle: angle);
            },
            titleTextStyle: const TextStyle(color: Colors.white60, fontSize: 10, fontWeight: FontWeight.bold),
            borderData: FlBorderData(show: false),
            radarBorderData: BorderSide(color: Colors.white.withOpacity(0.05)),
            tickBorderData: BorderSide(color: Colors.white.withOpacity(0.05)),
            gridBorderData: BorderSide(color: Colors.white.withOpacity(0.05), width: 1),
            dataSets: [
              RadarDataSet(
                fillColor: primaryColor.withOpacity(0.2),
                borderColor: primaryColor,
                entryRadius: 3,
                dataEntries: [
                  const RadarEntry(value: 80), const RadarEntry(value: 65),
                  const RadarEntry(value: 90), const RadarEntry(value: 70),
                  const RadarEntry(value: 85), const RadarEntry(value: 60),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWeightLineChart(List<FlSpot> spots) {
    return _buildGlassContainer(
      title: "WEIGHT TREND (KG)",
      child: AspectRatio(
        aspectRatio: 1.7,
        child: LineChart(
          LineChartData(
            gridData: const FlGridData(show: false),
            titlesData: const FlTitlesData(show: false),
            borderData: FlBorderData(show: false),
            lineBarsData: [
              LineChartBarData(
                spots: spots,
                isCurved: true,
                color: secondaryColor,
                barWidth: 4,
                dotData: const FlDotData(show: true), // Show dots for recorded days
                belowBarData: BarAreaData(
                  show: true,
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [secondaryColor.withOpacity(0.2), secondaryColor.withOpacity(0)],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWeightSummaryCard(double current) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF121214),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("CURRENT WEIGHT", style: TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1)),
              const SizedBox(height: 8),
              Text("${current.toStringAsFixed(1)} KG", style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900)),
            ],
          ),
          Icon(Icons.monitor_weight_rounded, color: primaryColor, size: 30),
        ],
      ),
    );
  }

  Widget _buildGlassContainer({required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(24),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF0D0D0F),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1)),
          const SizedBox(height: 24),
          child,
        ],
      ),
    );
  }
}