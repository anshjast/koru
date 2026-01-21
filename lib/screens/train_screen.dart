import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:koru/widgets/animated_emoji_button.dart';
import 'package:koru/widgets/animated_muscle_chip.dart';

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

  void _saveEnergyLevel() {
    if (_energyLevel != null) {
      final String todayId = DateFormat('yyyy-MM-dd').format(DateTime.now());
      FirebaseFirestore.instance.collection('dailyVitals').doc(todayId).set({
        'energyLevel': _energyLevel,
        'timestamp': Timestamp.now(),
      }, SetOptions(merge: true));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: trainColor,
          content: const Text('Energy level saved!', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        ),
      );
    }
  }
  void _showWeightUpdateDialog(BuildContext context) {
    final TextEditingController weightController = TextEditingController(text: "60");
    final Color trainColor = const Color(0xFF00BFA5);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0D0D0F),
        insetPadding: const EdgeInsets.symmetric(horizontal: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
          side: BorderSide(color: trainColor.withOpacity(0.3)),
        ),
        title: const Text("UPDATE WEIGHT",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 2, fontSize: 16)),
        content: SizedBox(
          width: MediaQuery.of(context).size.width,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("",
                  style: TextStyle(color: Colors.white24, fontSize: 12)),
              const SizedBox(height: 20),
              TextField(
                controller: weightController,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  suffixText: "KG",
                  suffixStyle: TextStyle(color: trainColor, fontWeight: FontWeight.bold),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.05),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: const BorderSide(color: Colors.white10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide(color: trainColor.withOpacity(0.5)),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("CANCEL", style: TextStyle(color: Colors.white38)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: trainColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () async {
              final String todayId = DateFormat('yyyy-MM-dd').format(DateTime.now());
              await FirebaseFirestore.instance.collection('dailyVitals').doc(todayId).set({
                'weight': weightController.text.trim(),
                'weightTimestamp': Timestamp.now(),
              }, SetOptions(merge: true));
              Navigator.pop(context);
            },
            child: const Text("SAVE", style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );
  }

  void _saveTrainedMuscles() {
    if (_selectedMuscleGroups.isNotEmpty) {
      final String todayId = DateFormat('yyyy-MM-dd').format(DateTime.now());
      FirebaseFirestore.instance.collection('dailyVitals').doc(todayId).set({
        'trainedMuscles': _selectedMuscleGroups,
        'lastTrainedTimestamp': Timestamp.now(),
      }, SetOptions(merge: true));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: trainColor,
          content: const Text('Trained muscles logged!', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
              Text("FITNESS", style: TextStyle(color: Colors.white38, fontSize: 11, letterSpacing: 1.5, fontWeight: FontWeight.w900)),
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
          const Text("How are you feeling today?", style: TextStyle(color: Colors.white38, fontSize: 13)),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildEmoji(1, '😞'),
              _buildEmoji(2, '😐'),
              _buildEmoji(3, '🙂'),
              _buildEmoji(4, '😊'),
              _buildEmoji(5, '🤩'),
            ],
          ),
          const SizedBox(height: 24),
          _buildActionBtn("SAVE ENERGY LEVEL", _energyLevel != null ? _saveEnergyLevel : null),
        ],
      ),
    );
  }

  Widget _buildMuscleCard() {
    return _buildGlassContainer(
      title: "LOG TRAINING",
      child: Column(
        children: [
          const Text("Select muscle groups trained", style: TextStyle(color: Colors.white38, fontSize: 13)),
          const SizedBox(height: 20),
          Wrap(
            spacing: 8.0,
            runSpacing: 10.0,
            alignment: WrapAlignment.center,
            children: _muscleGroups.map((muscle) {
              return AnimatedMuscleChip(
                label: muscle,
                isSelected: _selectedMuscleGroups.contains(muscle),
                onSelected: (bool selected) {
                  setState(() {
                    selected ? _selectedMuscleGroups.add(muscle) : _selectedMuscleGroups.remove(muscle);
                  });
                },
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
    return _buildGlassContainer(
      title: "VITALS & TRACKING",
      child: Column(
        children: [
          _buildVitalTile(Icons.directions_walk_rounded, "Steps Today", "Google Fit pending"),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () => _showWeightUpdateDialog(context),
            child: _buildVitalTile(Icons.monitor_weight_rounded, "Body Metrics", "60 KG ", isAdd: true),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassContainer({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [trainColor.withOpacity(0.12), trainColor.withOpacity(0.01)],
        ),
        border: Border.all(color: trainColor.withOpacity(0.2), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 1)),
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
          boxShadow: isActive ? [BoxShadow(color: trainColor.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4))] : [],
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
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Icon(icon, color: trainColor, size: 22),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
              Text(subtitle, style: const TextStyle(color: Colors.white38, fontSize: 11)),
            ],
          ),
          const Spacer(),
          if (isAdd) Icon(Icons.add_circle_outline_rounded, color: trainColor, size: 20),
        ],
      ),
    );
  }

  Widget _buildEmoji(int value, String emoji) {
    return AnimatedEmojiButton(
      emoji: emoji,
      isSelected: _energyLevel == value,
      onTap: () => setState(() => _energyLevel = value),
    );
  }
}