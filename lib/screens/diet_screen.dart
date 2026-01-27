import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:koru/screens/calorie_tracker_screen.dart';
import 'package:koru/screens/meals_library_screen.dart';
import 'package:koru/screens/water_intake_screen.dart';
import 'package:koru/widgets/meal_dialog.dart';

class DietScreen extends StatelessWidget {
  const DietScreen({super.key});

  final Color accentColor = const Color(0xFFFF9F0A);

  String? get currentUid => FirebaseAuth.instance.currentUser?.uid;

  Future<void> logToDailyIntake({
    required String name,
    required int calories,
    required int protein,
    required int carbs,
    required int fats,
  }) async {
    if (currentUid == null) return;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUid)
        .collection('dailyLog')
        .add({
      'name': name,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fats': fats,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  @override
  Widget build(BuildContext context) {
    if (currentUid == null) {
      return const Scaffold(
        backgroundColor: Color(0xFF08080A),
        body: Center(child: Text("ACCESS DENIED: PLEASE LOGIN", style: TextStyle(color: Colors.white24))),
      );
    }

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
                color: accentColor.withOpacity(0.1),
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
                      _buildGlassCard(
                        context,
                        title: "MEAL LIBRARY",
                        desc: "Fuel your body with precision",
                        icon: Icons.restaurant_rounded,
                        onAdd: () => showMealDialog(context: context),
                        onLog: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const MealsLibraryScreen())),
                      ),
                      const SizedBox(height: 20),
                      _buildGlassCard(
                        context,
                        title: "HYDRATION",
                        desc: "Track daily water intake",
                        icon: Icons.water_drop_rounded,
                        onAdd: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const WaterIntakeScreen())),
                        onLog: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const WaterIntakeScreen())),
                      ),
                      const SizedBox(height: 20),
                      _buildGlassCard(
                        context,
                        title: "CALORIE LOG",
                        desc: "Manage your energy balance",
                        icon: Icons.bolt_rounded,
                        onAdd: () => _showAddCalorieDialog(context),
                        onLog: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const CalorieTrackerScreen())),
                      ),
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
              Text("NUTRITION", style: TextStyle(color: Colors.white38, fontSize: 12, letterSpacing: 2, fontWeight: FontWeight.w900)),
              Text("DIET HUB", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGlassCard(BuildContext context, {required String title, required String desc, required IconData icon, required VoidCallback onAdd, required VoidCallback onLog}) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [accentColor.withOpacity(0.15), accentColor.withOpacity(0.02)],
        ),
        border: Border.all(color: accentColor.withOpacity(0.3), width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: accentColor, size: 32),
                const Icon(Icons.more_horiz, color: Colors.white24),
              ],
            ),
            const SizedBox(height: 20),
            Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 1)),
            Text(desc, style: const TextStyle(color: Colors.white38, fontSize: 13)),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(child: _buildActionBtn("ADD", onAdd, true)),
                const SizedBox(width: 12),
                Expanded(child: _buildActionBtn("VIEW", onLog, false)),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildActionBtn(String label, VoidCallback tap, bool primary) {
    return GestureDetector(
      onTap: tap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: primary ? accentColor : Colors.transparent,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: accentColor, width: 1.5),
          boxShadow: primary ? [BoxShadow(color: accentColor.withOpacity(0.3), blurRadius: 10)] : [],
        ),
        child: Center(
          child: Text(label, style: TextStyle(color: primary ? Colors.black : accentColor, fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1.5)),
        ),
      ),
    );
  }

  void _showAddCalorieDialog(BuildContext context) {
    final Color calorieColor = const Color(0xFFFF9F0A);
    final nameController = TextEditingController();
    final kcalController = TextEditingController();
    final proController = TextEditingController();
    final carbController = TextEditingController();
    final fatController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0D0D0F),
        insetPadding: const EdgeInsets.symmetric(horizontal: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
          side: BorderSide(color: calorieColor.withOpacity(0.2)),
        ),
        title: const Text("LOG NUTRITION",
            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
        content: SizedBox(
          width: MediaQuery.of(context).size.width,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildNeonTextField("Meal Name", Icons.restaurant_rounded, calorieColor, controller: nameController),
                const SizedBox(height: 16),
                _buildNeonTextField("Calories (kcal)", Icons.bolt_rounded, calorieColor, controller: kcalController, isNumber: true),
                const SizedBox(height: 24),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text("MACRONUTRIENTS (g)",
                      style: TextStyle(color: Colors.white24, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
                ),
                const SizedBox(height: 12),
                _buildNeonTextField("PRO", Icons.fitness_center, Colors.blueAccent, controller: proController, isNumber: true),
                const SizedBox(height: 12),
                _buildNeonTextField("CARB", Icons.grain, Colors.greenAccent, controller: carbController, isNumber: true),
                const SizedBox(height: 12),
                _buildNeonTextField("FAT", Icons.invert_colors, Colors.redAccent, controller: fatController, isNumber: true),
                const SizedBox(height: 25),
                const Text("— OR —", style: TextStyle(color: Colors.white24, fontSize: 10, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const MealsLibraryScreen()));
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: calorieColor.withOpacity(0.5)),
                      color: calorieColor.withOpacity(0.05),
                    ),
                    child: Center(
                      child: Text("SELECT FROM LIBRARY",
                          style: TextStyle(color: calorieColor, fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("CANCEL", style: TextStyle(color: Colors.white38)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: calorieColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () async {
              if (currentUid == null) return;
              final String mealName = nameController.text.trim();
              final int kcal = int.tryParse(kcalController.text) ?? 0;
              final int pro = int.tryParse(proController.text) ?? 0;
              final int carb = int.tryParse(carbController.text) ?? 0;
              final int fat = int.tryParse(fatController.text) ?? 0;

              final mealData = {
                'name': mealName.isEmpty ? "Quick Meal" : mealName,
                'calories': kcal,
                'protein': pro,
                'carbs': carb,
                'fats': fat,
                'tags': ['Snack'],
              };

              await FirebaseFirestore.instance
                  .collection('users')
                  .doc(currentUid)
                  .collection('meals')
                  .add(mealData);

              await logToDailyIntake(
                name: mealData['name'] as String,
                calories: kcal,
                protein: pro,
                carbs: carb,
                fats: fat,
              );

              Navigator.pop(context);
            },
            child: const Text("LOG", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildNeonTextField(String hint, IconData icon, Color color, {required TextEditingController controller, bool isNumber = false}) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: color, size: 18),
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white24),
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.white10),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: color.withOpacity(0.5)),
        ),
      ),
    );
  }
}