import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

enum TimeFrame { week, month, year }
enum MetricType { weight, calories, streak }

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  TimeFrame _selectedTimeFrame = TimeFrame.week;
  MetricType _selectedMetric = MetricType.weight;

  final Color analyticsColor = const Color(0xFFBB86FC);
  final Color targetGold = const Color(0xFFFFD700);
  final Color obsidianBg = const Color(0xFF08080A);
  final Color glassBg = const Color(0xFF121214);

  double targetWeight = 79.0;
  double userHeightCm = 168.0;

  String? get currentUid => FirebaseAuth.instance.currentUser?.uid;

  void _showAddWeightDialog() {
    final weightController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: glassBg,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
            side: BorderSide(color: analyticsColor.withOpacity(0.2))),
        title: const Text("LOG CURRENT MASS",
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16)),
        content: TextField(
          controller: weightController,
          keyboardType: TextInputType.number,
          autofocus: true,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          decoration: InputDecoration(
            suffixText: "KG",
            suffixStyle: TextStyle(color: analyticsColor),
            filled: true,
            fillColor: Colors.white.withOpacity(0.03),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("ABORT", style: TextStyle(color: Colors.white24))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: analyticsColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            onPressed: () async {
              if (currentUid != null && weightController.text.isNotEmpty) {
                final double newWeight = double.parse(weightController.text);
                final String todayId = DateFormat('yyyy-MM-dd').format(DateTime.now());

                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(currentUid)
                    .collection('dailyVitals')
                    .doc(todayId)
                    .set({
                  'weight': newWeight,
                  'timestamp': FieldValue.serverTimestamp(),
                }, SetOptions(merge: true));

                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(currentUid)
                    .update({'currentWeight': newWeight});
              }
              Navigator.pop(context);
            },
            child: const Text("COMMIT",
                style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (currentUid == null) {
      return const Scaffold(
        backgroundColor: Color(0xFF08080A),
        body: Center(
            child: Text("ACCESS DENIED: PLEASE LOGIN",
                style: TextStyle(color: Colors.white24))),
      );
    }

    return Scaffold(
      backgroundColor: obsidianBg,
      floatingActionButton: _selectedMetric == MetricType.weight
          ? FloatingActionButton(
        backgroundColor: analyticsColor,
        onPressed: _showAddWeightDialog,
        child: const Icon(Icons.add_chart_rounded, color: Colors.black),
      )
          : null,
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(currentUid)
            .snapshots(),
        builder: (context, userSnapshot) {
          if (userSnapshot.hasData && userSnapshot.data!.exists) {
            var data = userSnapshot.data!.data() as Map<String, dynamic>;
            targetWeight = (data['targetWeight'] as num?)?.toDouble() ?? 79.0;
            userHeightCm = (data['height'] as num?)?.toDouble() ?? 168.0;
          }

          return Stack(
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
                          const SizedBox(height: 24),
                          _buildMainDataStream(),
                          const SizedBox(height: 24),
                          _buildSettingsButton(),
                          const SizedBox(height: 100),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }


  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("SYSTEM ANALYTICS",
                  style: TextStyle(
                      color: Colors.white38,
                      fontSize: 11,
                      letterSpacing: 1.5,
                      fontWeight: FontWeight.w900)),
              PopupMenuButton<MetricType>(
                onSelected: (MetricType value) =>
                    setState(() => _selectedMetric = value),
                offset: const Offset(0, 40),
                color: glassBg,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: Row(
                  children: [
                    Text(
                      _selectedMetric == MetricType.weight
                          ? "BODY METRICS"
                          : _selectedMetric == MetricType.calories
                          ? "FUEL INTAKE"
                          : "AVOID STREAK",
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.5),
                    ),
                    const Icon(Icons.arrow_drop_down, color: Colors.white38),
                  ],
                ),
                itemBuilder: (context) => [
                  _buildPopupItem(MetricType.weight, "BODY METRICS"),
                  _buildPopupItem(MetricType.calories, "FUEL INTAKE"),
                  _buildPopupItem(MetricType.streak, "AVOID STREAK"),
                ],
              ),
            ],
          ),
          const Spacer(),
          Icon(_getMetricIcon(), color: analyticsColor, size: 28),
        ],
      ),
    );
  }

  IconData _getMetricIcon() {
    switch (_selectedMetric) {
      case MetricType.weight:
        return Icons.monitor_weight_outlined;
      case MetricType.calories:
        return Icons.local_fire_department_rounded;
      case MetricType.streak:
        return Icons.shield_rounded;
    }
  }

  PopupMenuItem<MetricType> _buildPopupItem(MetricType value, String text) {
    return PopupMenuItem(
      value: value,
      child: Text(text,
          style: const TextStyle(
              color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
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
    String collection = _selectedMetric == MetricType.weight
        ? 'dailyVitals'
        : _selectedMetric == MetricType.calories
        ? 'dailyLog'
        : 'avoidHabits';

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(currentUid)
          .collection(collection)
          .orderBy('timestamp', descending: false)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
              height: 200,
              child: Center(child: CircularProgressIndicator(color: Color(0xFFBB86FC))));
        }

        final processedData =
        _processMetricTrend(snapshot.data?.docs ?? [], _selectedTimeFrame);
        final chartData = processedData['chartData'] as List<FlSpot>;
        final stats = processedData['stats'] as Map<String, dynamic>;

        return Column(
          children: [
            _buildChartContainer(chartData),
            if (_selectedMetric == MetricType.weight) _buildBMIGauge(stats['latest']),
            const SizedBox(height: 24),
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
      if (targetWeight < minY)
        minY = (targetWeight - 5).clamp(0, double.infinity);
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
      decoration: BoxDecoration(
        color: glassBg,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: AspectRatio(
        aspectRatio: 2.2,
        child: LineChart(
          LineChartData(
            minY: minY,
            maxY: maxY,
            lineTouchData: LineTouchData(
              touchTooltipData: LineTouchTooltipData(
                tooltipBgColor: const Color(0xFF1A1A1C),
                tooltipRoundedRadius: 8,
              ),
            ),
            gridData: FlGridData(
              show: true,
              drawHorizontalLine: true,
              horizontalInterval: 10,
              getDrawingHorizontalLine: (value) => FlLine(
                color: Colors.white.withOpacity(0.03),
                strokeWidth: 1,
                dashArray: [5, 5],
              ),
              drawVerticalLine: false,
            ),
            extraLinesData: ExtraLinesData(
              horizontalLines: [
                if (_selectedMetric == MetricType.weight)
                  HorizontalLine(
                    y: targetWeight,
                    color: targetGold.withOpacity(0.5),
                    strokeWidth: 1.5,
                    dashArray: [8, 4],
                    label: HorizontalLineLabel(
                      show: true,
                      alignment: Alignment.topRight,
                      style: TextStyle(
                          color: targetGold.withOpacity(0.8),
                          fontSize: 9,
                          fontWeight: FontWeight.bold),
                      labelResolver: (line) => "TARGET: ${targetWeight.toInt()}KG",
                    ),
                  ),
              ],
            ),
            titlesData: FlTitlesData(
              show: true,
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 35,
                  getTitlesWidget: (value, meta) => Text(
                    value.toInt().toString(),
                    style: TextStyle(color: Colors.white.withOpacity(0.15), fontSize: 9),
                  ),
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 32,
                  getTitlesWidget: (value, meta) {
                    if (_selectedTimeFrame != TimeFrame.week) return const SizedBox.shrink();
                    DateTime now = DateTime.now();
                    DateTime date = now.subtract(Duration(days: 6 - value.toInt()));
                    return Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Text(DateFormat('dd/MM').format(date),
                          style: TextStyle(
                              color: Colors.white.withOpacity(0.2),
                              fontSize: 8,
                              fontWeight: FontWeight.bold)),
                    );
                  },
                ),
              ),
            ),
            borderData: FlBorderData(show: false),
            lineBarsData: [
              LineChartBarData(
                spots: spots,
                isCurved: false,
                color: analyticsColor,
                barWidth: 2,
                dotData: FlDotData(
                  show: true,
                  getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                    radius: 3.5,
                    color: analyticsColor,
                    strokeWidth: 2,
                    strokeColor: obsidianBg,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBMIGauge(double weight) {
    double bmi = weight / ((userHeightCm / 100) * (userHeightCm / 100));

    return Container(
      margin: const EdgeInsets.only(top: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: glassBg,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("BODY MASS INDEX",
                  style: TextStyle(
                      color: Colors.white38,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5)),
              Text(bmi < 25 ? "NORMAL" : "ALERT",
                  style: TextStyle(
                      color: analyticsColor, fontSize: 10, fontWeight: FontWeight.w900)),
            ],
          ),
          const SizedBox(height: 20),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                height: 120,
                width: 240,
                child: PieChart(
                  PieChartData(
                    startDegreeOffset: 180,
                    sectionsSpace: 4,
                    centerSpaceRadius: 60,
                    sections: [
                      PieChartSectionData(
                          color: Colors.blue.withOpacity(0.2),
                          value: 25,
                          showTitle: false,
                          radius: 12),
                      PieChartSectionData(
                          color: analyticsColor.withOpacity(0.8),
                          value: 25,
                          showTitle: false,
                          radius: 12),
                      PieChartSectionData(
                          color: Colors.orange.withOpacity(0.2),
                          value: 25,
                          showTitle: false,
                          radius: 12),
                      PieChartSectionData(
                          color: Colors.red.withOpacity(0.2),
                          value: 25,
                          showTitle: false,
                          radius: 12),
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: 10,
                child: Column(
                  children: [
                    Text(bmi.toStringAsFixed(1),
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.w900)),
                    const Text("SCORE",
                        style: TextStyle(
                            color: Colors.white24,
                            fontSize: 9,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(Map<String, dynamic> stats) {
    String unit = _getUnit();
    return Column(
      children: [
        Row(
          children: [
            Expanded(
                child: _buildStatCard(
                    'AVG VALUE', '${stats['average'].toStringAsFixed(1)} $unit')),
            const SizedBox(width: 16),
            Expanded(
                child: _buildStatCard(
                    'PEAK VALUE', '${stats['peak'].toStringAsFixed(1)} $unit')),
          ],
        ),
        const SizedBox(height: 16),
        _buildStatCard('LATEST LOG', '${stats['latest'].toStringAsFixed(1)} $unit',
            fullWidth: true),
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
          Text(title,
              style: const TextStyle(
                  color: Colors.white38,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5)),
          const SizedBox(height: 8),
          Text(value,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 20,
                  letterSpacing: 0.5)),
        ],
      ),
    );
  }

  Widget _buildSettingsButton() {
    return GestureDetector(
      onTap: _showSettingsDialog,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: glassBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: targetGold.withOpacity(0.2)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.tune_rounded, color: targetGold, size: 18),
            const SizedBox(width: 12),
            const Text("UPDATE BIOMETRICS",
                style: TextStyle(
                    color: Color(0xFFFFD700),
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                    letterSpacing: 1.5)),
          ],
        ),
      ),
    );
  }

  void _showSettingsDialog() {
    final weightController = TextEditingController(text: targetWeight.toString());
    final heightController = TextEditingController(text: userHeightCm.toString());

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: glassBg,
          title: const Text("ADJUST BIOMETRICS",
              style: TextStyle(
                  color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDialogField("TARGET WEIGHT (KG)", weightController),
              const SizedBox(height: 16),
              _buildDialogField("HEIGHT (CM)", heightController),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("CANCEL", style: TextStyle(color: Colors.white24))),
            TextButton(
              onPressed: () async {
                if (currentUid != null) {
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(currentUid)
                      .set({
                    'targetWeight':
                    double.tryParse(weightController.text) ?? targetWeight,
                    'height': double.tryParse(heightController.text) ?? userHeightCm,
                  }, SetOptions(merge: true));
                }
                Navigator.pop(context);
              },
              child: Text("SAVE",
                  style: TextStyle(
                      color: analyticsColor, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDialogField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white38, fontSize: 10),
        enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.white.withOpacity(0.1))),
      ),
    );
  }

  String _getUnit() {
    switch (_selectedMetric) {
      case MetricType.weight:
        return 'KG';
      case MetricType.calories:
        return 'KCAL';
      case MetricType.streak:
        return 'DAYS';
    }
  }

  Map<String, dynamic> _processMetricTrend(List<QueryDocumentSnapshot> docs, TimeFrame frame) {
    Map<DateTime, double> dataMap = {};
    String key = _selectedMetric == MetricType.weight
        ? 'weight'
        : _selectedMetric == MetricType.calories
        ? 'calories'
        : 'streakDays';

    for (var doc in docs) {
      var data = doc.data() as Map<String, dynamic>;
      if (data.containsKey(key) && data['timestamp'] != null) {
        DateTime date = (data['timestamp'] as Timestamp).toDate();
        DateTime dayOnly = DateTime(date.year, date.month, date.day);
        dataMap[dayOnly] = double.tryParse(data[key].toString()) ?? 0.0;
      }
    }

    DateTime now = DateTime.now();
    int days = (frame == TimeFrame.week) ? 7 : (frame == TimeFrame.month ? 30 : 365);
    DateTime start =
    DateTime(now.year, now.month, now.day).subtract(Duration(days: days - 1));

    List<FlSpot> spots = [];
    List<double> values = [];
    List<DateTime> sortedDates = dataMap.keys.toList()..sort();

    for (int i = 0; i < days; i++) {
      DateTime current = start.add(Duration(days: i));
      double val;

      if (dataMap.containsKey(current)) {
        val = dataMap[current]!;
      } else {
        DateTime? prevDate =
            sortedDates.reversed.where((d) => d.isBefore(current)).firstOrNull;
        val = dataMap[prevDate] ?? 0.0;
      }
      spots.add(FlSpot(i.toDouble(), val));
      values.add(val);
    }

    double avg = values.isEmpty ? 0 : values.reduce((a, b) => a + b) / values.length;
    double max = values.isEmpty ? 0 : values.reduce((a, b) => a > b ? a : b);

    return {
      'chartData': spots,
      'stats': {
        'average': avg,
        'peak': max,
        'latest': values.isNotEmpty ? values.last : 0.0
      }
    };
  }
}