import 'package:flutter/material.dart';
import 'package:koru/screens/calorie_tracker_screen.dart';
import 'package:koru/screens/meals_library_screen.dart';
import 'package:koru/screens/water_intake_screen.dart';
import 'package:koru/widgets/meal_dialog.dart';

class DietScreen extends StatelessWidget {
  const DietScreen({super.key});

  final Color accentColor = const Color(0xFFFF9F0A);

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
                        onAdd: () {},
                        onLog: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const WaterIntakeScreen())),
                      ),
                      const SizedBox(height: 20),
                      _buildGlassCard(
                        context,
                        title: "CALORIE LOG",
                        desc: "Manage your energy balance",
                        icon: Icons.bolt_rounded,
                        onAdd: () {},
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
}