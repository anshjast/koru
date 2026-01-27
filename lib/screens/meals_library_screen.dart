import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:koru/widgets/meal_dialog.dart';

class MealsLibraryScreen extends StatefulWidget {
  const MealsLibraryScreen({super.key});

  @override
  State<MealsLibraryScreen> createState() => _MealsLibraryScreenState();
}

class _MealsLibraryScreenState extends State<MealsLibraryScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = "";
  final Color accentColor = const Color(0xFFFF9F0A);

  String? get currentUid => FirebaseAuth.instance.currentUser?.uid;

  CollectionReference get _mealsCollection => FirebaseFirestore.instance
      .collection('users')
      .doc(currentUid)
      .collection('meals');

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text.toLowerCase());
    });
  }

  void _showDeleteConfirmation(DocumentSnapshot doc) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0D0D0F),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24), side: const BorderSide(color: Colors.redAccent, width: 0.5)),
        title: const Text("DELETE MEAL?", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("CANCEL", style: TextStyle(color: Colors.white38))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () {
              if (currentUid != null) {
                doc.reference.delete();
              }
              Navigator.pop(context);
            },
            child: const Text("DELETE", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (currentUid == null) {
      return const Scaffold(
        backgroundColor: Color(0xFF08080A),
        body: Center(child: Text("ACCESS DENIED: PLEASE LOGIN", style: TextStyle(color: Colors.white24))),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF08080A),
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                _buildHeader(context),
                _buildSearchBar(),
                Expanded(child: _buildMealList()),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: accentColor,
        onPressed: () => showMealDialog(context: context),
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.05), border: Border.all(color: Colors.white10)),
              child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
            ),
          ),
          const SizedBox(width: 20),
          const Text("MEAL LIBRARY", style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      child: TextField(
        controller: _searchController,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: 'Search meals...',
          hintStyle: const TextStyle(color: Colors.white24),
          prefixIcon: Icon(Icons.search, color: accentColor),
          filled: true,
          fillColor: const Color(0xFF121214),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
        ),
      ),
    );
  }

  Widget _buildMealList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _mealsCollection.orderBy('name').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final docs = snapshot.data!.docs.where((doc) => doc['name'].toString().toLowerCase().contains(_searchQuery)).toList();
        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final meal = docs[index].data() as Map<String, dynamic>;
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(color: const Color(0xFF121214), borderRadius: BorderRadius.circular(20)),
              child: ListTile(
                onTap: () => showMealDialog(context: context, doc: docs[index]),
                onLongPress: () => _showDeleteConfirmation(docs[index]),
                title: Text(meal['name'].toUpperCase(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                subtitle: Text("${meal['calories']} kcal", style: const TextStyle(color: Colors.white38)),
                trailing: const Icon(Icons.edit_outlined, color: Colors.white10, size: 18),
              ),
            );
          },
        );
      },
    );
  }
}