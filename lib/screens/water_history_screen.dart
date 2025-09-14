import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Hydration History'),
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildTimeFrameSelector(),
          const SizedBox(height: 24),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('waterLog').orderBy('timestamp').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(child: Text('Not enough data to show history.'));
              }

              final processedData = _processDataForChart(snapshot.data!.docs, _selectedTimeFrame);
              final chartData = processedData['chartData'] as List<FlSpot>;
              final stats = processedData['stats'] as Map<String, dynamic>;

              return Column(
                children: [
                  _buildChart(chartData),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard('Average', '${stats['average'].toStringAsFixed(0)} ml'),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard('Consistency', '${stats['consistency'].toStringAsFixed(0)}%'),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard('Best Day', '${stats['bestDay'].toStringAsFixed(0)} ml'),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
  Widget _buildTimeFrameSelector() {
    return SegmentedButton<TimeFrame>(
      segments: const <ButtonSegment<TimeFrame>>[
        ButtonSegment(value: TimeFrame.week, label: Text('Week')),
        ButtonSegment(value: TimeFrame.month, label: Text('Month')),
        ButtonSegment(value: TimeFrame.year, label: Text('Year')),
      ],
      selected: {_selectedTimeFrame},
      onSelectionChanged: (Set<TimeFrame> newSelection) {
        setState(() {
          _selectedTimeFrame = newSelection.first;
        });
      },
      style: SegmentedButton.styleFrom(
        foregroundColor: Colors.white,
        selectedForegroundColor: Colors.black,
        selectedBackgroundColor: Colors.white,
      ),
    );
  }

  Widget _buildChart(List<FlSpot> spots) {
    double maxYValue = spots.fold(0, (max, spot) => spot.y > max ? spot.y : max);
    double chartMaxY = maxYValue > _dailyTarget ? maxYValue : _dailyTarget.toDouble();
    if (chartMaxY == 0) chartMaxY = _dailyTarget.toDouble();

    return AspectRatio(
      aspectRatio: 1.7,
      child: LineChart(
        LineChartData(
          minY: 0,
          maxY: chartMaxY * 1.2,
          backgroundColor: const Color(0xffE6F4F1),
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          titlesData: const FlTitlesData(
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: const Color(0xff0D1F3C),
              barWidth: 4,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [
                    const Color(0xff0D1F3C).withOpacity(0.3),
                    const Color(0xff0D1F3C).withOpacity(0.0),
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

  Widget _buildStatCard(String title, String value) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          children: [
            Text(title, style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12), textAlign: TextAlign.center,),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16), textAlign: TextAlign.center,),
          ],
        ),
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

