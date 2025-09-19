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
      // --- THE FIX IS HERE: We are using a ListView ---
      // This allows the screen to scroll if the cards are too tall for the screen.
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
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
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20), // Adds spacing between cards

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
                          // TODO: Add logic for adding water
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Add'),
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
                          // TODO: Add logic for adding calories
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Add'),
                      ),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const CalorieTrackerScreen()),
                          );
                        },
                        icon: const Icon(Icons.bar_chart),
                        label: const Text('Total'),
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

