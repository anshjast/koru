import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

void showMealDialog({
  required BuildContext context,
  DocumentSnapshot? doc,
}) {
  final String? uid = FirebaseAuth.instance.currentUser?.uid;

  final _mealsCollection = FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .collection('meals');

  final bool isEditing = doc != null;
  var mealData = isEditing ? doc.data() as Map<String, dynamic> : {};
  final accentColor = const Color(0xFFFF9F0A);

  final nameController = TextEditingController(text: mealData['name']);
  final caloriesController = TextEditingController(text: mealData['calories']?.toString());
  final proController = TextEditingController(text: mealData['protein']?.toString());
  final carbController = TextEditingController(text: mealData['carbs']?.toString());
  final fatController = TextEditingController(text: mealData['fats']?.toString());

  List<String> selectedTags = List<String>.from(mealData['tags'] ?? []);
  final allTags = ['Breakfast', 'Lunch', 'Dinner', 'Snack'];

  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            backgroundColor: const Color(0xFF0D0D0F),
            insetPadding: const EdgeInsets.symmetric(horizontal: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
              side: BorderSide(color: accentColor.withOpacity(0.3), width: 1),
            ),
            title: Text(
              isEditing ? 'EDIT MEAL' : 'ADD NEW MEAL',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 2, fontSize: 18),
            ),
            content: SizedBox(
              width: MediaQuery.of(context).size.width,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCyberField("Meal Name", Icons.fastfood_rounded, nameController, accentColor),
                    const SizedBox(height: 16),
                    _buildCyberField("Total Calories", Icons.bolt_rounded, caloriesController, accentColor, isNumber: true),
                    const SizedBox(height: 24),

                    const Text('MACRONUTRIENTS (g)',
                        style: TextStyle(color: Colors.white38, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1.5)),
                    const SizedBox(height: 12),

                    _buildCyberField("Protein (g)", Icons.fitness_center, proController, Colors.blueAccent, isNumber: true),
                    const SizedBox(height: 12),
                    _buildCyberField("Carbs (g)", Icons.grain, carbController, Colors.greenAccent, isNumber: true),
                    const SizedBox(height: 12),
                    _buildCyberField("Fats (g)", Icons.invert_colors, fatController, Colors.redAccent, isNumber: true),

                    const SizedBox(height: 24),
                    const Text('TAGS',
                        style: TextStyle(color: Colors.white38, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1.5)),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 8.0,
                      children: allTags.map((tag) {
                        final isSelected = selectedTags.contains(tag);
                        return GestureDetector(
                          onTap: () {
                            setDialogState(() {
                              isSelected ? selectedTags.remove(tag) : selectedTags.add(tag);
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected ? accentColor.withOpacity(0.2) : Colors.white.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: isSelected ? accentColor : Colors.white10),
                            ),
                            child: Text(tag.toUpperCase(),
                                style: TextStyle(color: isSelected ? accentColor : Colors.white38, fontSize: 10, fontWeight: FontWeight.w900)),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('CANCEL', style: TextStyle(color: Colors.white38, fontWeight: FontWeight.bold)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                onPressed: () {
                  if (uid == null) return;

                  final meal = {
                    'name': nameController.text.trim(),
                    'calories': int.tryParse(caloriesController.text) ?? 0,
                    'protein': int.tryParse(proController.text) ?? 0,
                    'carbs': int.tryParse(carbController.text) ?? 0,
                    'fats': int.tryParse(fatController.text) ?? 0,
                    'tags': selectedTags,
                  };

                  if (isEditing) {
                    _mealsCollection.doc(doc.id).update(meal);
                  } else {
                    _mealsCollection.add(meal);
                  }
                  Navigator.pop(context);
                },
                child: const Text('SAVE MEAL', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900)),
              ),
            ],
          );
        },
      );
    },
  );
}

Widget _buildCyberField(String label, IconData icon, TextEditingController controller, Color accent, {bool isNumber = false}) {
  return TextField(
    controller: controller,
    keyboardType: isNumber ? TextInputType.number : TextInputType.text,
    style: const TextStyle(color: Colors.white, fontSize: 14),
    decoration: InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white38, fontSize: 11),
      prefixIcon: Icon(icon, color: accent, size: 18),
      filled: true,
      fillColor: Colors.white.withOpacity(0.03),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Colors.white10)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: accent.withOpacity(0.5))),
      contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
    ),
  );
}