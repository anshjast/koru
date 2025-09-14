// lib/screens/dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:koru/screens/train_screen.dart'; // <-- MAKE SURE THIS LINE IS HERE
import 'package:koru/widgets/gradient_app_bar.dart';
import 'package:koru/widgets/gradient_card.dart';
import 'package:koru/screens/goals_screen.dart';
import 'package:koru/screens/avoid_screen.dart';
import 'package:koru/screens/diet_screen.dart';

class KoruModule {
  final String title;
  final IconData icon;

  KoruModule({required this.title, required this.icon});
}

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<KoruModule> modules = [
      KoruModule(title: "Today's Focus", icon: Icons.center_focus_strong),
      KoruModule(title: 'Train', icon: Icons.fitness_center),
      KoruModule(title: 'Goals', icon: Icons.flag),
      KoruModule(title: 'Diet', icon: Icons.restaurant_menu),
      KoruModule(title: 'Schedule', icon: Icons.watch_later),
      KoruModule(title: 'Skills', icon: Icons.construction),
      KoruModule(title: 'Avoid', icon: Icons.do_not_disturb_on),
      KoruModule(title: 'Upgrade', icon: Icons.spa),
    ];

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: const GradientAppBar(),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 16.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.8,
          ),
          itemCount: modules.length,
          itemBuilder: (context, index) {
            final module = modules[index];

            return GradientCard(
              onTap: () {
                if (module.title == 'Train') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const TrainScreen()),
                  );
                } else if (module.title == 'Goals') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const GoalsScreen()),
                  );
                } else if (module.title == 'Avoid') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AvoidScreen()),
                  );
                } else if (module.title == 'Diet') { // <-- ADD THIS BLOCK
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const DietScreen()),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${module.title} screen is not yet built.')),
                  );
                }
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(module.icon, size: 48),
                  const SizedBox(height: 12),
                  Text(
                    module.title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}