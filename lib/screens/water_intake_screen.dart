import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:koru/screens/water_history_screen.dart';
import 'package:liquid_progress_indicator_v2/liquid_progress_indicator.dart';

class WaterIntakeScreen extends StatefulWidget {
  const WaterIntakeScreen({super.key});

  @override
  State<WaterIntakeScreen> createState() => _WaterIntakeScreenState();
}

class _WaterIntakeScreenState extends State<WaterIntakeScreen> {
  final _waterLogCollection = FirebaseFirestore.instance.collection('waterLog');
  final int _dailyTarget = 2000;
  final int _drinkAmount = 250;
  final Color waterColor = const Color(0xFF00D2FF);

  void _addWaterEntry() {
    _waterLogCollection.add({
      'amount': _drinkAmount,
      'timestamp': Timestamp.now(),
    });
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final startOfToday = DateTime(now.year, now.month, now.day);
    final endOfToday = startOfToday.add(const Duration(days: 1));

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
                color: waterColor.withOpacity(0.08),
              ),
            ),
          ),
          SafeArea(
            child: StreamBuilder<QuerySnapshot>(
              stream: _waterLogCollection
                  .where('timestamp', isGreaterThanOrEqualTo: startOfToday)
                  .where('timestamp', isLessThan: endOfToday)
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                int totalIntake = 0;
                if (snapshot.hasData) {
                  for (var doc in snapshot.data!.docs) {
                    totalIntake += (doc['amount'] as num).toInt();
                  }
                }

                double progress = totalIntake / _dailyTarget;
                if (progress > 1.0) progress = 1.0;

                return Column(
                  children: [
                    _buildHeader(context),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          children: [
                            const SizedBox(height: 30),
                            _buildLiquidIndicator(progress, totalIntake),
                            const SizedBox(height: 50),
                            _buildActionSection(),
                            const SizedBox(height: 40),
                            _buildRecordList(snapshot),
                            const SizedBox(height: 100),
                          ],
                        ),
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
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("HYDRATION", style: TextStyle(color: Colors.white38, fontSize: 11, letterSpacing: 1.5, fontWeight: FontWeight.w900)),
                  Text("WATER INTAKE", style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
                ],
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.history_rounded, color: Colors.lightBlueAccent),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const WaterHistoryScreen())),
          ),
        ],
      ),
    );
  }

  Widget _buildLiquidIndicator(double progress, int current) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 260,
          height: 260,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withOpacity(0.05), width: 8),
            boxShadow: [
              BoxShadow(color: waterColor.withOpacity(0.1), blurRadius: 40, spreadRadius: 5),
            ],
          ),
        ),
        SizedBox(
          width: 230,
          height: 230,
          child: LiquidCircularProgressIndicator(
            value: progress,
            valueColor: AlwaysStoppedAnimation(waterColor.withOpacity(0.6)),
            backgroundColor: Colors.transparent,
            borderColor: Colors.transparent,
            borderWidth: 0,
            direction: Axis.vertical,
            center: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$current',
                  style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 1),
                ),
                Text(
                  '/ $_dailyTarget ml',
                  style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionSection() {
    return Column(
      children: [
        GestureDetector(
          onTap: _addWaterEntry,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 18),
            decoration: BoxDecoration(
              color: waterColor,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(color: waterColor.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 8)),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.add_rounded, color: Colors.black, size: 28),
                const SizedBox(width: 12),
                Text("ADD ${_drinkAmount}ML", style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w900, letterSpacing: 1)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecordList(AsyncSnapshot<QuerySnapshot> snapshot) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("DAILY LOG", style: TextStyle(color: Colors.white24, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 2)),
        const SizedBox(height: 16),
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty)
          const Center(child: Text("No records yet", style: TextStyle(color: Colors.white10, fontSize: 14)))
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var doc = snapshot.data!.docs[index];
              var timestamp = (doc['timestamp'] as Timestamp).toDate();
              return Dismissible(
                key: Key(doc.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  decoration: BoxDecoration(
                    color: Colors.redAccent.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Icon(Icons.delete_sweep_rounded, color: Colors.redAccent),
                ),
                onDismissed: (direction) {
                  _waterLogCollection.doc(doc.id).delete();
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF121214),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: Colors.white.withOpacity(0.05)),
                  ),
                  child: ListTile(
                    leading: Icon(Icons.access_time_filled_rounded, color: waterColor.withOpacity(0.5), size: 20),
                    title: Text(DateFormat.jm().format(timestamp), style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                    trailing: Text('+${doc['amount']} ml', style: TextStyle(color: waterColor, fontWeight: FontWeight.w900, fontSize: 14)),
                  ),
                ),
              );
            },
          ),
      ],
    );
  }
}