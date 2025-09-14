import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void showCalorieDialog({
  required BuildContext context,
  DocumentSnapshot? doc,
}) {
  final _calorieLogCollection = FirebaseFirestore.instance.collection('calorieLog');
  final bool isEditing = doc != null;
  final itemController = TextEditingController(text: isEditing ? doc!['item'] : '');
  final caloriesController = TextEditingController(text: isEditing ? doc!['calories'].toString() : '');

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(isEditing ? 'Edit Entry' : 'Add Calorie Entry'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: itemController,
              autofocus: true,
              decoration: const InputDecoration(labelText: 'Food Item'),
            ),
            TextField(
              controller: caloriesController,
              decoration: const InputDecoration(labelText: 'Calories'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final String item = itemController.text.trim();
              final int? calories = int.tryParse(caloriesController.text.trim());

              if (item.isNotEmpty && calories != null) {
                final entry = {
                  'item': item,
                  'calories': calories,
                  'timestamp': Timestamp.now(),
                };

                if (isEditing) {
                  _calorieLogCollection.doc(doc.id).update(entry);
                } else {
                  _calorieLogCollection.add(entry);
                }
                Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      );
    },
  );
}
