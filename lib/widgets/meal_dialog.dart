import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

const Map<String, Color> tagColors = {
  'Breakfast': Colors.yellow,
  'Lunch': Colors.red,
  'Dinner': Colors.blue,
  'Snack': Colors.orange,
};

void showMealDialog({
  required BuildContext context,
  DocumentSnapshot? doc,
}) {
  final _mealsCollection = FirebaseFirestore.instance.collection('meals');
  final bool isEditing = doc != null;
  var mealData = isEditing ? doc.data() as Map<String, dynamic> : {};
  final accentColor = const Color(0xFFFF9F0A);

  final nameController = TextEditingController(text: mealData['name']);
  final caloriesController = TextEditingController(text: mealData['calories']?.toString());
  final proController = TextEditingController(text: mealData['protein']?.toString());
  final carbController = TextEditingController(text: mealData['carbs']?.toString());
  final fatController = TextEditingController(text: mealData['fats']?.toString());
  final descriptionController = TextEditingController(text: mealData['description']);
  final ingredientsController = TextEditingController(text: mealData['ingredients']);

  List<String> selectedTags = List<String>.from(mealData['tags'] ?? []);
  final allTags = ['Breakfast', 'Lunch', 'Dinner', 'Snack'];

  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            backgroundColor: const Color(0xFF0D0D0F),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
              side: BorderSide(color: accentColor.withOpacity(0.5), width: 1),
            ),
            title: Text(
              isEditing ? 'EDIT MEAL' : 'ADD NEW MEAL',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 2, fontSize: 18),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCyberField("Meal Name", Icons.fastfood_rounded, nameController, accentColor),
                  const SizedBox(height: 16),
                  _buildCyberField("Total Calories", Icons.bolt_rounded, caloriesController, accentColor, isNumber: true),
                  const SizedBox(height: 24),

                  const Text('MACRONUTRIENTS (g)', style: TextStyle(color: Colors.white38, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1.5)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _buildCyberField("PRO", Icons.fitness_center, proController, Colors.blueAccent, isNumber: true)),
                      const SizedBox(width: 8),
                      Expanded(child: _buildCyberField("CARB", Icons.grain, carbController, Colors.greenAccent, isNumber: true)),
                      const SizedBox(width: 8),
                      Expanded(child: _buildCyberField("FAT", Icons.invert_colors, fatController, Colors.redAccent, isNumber: true)),
                    ],
                  ),

                  const SizedBox(height: 24),
                  _buildCyberField("Description", Icons.description_rounded, descriptionController, accentColor, maxLines: 2),
                  const SizedBox(height: 16),
                  _buildCyberField("Ingredients", Icons.list_alt_rounded, ingredientsController, accentColor, maxLines: 2),
                  const SizedBox(height: 24),

                  const Text('TAGS', style: TextStyle(color: Colors.white38, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1.5)),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 8.0,
                    children: allTags.map((tag) {
                      final isSelected = selectedTags.contains(tag);
                      final tagBaseColor = tagColors[tag] ?? Colors.grey;

                      return GestureDetector(
                        onTap: () {
                          setDialogState(() {
                            if (isSelected) {
                              selectedTags.remove(tag);
                            } else {
                              selectedTags.add(tag);
                            }
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? tagBaseColor.withOpacity(0.2) : Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected ? tagBaseColor : Colors.white10,
                              width: 1,
                            ),
                          ),
                          child: Text(
                            tag.toUpperCase(),
                            style: TextStyle(
                              color: isSelected ? tagBaseColor : Colors.white38,
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('CANCEL', style: TextStyle(color: Colors.white38, fontWeight: FontWeight.bold, letterSpacing: 1)),
              ),
              Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(color: accentColor.withOpacity(0.2), blurRadius: 15, offset: const Offset(0, 4)),
                  ],
                ),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  onPressed: () {
                    final meal = {
                      'name': nameController.text.trim(),
                      'calories': int.tryParse(caloriesController.text) ?? 0,
                      'protein': int.tryParse(proController.text) ?? 0,
                      'carbs': int.tryParse(carbController.text) ?? 0,
                      'fats': int.tryParse(fatController.text) ?? 0,
                      'description': descriptionController.text.trim(),
                      'ingredients': ingredientsController.text.trim(),
                      'tags': selectedTags,
                      'timestamp': FieldValue.serverTimestamp(),
                    };
                    if (isEditing) {
                      _mealsCollection.doc(doc.id).update(meal);
                    } else {
                      _mealsCollection.add(meal);
                    }
                    Navigator.pop(context);
                  },
                  child: const Text('SAVE MEAL', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900, letterSpacing: 1)),
                ),
              ),
            ],
          );
        },
      );
    },
  );
}

Widget _buildCyberField(String label, IconData icon, TextEditingController controller, Color accent, {int maxLines = 1, bool isNumber = false}) {
  return TextField(
    controller: controller,
    maxLines: maxLines,
    keyboardType: isNumber ? TextInputType.number : TextInputType.text,
    style: const TextStyle(color: Colors.white, fontSize: 14),
    decoration: InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white38, fontSize: 12),
      prefixIcon: Icon(icon, color: accent, size: 20),
      filled: true,
      fillColor: Colors.white.withOpacity(0.03),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.white10),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: accent.withOpacity(0.5)),
      ),
    ),
  );
}