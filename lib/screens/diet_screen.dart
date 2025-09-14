// lib/screens/diet_screen.dart

import 'package:flutter/material.dart';
import 'package:koru/screens/calorie_tracker_screen.dart';
import 'package:koru/screens/meals_library_screen.dart';
import 'package:koru/screens/water_intake_screen.dart';
import 'package:koru/widgets/gradient_card.dart';
import 'package:koru/widgets/meal_dialog.dart';

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
      // --- THE FIX: Use a ListView instead of a Column ---
      // This makes the screen scrollable and prevents overflows.
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Add some vertical spacing between cards
          const SizedBox(height: 20),

          // --- "My Meals" Card ---
          GradientCard(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
              child: Column(
                children: [
                  const ListTile(
                    leading: Icon(Icons.restaurant_menu, size: 32),
                    title: Text('My Meals', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    subtitle: Text('Your library of go-to recipes'),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          showMealDialog(context: context);
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Add'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[800],
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const MealsLibraryScreen()),
                          );
                        },
                        icon: const Icon(Icons.menu_book),
                        label: const Text('Library'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[800],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // --- "Water Intake" Card ---
          GradientCard(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
              child: Column(
                children: [
                  const ListTile(
                    leading: Icon(Icons.local_drink, size: 32),
                    title: Text('Water Intake', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    subtitle: Text('Track your daily hydration'),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          print('Add Water tapped!');
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Add'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[800],
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const WaterIntakeScreen()),
                          );
                        },
                        icon: const Icon(Icons.history),
                        label: const Text('Water Log'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[800],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // --- "Daily Calories" Card ---
          GradientCard(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
              child: Column(
                children: [
                  const ListTile(
                    leading: Icon(Icons.calculate, size: 32),
                    title: Text('Daily Calories', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    subtitle: Text('Log your daily calorie consumption'),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          print('Add Calories tapped!');
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Add'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[800],
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const CalorieTrackerScreen()),
                          );
                        },
                        icon: const Icon(Icons.bar_chart),
                        label: const Text('Total Calorie'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[800],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

