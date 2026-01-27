import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:koru/screens/dashboard_screen.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _nameController = TextEditingController();
  final _heightController = TextEditingController(text: "168");
  final _weightController = TextEditingController(text: "60");
  final _targetWeightController = TextEditingController(text: "79");

  final Color accentColor = const Color(0xFFBB86FC);
  final Color obsidianBg = const Color(0xFF08080A);
  final Color glassBg = const Color(0xFF121214);

  Future<void> _completeSetup() async {
    final String? uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'name': _nameController.text.trim(),
        'height': double.tryParse(_heightController.text) ?? 168.0,
        'currentWeight': double.tryParse(_weightController.text) ?? 60.0,
        'targetWeight': double.tryParse(_targetWeightController.text) ?? 79.0,
        'status': 'B.TECH FINAL YEAR',
        'setupComplete': true,
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const DashboardScreen()),
              (route) => false,
        );
      }
    } catch (e) {
      debugPrint("Setup Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: obsidianBg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("CALIBRATING IDENTITY", style: TextStyle(color: accentColor, fontSize: 11, letterSpacing: 2, fontWeight: FontWeight.w900)),
              const SizedBox(height: 8),
              const Text("PROFILE SETUP", style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900)),
              const SizedBox(height: 40),
              _buildInputGroup("FULL NAME", _nameController, Icons.person_outline, false),
              const SizedBox(height: 20),
              _buildInputGroup("HEIGHT (CM)", _heightController, Icons.height, true),
              const SizedBox(height: 20),
              _buildInputGroup("CURRENT MASS (KG)", _weightController, Icons.monitor_weight_outlined, true),
              const SizedBox(height: 20),
              _buildInputGroup("TARGET MASS (KG)", _targetWeightController, Icons.track_changes_rounded, true),
              const SizedBox(height: 40),
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputGroup(String label, TextEditingController ctrl, IconData icon, bool isNum) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: glassBg, borderRadius: BorderRadius.circular(25), border: Border.all(color: Colors.white.withOpacity(0.05))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.white38, fontSize: 9, fontWeight: FontWeight.w900)),
          TextField(
            controller: ctrl,
            keyboardType: isNum ? TextInputType.number : TextInputType.text,
            style: const TextStyle(color: Colors.white, fontSize: 16),
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: accentColor.withOpacity(0.5), size: 18),
              enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white.withOpacity(0.05))),
              focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: accentColor)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return GestureDetector(
      onTap: _completeSetup,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(color: accentColor, borderRadius: BorderRadius.circular(20)),
        child: const Center(child: Text("INITIALIZE SYSTEM", style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900, letterSpacing: 1.5))),
      ),
    );
  }
}