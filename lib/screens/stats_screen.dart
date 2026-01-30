import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

enum TimeFrame { week, month, year }

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  TimeFrame _selectedTimeFrame = TimeFrame.week;

  final Color analyticsColor = const Color(0xFFBB86FC);
  final Color targetGold = const Color(0xFFFFD700);
  final Color aestheticCyan = const Color(0xFF03DAC6);
  final Color obsidianBg = const Color(0xFF08080A);
  final Color glassBg = const Color(0xFF121214);

  double targetWeight = 79.0;
  double userHeightCm = 168.0;
  double currentShoulders = 0.0;
  double currentWaist = 0.0;
  double currentNeck = 38.0;

  String? get currentUid => FirebaseAuth.instance.currentUser?.uid;

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
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('users').doc(currentUid).snapshots(),
        builder: (context, userSnapshot) {
          if (userSnapshot.hasData && userSnapshot.data!.exists) {
            var data = userSnapshot.data!.data() as Map<String, dynamic>;
            targetWeight = (data['targetWeight'] as num?)?.toDouble() ?? 79.0;
            userHeightCm = (data['height'] as num?)?.toDouble() ?? 168.0;
            currentShoulders = (data['shoulders'] as num?)?.toDouble() ?? 0.0;
            currentWaist = (data['waist'] as num?)?.toDouble() ?? 0.0;
            currentNeck = (data['neck'] as num?)?.toDouble() ?? 38.0;
          }

          return SafeArea(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              children: [
                _buildHeader(),
                _buildTimeFrameSelector(),
                const SizedBox(height: 24),
                _buildMainDataStream(),
                const SizedBox(height: 24),
                _buildSymmetrySection(),
                const SizedBox(height: 32),
                _buildSettingsButton(),
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("SYSTEM ANALYTICS", style: TextStyle(color: Colors.white38, fontSize: 11, letterSpacing: 1.5, fontWeight: FontWeight.w900)),
              Text("BODY METRICS", style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
            ],
          ),
          Icon(Icons.analytics_outlined, color: analyticsColor, size: 28),
        ],
      ),
    );
  }

  Widget _buildTimeFrameSelector() {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(color: glassBg, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white.withOpacity(0.05))),
      child: Row(
        children: TimeFrame.values.map((frame) {
          bool isSelected = _selectedTimeFrame == frame;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedTimeFrame = frame),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(color: isSelected ? analyticsColor : Colors.transparent, borderRadius: BorderRadius.circular(15)),
                child: Center(child: Text(frame.name.toUpperCase(), style: TextStyle(color: isSelected ? Colors.black : Colors.white38, fontSize: 10, fontWeight: FontWeight.w900))),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMainDataStream() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('users').doc(currentUid).collection('dailyVitals').orderBy('timestamp', descending: false).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

        final processedData = _processMetricTrend(snapshot.data?.docs ?? [], _selectedTimeFrame);
        final chartData = processedData['chartData'] as List<FlSpot>;
        final stats = processedData['stats'] as Map<String, dynamic>;
        double velocity = (processedData['velocity'] as num).toDouble();

        return Column(
          children: [
            _buildChartContainer(chartData),
            const SizedBox(height: 24),
            _buildVelocityCard(velocity),
            const SizedBox(height: 16),
            _buildStatsGrid(stats),
          ],
        );
      },
    );
  }

  Widget _buildChartContainer(List<FlSpot> spots) {
    double minY = 0;
    double maxY = 100;

    if (spots.isNotEmpty) {
      double minW = spots.map((s) => s.y).reduce((a, b) => a < b ? a : b);
      double maxW = spots.map((s) => s.y).reduce((a, b) => a > b ? a : b);
      minY = (minW - 5).clamp(0, double.infinity);
      maxY = (maxW + 5);
      if (targetWeight > maxY) maxY = targetWeight + 5;
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
      decoration: BoxDecoration(color: glassBg, borderRadius: BorderRadius.circular(30), border: Border.all(color: Colors.white.withOpacity(0.05))),
      child: AspectRatio(
        aspectRatio: 2.2,
        child: LineChart(
          LineChartData(
            minY: minY,
            maxY: maxY,
            gridData: FlGridData(show: true, drawVerticalLine: false, horizontalInterval: 10, getDrawingHorizontalLine: (value) => FlLine(color: Colors.white.withOpacity(0.03), strokeWidth: 1, dashArray: [5, 5])),
            titlesData: const FlTitlesData(show: false),
            borderData: FlBorderData(show: false),
            extraLinesData: ExtraLinesData(horizontalLines: [HorizontalLine(y: targetWeight, color: targetGold.withOpacity(0.5), strokeWidth: 1.5, dashArray: [8, 4])]),
            lineBarsData: [
              LineChartBarData(spots: spots, isCurved: true, color: analyticsColor, barWidth: 3, dotData: const FlDotData(show: false), belowBarData: BarAreaData(show: true, color: analyticsColor.withOpacity(0.05)))
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVelocityCard(double velocity) {
    bool isPositive = velocity >= 0;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: glassBg, borderRadius: BorderRadius.circular(24), border: Border.all(color: analyticsColor.withOpacity(0.1))),
      child: Row(
        children: [
          Icon(isPositive ? Icons.trending_up : Icons.trending_down, color: analyticsColor),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("WEIGHT VELOCITY", style: TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.w900)),
              Text("${isPositive ? '+' : ''}${velocity.toStringAsFixed(2)} KG / WEEK", style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          const Spacer(),
          Text(velocity.abs() < 0.6 ? "OPTIMAL BULK" : "FAST CHANGE", style: TextStyle(color: analyticsColor.withOpacity(0.5), fontSize: 9, fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }

  Widget _buildSymmetrySection() {
    double ratio = currentWaist > 0 ? currentShoulders / currentWaist : 0.0;
    double idealRatio = 1.618;
    double progress = (ratio / idealRatio).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: glassBg, borderRadius: BorderRadius.circular(30), border: Border.all(color: aestheticCyan.withOpacity(0.1))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("V-TAPER RATIO", style: TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(ratio.toStringAsFixed(2), style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900)),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text("GOLDEN RATIO", style: TextStyle(color: Colors.white24, fontSize: 9)),
                  Text(idealRatio.toString(), style: TextStyle(color: aestheticCyan, fontWeight: FontWeight.bold)),
                ],
              )
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(value: progress, backgroundColor: Colors.white.withOpacity(0.05), color: aestheticCyan, minHeight: 8),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(Map<String, dynamic> stats) {
    return Row(
      children: [
        Expanded(child: _buildStatCard('AVG KG', '${(stats['average'] as double).toStringAsFixed(1)}')),
        const SizedBox(width: 12),
        Expanded(child: _buildStatCard('LATEST', '${(stats['latest'] as double).toStringAsFixed(1)}')),
      ],
    );
  }

  Widget _buildStatCard(String title, String value) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: glassBg, borderRadius: BorderRadius.circular(22), border: Border.all(color: Colors.white.withOpacity(0.03))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(color: Colors.white38, fontSize: 9, fontWeight: FontWeight.w900)),
        const SizedBox(height: 8),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
      ]),
    );
  }

  Widget _buildSettingsButton() {
    return GestureDetector(
      onTap: _showSettingsDialog,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(color: glassBg, borderRadius: BorderRadius.circular(20), border: Border.all(color: targetGold.withOpacity(0.2))),
        child: const Center(child: Text("UPDATE BIOMETRICS", style: TextStyle(color: Color(0xFFFFD700), fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1.5))),
      ),
    );
  }

  void _showSettingsDialog() {
    final weightController = TextEditingController(text: targetWeight.toString());
    final shoulderController = TextEditingController(text: currentShoulders.toString());
    final waistController = TextEditingController(text: currentWaist.toString());
    final neckController = TextEditingController(text: (currentNeck ?? 38.0).toString());
    final heightController = TextEditingController(text: userHeightCm.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: glassBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        title: const Text("ADJUST HARDWARE",
            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDialogField("TARGET WEIGHT (KG)", weightController),
              _buildDialogField("HEIGHT (CM)", heightController),
              _buildDialogField("SHOULDERS (CM)", shoulderController),
              _buildDialogField("WAIST (CM) - for Body Fat", waistController),
              _buildDialogField("NECK (CM) - for Body Fat", neckController),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("CANCEL", style: TextStyle(color: Colors.white24))),
          TextButton(
            onPressed: () async {
              if (currentUid != null) {
                await FirebaseFirestore.instance.collection('users').doc(currentUid).update({
                  'targetWeight': double.tryParse(weightController.text) ?? targetWeight,
                  'height': double.tryParse(heightController.text) ?? userHeightCm,
                  'shoulders': double.tryParse(shoulderController.text) ?? currentShoulders,
                  'waist': double.tryParse(waistController.text) ?? currentWaist,
                  'neck': double.tryParse(neckController.text) ?? 38.0,
                });
              }
              Navigator.pop(context);
            },
            child: Text("COMMIT", style: TextStyle(color: analyticsColor, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildDialogField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(labelText: label, labelStyle: const TextStyle(color: Colors.white38, fontSize: 10)),
    );
  }

  Map<String, dynamic> _processMetricTrend(List<QueryDocumentSnapshot> docs, TimeFrame frame) {
    List<double> weights = docs.map((d) => (double.tryParse((d.data() as Map<String, dynamic>)['weight'].toString()) ?? 0.0)).toList();
    double velocity = 0.0;
    if (weights.length >= 7) {
      velocity = weights.last - weights[weights.length - 7];
    }

    return {
      'chartData': docs.asMap().entries.map((e) => FlSpot(e.key.toDouble(), double.tryParse((e.value.data() as Map<String, dynamic>)['weight'].toString()) ?? 0.0)).toList(),
      'velocity': velocity,
      'stats': {'average': weights.isEmpty ? 0.0 : weights.reduce((a, b) => a + b) / weights.length, 'latest': weights.isEmpty ? 0.0 : weights.last}
    };
  }
}