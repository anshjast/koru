import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:koru/models/auth_service.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final Color primaryAccent = const Color(0xFFE0E0E0);
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
            top: -100,
            right: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: primaryAccent.withOpacity(0.03),
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
                String name = userData['name'] ?? "UNKNOWN_USER";
                String status = userData['status'] ?? "B.TECH FINAL YEAR";
                double weight = (userData['currentWeight'] as num?)?.toDouble() ?? 0.0;
                double height = (userData['height'] as num?)?.toDouble() ?? 168.0;

                return Column(
                  children: [
                    _buildHeader(context),
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        children: [
                          _buildProfileCard(name, status),
                          const SizedBox(height: 32),
                          const Text("BIOMETRIC CONFIGURATION",
                              style: TextStyle(color: Colors.white24, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 2)),
                          const SizedBox(height: 16),
                          _buildVitalsRow(weight.toString(), height.toString()),
                          const SizedBox(height: 32),
                          Text("CLEAR DATA",
                              style: TextStyle(color: Colors.redAccent.withOpacity(0.5), fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 2)),
                          const SizedBox(height: 16),
                          _buildDangerZone(),
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
          const Text("SYSTEM IDENTITY",
              style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
        ],
      ),
    );
  }

  Widget _buildProfileCard(String name, String status) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: glassBg,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.white.withOpacity(0.05),
            child: const Icon(Icons.person_outline, color: Colors.white, size: 30),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name.toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 1)),
                Text(status, style: const TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVitalsRow(String weight, String height) {
    return Row(
      children: [
        Expanded(child: _buildMetricBox("CURRENT MASS", "$weight KG")),
        const SizedBox(width: 16),
        Expanded(child: _buildMetricBox("SYSTEM HEIGHT", "$height CM")),
      ],
    );
  }

  Widget _buildMetricBox(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: glassBg,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withOpacity(0.03)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.white24, fontSize: 9, fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildDangerZone() {
    return Column(
      children: [
        _buildActionButton("LOGOUT SESSION", Colors.white24, () => AuthService().logout()),
        const SizedBox(height: 12),
        _buildActionButton("WIPE LOCAL CACHE", Colors.redAccent.withOpacity(0.2), () {
          // Placeholder for local cache clearing logic
        }),
      ],
    );
  }

  Widget _buildActionButton(String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 2)),
        ),
      ),
    );
  }
}