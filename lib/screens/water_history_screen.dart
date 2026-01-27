import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

enum TimeFrame { week, month, year }

class WaterHistoryScreen extends StatefulWidget {
  const WaterHistoryScreen({super.key});

  @override
  State<WaterHistoryScreen> createState() => _WaterHistoryScreenState();
}

class _WaterHistoryScreenState extends State<WaterHistoryScreen> {
  TimeFrame _selectedTimeFrame = TimeFrame.week;
  final int _dailyTarget = 2000;
  final Color waterColor = const Color(0xFF00D2FF);

  String? get currentUid => FirebaseAuth.instance.currentUser?.uid;

  @override
  Widget build(BuildContext context) {
    if (currentUid == null) {
      return const Scaffold(
        backgroundColor: Color(0xFF08080A),
        body: Center(child: Text("PLEASE LOGIN TO VIEW HISTORY", style: TextStyle(color: Colors.white24))),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF08080A),
      body: Stack(
        children: [
          Positioned(
            top: -50,
            right: -50,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: waterColor.withOpacity(0.08),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                _buildHeader(context),
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

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
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
              Text("ANALYTICS", style: TextStyle(color: Colors.white38, fontSize: 11, letterSpacing: 1.5, fontWeight: FontWeight.w900)),
              Text("HISTORY", style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimeFrameSelector() {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: const Color(0xFF121214),
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
                  color: isSelected ? waterColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Center(
                  child: Text(
                    frame.name.toUpperCase(),
                    style: TextStyle(
                      color: isSelected ? Colors.black : Colors.white38,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1,
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
          .collection('users')
          .doc(currentUid)
          .collection('waterLog')
          .orderBy('timestamp')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

        final processedData = _processDataForChart(snapshot.data!.docs, _selectedTimeFrame);
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
      child: _buildChart(spots),
    );
  }

  Widget _buildChart(List<FlSpot> spots) {
    double maxYValue = spots.fold(0, (max, spot) => spot.y > max ? spot.y : max);
    double chartMaxY = maxYValue > 0 ? maxYValue * 1.5 : _dailyTarget.toDouble();

    return AspectRatio(
      aspectRatio: 1.7,
      child: LineChart(
        LineChartData(
          minY: 0,
          maxY: chartMaxY,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: true,
            horizontalInterval: chartMaxY / 4,
            getDrawingHorizontalLine: (value) => FlLine(
              color: Colors.white.withOpacity(0.03),
              strokeWidth: 1,
            ),
            getDrawingVerticalLine: (value) => FlLine(
              color: Colors.white.withOpacity(0.03),
              strokeWidth: 1,
            ),
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            show: true,
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                interval: _selectedTimeFrame == TimeFrame.week ? 1 : 5,
                getTitlesWidget: (value, meta) {
                  String text = '';
                  if (_selectedTimeFrame == TimeFrame.week) {
                    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                    if (value.toInt() >= 0 && value.toInt() < 7) text = days[value.toInt()];
                  } else if (_selectedTimeFrame == TimeFrame.month) {
                    text = '${value.toInt() + 1}';
                  } else if (_selectedTimeFrame == TimeFrame.year) {
                    const months = ['Jan', 'Mar', 'May', 'Jul', 'Sep', 'Nov'];
                    int idx = value.toInt();
                    if (idx % 2 == 0 && idx < 12) text = months[idx ~/ 2];
                  }
                  return SideTitleWidget(
                    axisSide: meta.axisSide,
                    space: 10,
                    child: Text(
                      text,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.4),
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          lineTouchData: LineTouchData(
            handleBuiltInTouches: true,
            touchTooltipData: LineTouchTooltipData(
              tooltipBgColor: const Color(0xFF121214),
              tooltipRoundedRadius: 8,
              getTooltipItems: (touchedSpots) => touchedSpots.map((spot) {
                return LineTooltipItem(
                  '${spot.y.toInt()} ml',
                  TextStyle(color: waterColor, fontWeight: FontWeight.bold, fontSize: 12),
                );
              }).toList(),
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              curveSmoothness: 0.4,
              color: waterColor,
              barWidth: 2,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [
                    waterColor.withOpacity(0.2),
                    waterColor.withOpacity(0.0),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsGrid(Map<String, dynamic> stats) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildStatCard('AVERAGE', '${stats['average'].toStringAsFixed(0)} ML')),
            const SizedBox(width: 16),
            Expanded(child: _buildStatCard('BEST DAY', '${stats['bestDay'].toStringAsFixed(0)} ML')),
          ],
        ),
        const SizedBox(height: 16),
        _buildStatCard('CONSISTENCY', '${stats['consistency'].toStringAsFixed(0)}%', fullWidth: true),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, {bool fullWidth = false}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF121214),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: fullWidth ? CrossAxisAlignment.center : CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18, letterSpacing: 1)),
        ],
      ),
    );
  }

  Map<String, dynamic> _processDataForChart(List<QueryDocumentSnapshot> docs, TimeFrame timeFrame) {
    final Map<DateTime, int> dailyTotals = {};
    for (var doc in docs) {
      final timestamp = (doc['timestamp'] as Timestamp).toDate();
      final day = DateTime(timestamp.year, timestamp.month, timestamp.day);
      final amount = (doc['amount'] as num).toInt();
      dailyTotals.update(day, (value) => value + amount, ifAbsent: () => amount);
    }
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    DateTime startDate;
    int numberOfDays;

    switch (timeFrame) {
      case TimeFrame.week:
        numberOfDays = 7;
        startDate = today.subtract(Duration(days: numberOfDays - 1));
        break;
      case TimeFrame.month:
        numberOfDays = 30;
        startDate = today.subtract(Duration(days: numberOfDays - 1));
        break;
      case TimeFrame.year:
        numberOfDays = 12;
        startDate = DateTime(today.year, today.month - 11, 1);
        break;
    }
    final List<FlSpot> spots = [];
    final List<double> dailyValues = [];
    if (timeFrame == TimeFrame.year) {
      final Map<int, int> monthlyTotals = {};
      dailyTotals.forEach((date, amount) {
        monthlyTotals.update(date.month, (value) => value + amount, ifAbsent: () => amount);
      });
      for (int i = 0; i < 12; i++) {
        int month = startDate.month + i;
        if (month > 12) month -= 12;
        spots.add(FlSpot(i.toDouble(), (monthlyTotals[month] ?? 0).toDouble()));
        dailyValues.add((monthlyTotals[month] ?? 0).toDouble());
      }
    } else {
      for (int i = 0; i < numberOfDays; i++) {
        final date = startDate.add(Duration(days: i));
        final value = (dailyTotals[date] ?? 0).toDouble();
        spots.add(FlSpot(i.toDouble(), value));
        dailyValues.add(value);
      }
    }
    double average = 0;
    int consistency = 0;
    double bestDay = 0;
    if (dailyValues.isNotEmpty) {
      final relevantValues = dailyValues.where((v) => v > 0).toList();
      if (relevantValues.isNotEmpty) {
        average = relevantValues.reduce((a, b) => a + b) / relevantValues.length;
        bestDay = relevantValues.reduce((a, b) => a > b ? a : b);
      }
      consistency = (dailyValues.where((v) => v >= _dailyTarget).length / dailyValues.length * 100).toInt();
    }

    return {
      'chartData': spots,
      'stats': {
        'average': average,
        'consistency': consistency,
        'bestDay': bestDay,
      }
    };
  }
}