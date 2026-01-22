import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class TrainScreen extends StatefulWidget {
  const TrainScreen({super.key});

  @override
  State<TrainScreen> createState() => _TrainScreenState();
}

class _TrainScreenState extends State<TrainScreen> {
  int? _energyLevel;
  final List<String> _selectedMuscleGroups = [];
  final List<String> _muscleGroups = [
    'Chest', 'Back', 'Legs', 'Arms', 'Biceps', 'Triceps', 'Shoulders', 'Core', 'Cardio'
  ];

  final Color trainColor = const Color(0xFF00BFA5);
  final Color obsidianBg = const Color(0xFF08080A);
  final Color glassBg = const Color(0xFF121214);

  void _saveEnergyLevel() {
    if (_energyLevel != null) {
      final String todayId = DateFormat('yyyy-MM-dd').format(DateTime.now());
      FirebaseFirestore.instance.collection('dailyVitals').doc(todayId).set({
        'energyLevel': _energyLevel,
        'timestamp': Timestamp.now(),
      }, SetOptions(merge: true));
      _showSnackBar('ENERGY SYNCHRONIZED');
    }
  }

  void _saveTrainedMuscles() {
    if (_selectedMuscleGroups.isNotEmpty) {
      final String todayId = DateFormat('yyyy-MM-dd').format(DateTime.now());
      FirebaseFirestore.instance.collection('dailyVitals').doc(todayId).set({
        'trainedMuscles': _selectedMuscleGroups,
        'lastTrainedTimestamp': Timestamp.now(),
      }, SetOptions(merge: true));
      _showSnackBar('TARGETS LOGGED');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: trainColor,
        behavior: SnackBarBehavior.floating,
        content: Text(message, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: obsidianBg,
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
                color: trainColor.withOpacity(0.08),
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
                      _buildEnergyCard(),
                      const SizedBox(height: 20),
                      _buildMuscleCard(),
                      const SizedBox(height: 20),
                      _buildVitalsCard(),
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
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 25),
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
              Text("PHYSICAL ENGINE", style: TextStyle(color: Colors.white38, fontSize: 11, letterSpacing: 1.5, fontWeight: FontWeight.w900)),
              Text("TRAINING", style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEnergyCard() {
    return _buildGlassContainer(
      title: "ENERGY CHECK-IN",
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [1, 2, 3, 4, 5].map((val) {
              List<String> emojis = ['😞', '😐', '🙂', '😊', '🤩'];
              bool isSelected = _energyLevel == val;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _energyLevel = val),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected ? trainColor.withOpacity(0.15) : Colors.white.withOpacity(0.02),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: isSelected ? trainColor : Colors.white10),
                    ),
                    child: Center(
                      child: Text(emojis[val - 1], style: const TextStyle(fontSize: 22)),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          _buildActionBtn("SYNC ENERGY", _energyLevel != null ? _saveEnergyLevel : null),
        ],
      ),
    );
  }

  Widget _buildMuscleCard() {
    return _buildGlassContainer(
      title: "LOG TARGETS",
      child: Column(
        children: [
          Wrap(
            spacing: 8.0,
            runSpacing: 10.0,
            alignment: WrapAlignment.center,
            children: _muscleGroups.map((muscle) {
              bool isSelected = _selectedMuscleGroups.contains(muscle);
              return FilterChip(
                label: Text(muscle, style: TextStyle(color: isSelected ? Colors.black : Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                selected: isSelected,
                onSelected: (bool selected) {
                  setState(() {
                    selected ? _selectedMuscleGroups.add(muscle) : _selectedMuscleGroups.remove(muscle);
                  });
                },
                backgroundColor: glassBg,
                selectedColor: trainColor,
                checkmarkColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 4),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: isSelected ? trainColor : Colors.white10)
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          _buildActionBtn("LOG WORKOUT", _selectedMuscleGroups.isNotEmpty ? _saveTrainedMuscles : null),
        ],
      ),
    );
  }

  Widget _buildVitalsCard() {
    final String todayId = DateFormat('yyyy-MM-dd').format(DateTime.now());

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('dailyVitals').doc(todayId).snapshots(),
      builder: (context, snapshot) {
        String currentWeight = "60";

        if (snapshot.hasData && snapshot.data!.exists) {
          var data = snapshot.data!.data() as Map<String, dynamic>;
          if (data.containsKey('weight')) {
            currentWeight = data['weight'].toString();
          }
        }

        return _buildGlassContainer(
          title: "HARDWARE METRICS",
          child: Column(
            children: [
              _buildVitalTile(Icons.directions_walk_rounded, "Movement", "Daily steps log"),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () => _showWeightUpdateDialog(context),
                child: _buildVitalTile(
                    Icons.monitor_weight_rounded,
                    "Body Mass",
                    "$currentWeight KG",
                    isAdd: true
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGlassContainer({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        color: glassBg,
        border: Border.all(color: trainColor.withOpacity(0.1), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(color: trainColor, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }

  Widget _buildActionBtn(String label, VoidCallback? onTap) {
    bool isActive = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isActive ? trainColor : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Center(
          child: Text(label, style: TextStyle(color: isActive ? Colors.black : Colors.white24, fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1.5)),
        ),
      ),
    );
  }

  Widget _buildVitalTile(IconData icon, String title, String subtitle, {bool isAdd = false}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.02),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Icon(icon, color: trainColor, size: 20),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                Text(subtitle, style: const TextStyle(color: Colors.white24, fontSize: 11), overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          if (isAdd) Icon(Icons.add_circle_outline_rounded, color: trainColor.withOpacity(0.5), size: 18),
        ],
      ),
    );
  }

  void _showWeightUpdateDialog(BuildContext context) {
    final TextEditingController weightController = TextEditingController(text: "60");
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: glassBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28), side: BorderSide(color: trainColor.withOpacity(0.2))),
        title: const Text("UPDATE MASS", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16)),
        content: TextField(
          controller: weightController,
          keyboardType: TextInputType.number,
          autofocus: true,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          decoration: InputDecoration(
            suffixText: "KG",
            suffixStyle: TextStyle(color: trainColor),
            filled: true,
            fillColor: Colors.white.withOpacity(0.03),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("CANCEL", style: TextStyle(color: Colors.white24))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: trainColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            onPressed: () async {
              final String todayId = DateFormat('yyyy-MM-dd').format(DateTime.now());
              await FirebaseFirestore.instance.collection('dailyVitals').doc(todayId).set({
                'weight': weightController.text.trim(),
                'timestamp': Timestamp.now(),
              }, SetOptions(merge: true));
              Navigator.pop(context);
            },
            child: const Text("SAVE", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}