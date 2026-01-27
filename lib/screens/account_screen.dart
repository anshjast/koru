import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../models/auth_service.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final Color primaryAccent = const Color(0xFFE0E0E0);
  final Color obsidianBg = const Color(0xFF08080A);
  final Color glassBg = const Color(0xFF121214);
  final String _todayId = DateFormat('yyyy-MM-dd').format(DateTime.now());

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
            child: Column(
              children: [
                _buildHeader(context),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    children: [
                      _buildEditableProfile(),
                      const SizedBox(height: 32),
                      const Text("PHYSICAL SNAPSHOT",
                          style: TextStyle(color: Colors.white24, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 2)),
                      const SizedBox(height: 16),
                      _buildEditableVitals(),
                      const SizedBox(height: 32),
                      const Text("SYNC STATUS",
                          style: TextStyle(color: Colors.white24, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 2)),
                      const SizedBox(height: 16),
                      _buildSyncCard(),
                      const SizedBox(height: 40),
                      _buildLogoutButton(),
                      const SizedBox(height: 40),
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
          const Text("SYSTEM IDENTITY",
              style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
        ],
      ),
    );
  }

  Widget _buildEditableProfile() {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('users').doc(currentUid).snapshots(),
      builder: (context, snapshot) {
        String name = "USER_UNKNOWN";
        String status = "B.TECH FINAL YEAR";

        if (snapshot.hasData && snapshot.data!.exists) {
          var data = snapshot.data!.data() as Map<String, dynamic>;
          name = data['name'] ?? name;
          status = data['status'] ?? status;
        }

        return GestureDetector(
          onTap: () => _showEditProfileDialog(name, status),
          child: Container(
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
                  backgroundColor: primaryAccent.withOpacity(0.05),
                  child: Icon(Icons.account_circle_outlined, color: primaryAccent, size: 35),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name.toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 1)),
                      Text(status, style: const TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
                    ],
                  ),
                ),
                Icon(Icons.edit_note_rounded, color: primaryAccent.withOpacity(0.2)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEditableVitals() {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(currentUid)
          .collection('dailyVitals')
          .doc(_todayId)
          .snapshots(),
      builder: (context, snapshot) {
        String weight = "60";
        String height = "168";

        if (snapshot.hasData && snapshot.data!.exists) {
          var data = snapshot.data!.data() as Map<String, dynamic>;
          weight = data['weight']?.toString() ?? weight;
          height = data['height']?.toString() ?? height;
        }

        return Row(
          children: [
            Expanded(child: _buildMetricBox("MASS", "$weight KG", () => _showEditVitalsDialog("weight", weight))),
            const SizedBox(width: 16),
            Expanded(child: _buildMetricBox("HEIGHT", "$height CM", () => _showEditVitalsDialog("height", height))),
          ],
        );
      },
    );
  }

  Widget _buildMetricBox(String label, String value, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
      ),
    );
  }

  Widget _buildSyncCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.02),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          const Icon(Icons.cloud_done_rounded, color: Colors.blueAccent, size: 20),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("FIRESTORE CLOUD", style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
              Text(FirebaseAuth.instance.currentUser?.email ?? "Guest Mode",
                  style: const TextStyle(color: Colors.white24, fontSize: 11)),
            ],
          ),
          const Spacer(),
          Text(DateFormat('HH:mm').format(DateTime.now()),
              style: TextStyle(color: primaryAccent.withOpacity(0.3), fontSize: 10, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildLogoutButton() {
    return GestureDetector(
      onTap: () async {
        await AuthService().logout();
        if (mounted) Navigator.pop(context);
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.redAccent.withOpacity(0.3)),
        ),
        child: const Center(
          child: Text("TERMINATE SESSION",
              style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 2)),
        ),
      ),
    );
  }

  void _showEditProfileDialog(String currentName, String currentStatus) {
    final nameCtrl = TextEditingController(text: currentName);
    final statusCtrl = TextEditingController(text: currentStatus);
    _showTerminalDialog(
      title: "EDIT IDENTITY",
      fields: [
        _buildTextField(nameCtrl, "USER NAME"),
        const SizedBox(height: 12),
        _buildTextField(statusCtrl, "SYSTEM STATUS"),
      ],
      onSave: () {
        if (currentUid != null) {
          FirebaseFirestore.instance.collection('users').doc(currentUid).set({
            'name': nameCtrl.text.trim(),
            'status': statusCtrl.text.trim(),
          }, SetOptions(merge: true));
        }
      },
    );
  }

  void _showEditVitalsDialog(String field, String currentVal) {
    final ctrl = TextEditingController(text: currentVal);
    _showTerminalDialog(
      title: "UPDATE ${field.toUpperCase()}",
      fields: [_buildTextField(ctrl, "NEW VALUE")],
      onSave: () {
        if (currentUid != null) {
          FirebaseFirestore.instance
              .collection('users')
              .doc(currentUid)
              .collection('dailyVitals')
              .doc(_todayId)
              .set({
            field: ctrl.text.trim(),
            'timestamp': Timestamp.now(),
          }, SetOptions(merge: true));
        }
      },
    );
  }

  void _showTerminalDialog({required String title, required List<Widget> fields, required VoidCallback onSave}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: glassBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28), side: BorderSide(color: primaryAccent.withOpacity(0.1))),
        title: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14)),
        content: Column(mainAxisSize: MainAxisSize.min, children: fields),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("ABORT", style: TextStyle(color: Colors.white24))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: primaryAccent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            onPressed: () { onSave(); Navigator.pop(context); },
            child: const Text("COMMIT", style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController ctrl, String hint) {
    return TextField(
      controller: ctrl,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: hint,
        labelStyle: const TextStyle(color: Colors.white10, fontSize: 12),
        filled: true,
        fillColor: Colors.white.withOpacity(0.03),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
      ),
    );
  }
}