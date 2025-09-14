// lib/screens/diet_screen.dart

import 'package:flutter/material.dart';
import 'package:koru/screens/calorie_tracker_screen.dart';
import 'package:koru/screens/meals_library_screen.dart';
import 'package:koru/screens/water_intake_screen.dart';
import 'package:koru/widgets/gradient_card.dart';

class DietScreen extends StatelessWidget {
  const DietScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Diet'),
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          // --- THIS IS THE FIX ---
          // This will distribute the cards evenly across the vertical space.
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // My Meals Card
            GradientCard(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MealsLibraryScreen()),
                );
              },
              child: const ListTile(
                leading: Icon(Icons.restaurant_menu, size: 32),
                title: Text('My Meals', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                subtitle: Text('Your library of go-to recipes'),
              ),
            ),
            // The SizedBoxes are no longer needed

            // Water Intake Card
            GradientCard(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const WaterIntakeScreen()),
                );
              },
              child: const ListTile(
                leading: Icon(Icons.local_drink, size: 32),
                title: Text('Water Intake', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                subtitle: Text('Track your daily hydration'),
              ),
            ),
            // The SizedBoxes are no longer needed

            // Daily Calorie Measurer Card
            GradientCard(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CalorieTrackerScreen()),
                );
              },
              child: const ListTile(
                leading: Icon(Icons.calculate, size: 32),
                title: Text('Daily Calorie Measurer', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                subtitle: Text('Log your daily calorie consumption'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

