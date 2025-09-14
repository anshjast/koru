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

  final nameController = TextEditingController(text: mealData['name']);
  final caloriesController = TextEditingController(text: mealData['calories']);
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
            title: Text(isEditing ? 'Edit Meal' : 'Add New Meal'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Meal Name')),
                  TextField(controller: caloriesController, decoration: const InputDecoration(labelText: 'Total Calories'), keyboardType: TextInputType.number),
                  TextField(controller: descriptionController, decoration: const InputDecoration(labelText: 'Description'), maxLines: 2),
                  TextField(controller: ingredientsController, decoration: const InputDecoration(labelText: 'Ingredients (comma separated)'), maxLines: 2),
                  const SizedBox(height: 20),
                  const Text('Tags', style: TextStyle(fontWeight: FontWeight.bold)),
                  Wrap(
                    spacing: 8.0,
                    children: allTags.map((tag) {
                      final isSelected = selectedTags.contains(tag);
                      final color = tagColors[tag] ?? Colors.grey;

                      return FilterChip(
                        label: Text(tag),
                        selected: isSelected,
                        backgroundColor: color.withOpacity(0.2),
                        selectedColor: color,
                        checkmarkColor: Colors.white,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : Colors.white70,
                        ),
                        onSelected: (bool selected) {
                          setDialogState(() {
                            if (selected) {
                              selectedTags.add(tag);
                            } else {
                              selectedTags.remove(tag);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  final meal = {
                    'name': nameController.text.trim(),
                    'calories': caloriesController.text.trim(),
                    'description': descriptionController.text.trim(),
                    'ingredients': ingredientsController.text.trim(),
                    'tags': selectedTags,
                  };
                  if (isEditing) {
                    _mealsCollection.doc(doc.id).update(meal);
                  } else {
                    _mealsCollection.add(meal);
                  }
                  Navigator.pop(context);
                },
                child: const Text('Save'),
              ),
            ],
          );
        },
      );
    },
  );
}

