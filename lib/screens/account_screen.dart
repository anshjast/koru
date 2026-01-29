import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:koru/models/auth_service.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final Color primaryAccent = const Color(0xFFE0E0E0);
  final Color energyPeach = const Color(0xFFFFB399);
  final Color muscleCyan = const Color(0xFF80FFE8);
  final Color obsidianBg = const Color(0xFF08080A);
  final Color glassBg = const Color(0xFF121214);

  String? get currentUid => FirebaseAuth.instance.currentUser?.uid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: obsidianBg,
      body: Stack(
        children: [
          Positioned(
            top: -150,
            left: -100,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: energyPeach.withOpacity(0.05),
              ),
            ),
          ),
          SafeArea(
            child: StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance.collection('users').doc(currentUid).snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData || !snapshot.data!.exists) {
                  return const Center(child: CircularProgressIndicator());
                }

                var userData = snapshot.data!.data() as Map<String, dynamic>;
                String name = userData['name'] ?? "WARRIOR";
                String status = userData['status'] ?? "B.TECH FINAL YEAR";
                double weight = (userData['currentWeight'] as num?)?.toDouble() ?? 60.0;
                double height = (userData['height'] as num?)?.toDouble() ?? 168.0;

                return Column(
                  children: [
                    _buildHeader(context),
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        children: [
                          _buildProfileCard(name, status),
                          const SizedBox(height: 24),
                          _buildVitalsRow(weight.toString(), height.toString()),
                          const SizedBox(height: 32),
                          _buildEnergyChartCard(),
                          const SizedBox(height: 20),
                          _buildMuscleDistributionCard(),
                          const SizedBox(height: 32),
                          _buildLogoutButton(),
                          const SizedBox(height: 40),
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
              const Text("SYSTEM IDENTITY",
                  style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
            ],
          ),
          Icon(Icons.verified_user_rounded, color: energyPeach.withOpacity(0.5), size: 24),
        ],
      ),
    );
  }

  Widget _buildProfileCard(String name, String status) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: glassBg,
        borderRadius: BorderRadius.circular(35),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: energyPeach.withOpacity(0.2), width: 2),
            ),
            child: CircleAvatar(
              radius: 40,
              backgroundColor: Colors.white.withOpacity(0.05),
              child: const Icon(Icons.person_outline_rounded, color: Colors.white, size: 40),
            ),
          ),
          const SizedBox(height: 20),
          Text(name.toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: 2)),
          const SizedBox(height: 4),
          Text(status, style: TextStyle(color: energyPeach.withOpacity(0.6), fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1)),
        ],
      ),
    );
  }

  Widget _buildVitalsRow(String weight, String height) {
    return Row(
      children: [
        Expanded(child: _buildMetricBox("BODY MASS", "$weight KG", Icons.monitor_weight_outlined)),
        const SizedBox(width: 12),
        Expanded(child: _buildMetricBox("IDENTITY HEIGHT", "$height CM", Icons.height_rounded)),
      ],
    );
  }

  Widget _buildMetricBox(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      decoration: BoxDecoration(
        color: glassBg,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.white.withOpacity(0.03)),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white24, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white24, fontSize: 7, fontWeight: FontWeight.w900),
                ),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnergyChartCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF0F0F11),
        borderRadius: BorderRadius.circular(35),
        border: Border.all(color: energyPeach.withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("ENERGY TREND", style: TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
              Icon(Icons.bolt_rounded, color: energyPeach, size: 18),
            ],
          ),
          const SizedBox(height: 24),
          AspectRatio(
            aspectRatio: 2,
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('users').doc(currentUid).collection('trainLogs').orderBy('timestamp', descending: true).limit(7).snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("NO DATA LOGGED", style: TextStyle(color: Colors.white10, fontSize: 10)));
                }
                List<QueryDocumentSnapshot> docs = snapshot.data!.docs.reversed.toList();
                List<FlSpot> spots = [];
                for (int i = 0; i < docs.length; i++) {
                  var data = docs[i].data() as Map<String, dynamic>;
                  double energy = (data['energyLevel'] as num? ?? 3).toDouble();
                  spots.add(FlSpot(i.toDouble(), energy));
                }
                return LineChart(
                  LineChartData(
                    gridData: const FlGridData(show: false),
                    titlesData: const FlTitlesData(show: false),
                    borderData: FlBorderData(show: false),
                    minY: 1,
                    maxY: 5,
                    lineBarsData: [
                      LineChartBarData(
                        spots: spots,
                        isCurved: true,
                        color: energyPeach,
                        barWidth: 3,
                        isStrokeCapRound: true,
                        dotData: const FlDotData(show: true),
                        belowBarData: BarAreaData(show: true, color: energyPeach.withOpacity(0.05)),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMuscleDistributionCard() {
    return GestureDetector(
      onTap: () => _showMonthlySummary(),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: glassBg,
          borderRadius: BorderRadius.circular(35),
          border: Border.all(color: muscleCyan.withOpacity(0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("TRAINING VOLUME", style: TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
                Icon(Icons.analytics_outlined, color: muscleCyan, size: 14),
              ],
            ),
            const SizedBox(height: 20),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('users').doc(currentUid).collection('trainLogs').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Text("NO WORKOUT DATA", style: TextStyle(color: Colors.white10, fontSize: 10));
                }
                Map<String, int> counts = {"CHEST": 0, "BACK": 0, "LEGS": 0, "SHOULDERS": 0, "ARMS": 0};
                for (var doc in snapshot.data!.docs) {
                  var data = doc.data() as Map<String, dynamic>;
                  String part = (data['muscleGroup'] ?? "").toString().toUpperCase();
                  if (counts.containsKey(part)) {
                    counts[part] = counts[part]! + 1;
                  }
                }
                int maxCount = counts.values.reduce((a, b) => a > b ? a : b);
                if (maxCount == 0) maxCount = 1;
                return Column(
                  children: counts.entries.map((entry) {
                    double progress = entry.value / maxCount;
                    return _buildMuscleProgress(entry.key, progress, entry.value);
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMuscleProgress(String part, double value, int rawCount) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(part, style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
              Text("$rawCount SESSIONS", style: TextStyle(color: muscleCyan, fontSize: 8, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: LinearProgressIndicator(
              value: value,
              backgroundColor: Colors.white.withOpacity(0.05),
              color: muscleCyan.withOpacity(0.6),
              minHeight: 4,
            ),
          ),
        ],
      ),
    );
  }

  void _showMonthlySummary() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: BoxDecoration(
          color: const Color(0xFF0D0D0F),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(35)),
          border: Border.all(color: muscleCyan.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(2))),
            const Padding(
              padding: EdgeInsets.all(24.0),
              child: Text("SESSION ARCHIVE", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 2)),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('users').doc(currentUid).collection('trainLogs').orderBy('timestamp', descending: true).snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                  if (snapshot.data!.docs.isEmpty) return const Center(child: Text("ARCHIVE EMPTY", style: TextStyle(color: Colors.white10, fontSize: 10, letterSpacing: 2)));
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      var doc = snapshot.data!.docs[index];
                      var data = doc.data() as Map<String, dynamic>;
                      DateTime date = (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now();
                      return Dismissible(
                        key: Key(doc.id),
                        direction: DismissDirection.endToStart,
                        onDismissed: (direction) {
                          FirebaseFirestore.instance.collection('users').doc(currentUid).collection('trainLogs').doc(doc.id).delete();
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("SESSION REMOVED", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10)), backgroundColor: Colors.redAccent, duration: Duration(seconds: 1)));
                        },
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(color: Colors.redAccent.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                          child: const Icon(Icons.delete_sweep_rounded, color: Colors.redAccent),
                        ),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(color: Colors.white.withOpacity(0.03), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white.withOpacity(0.02))),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(data['muscleGroup']?.toString().toUpperCase() ?? "UNKNOWN", style: TextStyle(color: muscleCyan, fontSize: 12, fontWeight: FontWeight.w900)),
                                  const SizedBox(height: 4),
                                  Text(DateFormat('EEEE, MMM d • hh:mm a').format(date), style: const TextStyle(color: Colors.white38, fontSize: 10)),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(8)),
                                child: Text("LVL ${data['energyLevel'] ?? 3}", style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return GestureDetector(
      onTap: () => AuthService().logout(),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: Colors.redAccent.withOpacity(0.1),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: Colors.redAccent.withOpacity(0.2)),
        ),
        child: const Center(
          child: Text("TERMINATE SESSION", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 2)),
        ),
      ),
    );
  }
}