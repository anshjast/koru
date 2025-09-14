// lib/screens/meals_library_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:koru/widgets/gradient_card.dart';
import 'package:koru/widgets/meal_dialog.dart';

class MealsLibraryScreen extends StatefulWidget {
  const MealsLibraryScreen({super.key});

  @override
  State<MealsLibraryScreen> createState() => _MealsLibraryScreenState();
}

class _MealsLibraryScreenState extends State<MealsLibraryScreen> {
  final _mealsCollection = FirebaseFirestore.instance.collection('meals');
  final _searchController = TextEditingController();
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    // Listen for changes in the search bar
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('My Meals'),
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: Column(
        children: [
          // --- SEARCH BAR ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by name or tag...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[900],
              ),
            ),
          ),
          // --- MEALS LIST ---
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _mealsCollection.orderBy('name').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text(
                      'Your meals library is empty.\nTap the + button to add your first meal!',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16),
                    ),
                  );
                }

                // --- SEARCH FILTERING LOGIC ---
                final filteredDocs = snapshot.data!.docs.where((doc) {
                  final mealData = doc.data() as Map<String, dynamic>;
                  final name = (mealData['name'] as String? ?? '').toLowerCase();
                  final tags = List<String>.from(mealData['tags'] ?? [])
                      .map((tag) => tag.toLowerCase())
                      .toList();

                  // Return true if the name or any tag contains the search query
                  return name.contains(_searchQuery) ||
                      tags.any((tag) => tag.contains(_searchQuery));
                }).toList();

                if (filteredDocs.isEmpty) {
                  return const Center(child: Text('No meals found.'));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: filteredDocs.length,
                  itemBuilder: (context, index) {
                    var doc = filteredDocs[index];
                    var mealData = doc.data() as Map<String, dynamic>;
                    List<String> tags = List<String>.from(mealData['tags'] ?? []);

                    List<Color>? cardGradient;
                    if (tags.isNotEmpty) {
                      final firstTagColor = tagColors[tags.first];
                      if (firstTagColor != null) {
                        cardGradient = [firstTagColor.withOpacity(0.8), firstTagColor];
                      }
                    }

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: GradientCard(
                        gradientColors: cardGradient,
                        onTap: () => showMealDialog(context: context, doc: doc),
                        child: ListTile(
                          title: Text(mealData['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                          subtitle: Text(
                            "Calories: ${mealData['calories']}\nTags: ${tags.join(', ')}",
                            style: TextStyle(color: Colors.white.withOpacity(0.8)),
                          ),
                          trailing: const Icon(Icons.edit_note),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showMealDialog(context: context),
        child: const Icon(Icons.add),
        tooltip: 'Add Meal',
      ),
    );
  }
}

