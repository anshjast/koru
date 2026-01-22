import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
  final Color obsidianBg = const Color(0xFF08080A);
  final Color glassBg = const Color(0xFF121214);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: obsidianBg,
      body: Stack(
        children: [
          Positioned(
            top: -50,
            left: -50,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: analyticsColor.withOpacity(0.05),
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
                      _buildTimeFrameSelector(),
                      const SizedBox(height: 30),
                      _buildMainDataStream(),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("SYSTEM ANALYTICS", style: TextStyle(color: Colors.white38, fontSize: 11, letterSpacing: 1.5, fontWeight: FontWeight.w900)),
              Text("BODY METRICS", style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
            ],
          ),
          const Spacer(),
          Icon(Icons.analytics_rounded, color: analyticsColor, size: 28),
        ],
      ),
    );
  }

  Widget _buildTimeFrameSelector() {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: glassBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: TimeFrame.values.map((frame) {
          bool isSelected = _selectedTimeFrame == frame;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedTimeFrame = frame),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? analyticsColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Center(
                  child: Text(
                    frame.name.toUpperCase(),
                    style: TextStyle(
                      color: isSelected ? Colors.black : Colors.white38,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMainDataStream() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('dailyVitals')
          .orderBy('timestamp', descending: false)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFFBB86FC)));
        }

        final processedData = _processWeightTrend(snapshot.data?.docs ?? [], _selectedTimeFrame);
        final chartData = processedData['chartData'] as List<FlSpot>;
        final stats = processedData['stats'] as Map<String, dynamic>;

        return Column(
          children: [
            _buildChartContainer(chartData),
            const SizedBox(height: 30),
            _buildStatsGrid(stats),
          ],
        );
      },
    );
  }

  Widget _buildChartContainer(List<FlSpot> spots) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 30, 20, 10),
      decoration: BoxDecoration(
        color: const Color(0xFF0F0F12),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: AspectRatio(
        aspectRatio: 1.7,
        child: LineChart(
          LineChartData(
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              getDrawingHorizontalLine: (value) => FlLine(color: Colors.white.withOpacity(0.02), strokeWidth: 1),
            ),
            titlesData: FlTitlesData(
              show: true,
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 30,
                  getTitlesWidget: (value, meta) {
                    if (_selectedTimeFrame != TimeFrame.week) return const SizedBox.shrink();
                    const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
                    int index = value.toInt();
                    return index >= 0 && index < 7
                        ? SideTitleWidget(
                      axisSide: meta.axisSide,
                      child: Text(days[index], style: const TextStyle(color: Colors.white24, fontSize: 10, fontWeight: FontWeight.bold)),
                    )
                        : const SizedBox.shrink();
                  },
                ),
              ),
            ),
            borderData: FlBorderData(show: false),
            lineBarsData: [
              LineChartBarData(
                spots: spots,
                isCurved: true,
                curveSmoothness: 0.35,
                color: analyticsColor,
                barWidth: 4,
                dotData: const FlDotData(show: false),
                belowBarData: BarAreaData(
                  show: true,
                  gradient: LinearGradient(
                    colors: [analyticsColor.withOpacity(0.2), Colors.transparent],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsGrid(Map<String, dynamic> stats) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildStatCard('AVG WEIGHT', '${stats['average'].toStringAsFixed(1)} KG')),
            const SizedBox(width: 16),
            Expanded(child: _buildStatCard('MAX WEIGHT', '${stats['peak'].toStringAsFixed(1)} KG')),
          ],
        ),
        const SizedBox(height: 16),
        _buildStatCard('LATEST LOG', '${stats['latest'].toStringAsFixed(1)} KG', fullWidth: true),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, {bool fullWidth = false}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: glassBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: fullWidth ? CrossAxisAlignment.center : CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 20, letterSpacing: 0.5)),
        ],
      ),
    );
  }

  Map<String, dynamic> _processWeightTrend(List<QueryDocumentSnapshot> docs, TimeFrame frame) {
    Map<DateTime, double> dailyWeights = {};
    for (var doc in docs) {
      var data = doc.data() as Map<String, dynamic>;
      if (data.containsKey('weight') && data['timestamp'] != null) {
        DateTime date = (data['timestamp'] as Timestamp).toDate();
        DateTime dayOnly = DateTime(date.year, date.month, date.day);
        dailyWeights[dayOnly] = double.tryParse(data['weight'].toString()) ?? 0.0;
      }
    }

    DateTime now = DateTime.now();
    int daysToLookBack = (frame == TimeFrame.week) ? 7 : (frame == TimeFrame.month ? 30 : 365);
    DateTime startDate = DateTime(now.year, now.month, now.day).subtract(Duration(days: daysToLookBack - 1));

    List<FlSpot> spots = [];
    List<double> values = [];
    double lastKnownWeight = 60.0;

    for (int i = 0; i < daysToLookBack; i++) {
      DateTime currentDate = startDate.add(Duration(days: i));
      if (dailyWeights.containsKey(currentDate)) {
        lastKnownWeight = dailyWeights[currentDate]!;
      }
      spots.add(FlSpot(i.toDouble(), lastKnownWeight));
      values.add(lastKnownWeight);
    }

    double avg = values.isEmpty ? 0 : values.reduce((a, b) => a + b) / values.length;
    double max = values.isEmpty ? 0 : values.reduce((a, b) => a > b ? a : b);

    return {
      'chartData': spots,
      'stats': {
        'average': avg,
        'peak': max,
        'latest': values.isNotEmpty ? values.last : 0.0,
      }
    };
  }
}