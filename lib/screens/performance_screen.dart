import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'dart:math';

class PerformanceHub extends StatelessWidget {
  const PerformanceHub({super.key});

  final Color performanceBlue = const Color(0xFF2E5BFF);
  final Color obsidianBg = const Color(0xFF08080A);
  final Color glassBg = const Color(0xFF121214);

  String? get currentUid => FirebaseAuth.instance.currentUser?.uid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: obsidianBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text("PERFORMANCE OS",
            style: TextStyle(color: performanceBlue, fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 2)),
        centerTitle: true,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('users').doc(currentUid).snapshots(),
        builder: (context, userSnapshot) {
          if (!userSnapshot.hasData) return const Center(child: CircularProgressIndicator(color: Color(0xFF2E5BFF)));

          var userData = userSnapshot.data!.data() as Map<String, dynamic>;
          double weight = (userData['currentWeight'] as num?)?.toDouble() ?? 60.0;
          double height = (userData['height'] as num?)?.toDouble() ?? 168.0;
          double neck = (userData['neck'] as num?)?.toDouble() ?? 38.0;
          double waist = (userData['waist'] as num?)?.toDouble() ?? 80.0;

          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            children: [
              _buildAdvancedDiagnostic(),
              const SizedBox(height: 24),
              _buildHardwareAudit(weight, height, neck, waist),
              const SizedBox(height: 24),
              _buildTechTree(weight),
              const SizedBox(height: 50),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAdvancedDiagnostic() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(currentUid)
          .collection('trainLogs')
          .snapshots(),
      builder: (context, snapshot) {
        Map<String, DateTime> lastTrained = {};
        if (snapshot.hasData) {
          for (var doc in snapshot.data!.docs) {
            String part = (doc['muscleGroup'] ?? '').toString().toUpperCase().trim();
            Timestamp? ts = doc['timestamp'] as Timestamp?;
            if (ts != null) {
              if (lastTrained[part] == null || ts.toDate().isAfter(lastTrained[part]!)) {
                lastTrained[part] = ts.toDate();
              }
            }
          }
        }

        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: glassBg,
            borderRadius: BorderRadius.circular(35),
            border: Border.all(color: performanceBlue.withOpacity(0.2)),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("SYSTEM DIAGNOSTIC", style: TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
                  Icon(Icons.biotech_rounded, color: performanceBlue, size: 18),
                ],
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 320,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Opacity(
                      opacity: 0.2,
                      child: Image.asset(
                        'assets/images/muscle_wireframe.png',
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) => const Icon(Icons.accessibility_new_rounded, size: 200, color: Colors.white10),
                      ),
                    ),
                    _positionGlow("SHOULDERS", lastTrained['SHOULDERS'], top: 55, left: 80),
                    _positionGlow("CHEST", lastTrained['CHEST'], top: 75, left: 135),
                    _positionGlow("BACK", lastTrained['BACK'], top: 75, right: 135),
                    _positionGlow("ARMS", lastTrained['ARMS'], top: 110, left: 65),
                    _positionGlow("CORE", lastTrained['CORE'], top: 120, left: 140),
                    _positionGlow("LEGS", lastTrained['LEGS'], bottom: 60, left: 125),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Text("LATEST SCAN: ${DateFormat('HH:mm').format(DateTime.now())}",
                  style: const TextStyle(color: Colors.white10, fontSize: 8, fontWeight: FontWeight.bold)),
            ],
          ),
        );
      },
    );
  }

  Widget _positionGlow(String label, DateTime? lastDate, {double? top, double? left, double? right, double? bottom}) {
    int days = lastDate != null ? DateTime.now().difference(lastDate).inDays : 99;
    Color statusColor = days <= 2 ? performanceBlue : (days <= 5 ? Colors.white24 : Colors.redAccent.withOpacity(0.5));
    bool isGlowing = days <= 2;

    return Positioned(
      top: top, left: left, right: right, bottom: bottom,
      child: Column(
        children: [
          Container(
            width: 8, height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: statusColor,
              boxShadow: isGlowing ? [BoxShadow(color: performanceBlue.withOpacity(0.8), blurRadius: 15, spreadRadius: 2)] : [],
            ),
          ),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(color: statusColor, fontSize: 6, fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }

  Widget _buildHardwareAudit(double weight, double height, double neck, double waist) {
    double bodyFat = 86.010 * (log(max(1, waist - neck)) / ln10) - 70.041 * (log(height) / ln10) + 36.76;
    if (bodyFat.isNaN || bodyFat.isInfinite || bodyFat < 0) bodyFat = 15.0;
    double lbm = weight * (1 - (bodyFat / 100));

    return Row(
      children: [
        Expanded(child: _auditCard("LEAN MASS", "${lbm.toStringAsFixed(1)} KG")),
        const SizedBox(width: 16),
        Expanded(child: _auditCard("BODY FAT", "${bodyFat.toStringAsFixed(1)} %")),
      ],
    );
  }

  Widget _auditCard(String title, String val) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: glassBg,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: performanceBlue.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.white38, fontSize: 9, fontWeight: FontWeight.w900)),
          const SizedBox(height: 10),
          Text(val, style: TextStyle(color: performanceBlue, fontSize: 20, fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }

  Widget _buildTechTree(double weight) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: glassBg,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("HARDWARE MILESTONES", style: TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2)),
          const SizedBox(height: 24),
          _treeNode("LVL 1: MASS FOUNDATION", "Reach 65 KG Weight", weight >= 65),
          _treeNode("LVL 2: ENGINE STRENGTH", "1.0x BW Bench Press Est.", false),
          _treeNode("LVL 3: PEAK PERFORMANCE", "Reach 79 KG Final Target", weight >= 79),
        ],
      ),
    );
  }

  Widget _treeNode(String title, String subtitle, bool isUnlocked) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        children: [
          Icon(isUnlocked ? Icons.verified_user_rounded : Icons.lock_person_rounded,
              color: isUnlocked ? performanceBlue : Colors.white10, size: 20),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(color: isUnlocked ? Colors.white : Colors.white24, fontSize: 12, fontWeight: FontWeight.bold)),
              Text(subtitle, style: const TextStyle(color: Colors.white10, fontSize: 9)),
            ],
          )
        ],
      ),
    );
  }
}