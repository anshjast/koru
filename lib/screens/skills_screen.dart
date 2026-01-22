import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SkillsScreen extends StatefulWidget {
  const SkillsScreen({super.key});

  @override
  State<SkillsScreen> createState() => _SkillsScreenState();
}

class _SkillsScreenState extends State<SkillsScreen> {
  final _skillsCollection = FirebaseFirestore.instance.collection('skills');

  final Color primaryAccent = Colors.grey;
  final Color obsidianBg = const Color(0xFF08080A);
  final Color glassBg = const Color(0xFF121214);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: obsidianBg,
      body: Stack(
        children: [
          Positioned(
            top: -100,
            left: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.03),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: _skillsCollection.snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (context, index) {
                          var skill = snapshot.data!.docs[index];
                          double level = (skill['level'] ?? 0.0) / 100;

                          return _buildSkillCard(skill['name'], level, skill.id);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.white,
        onPressed: _showAddSkillDialog,
        child: const Icon(Icons.architecture_rounded, color: Colors.black),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 25),
      child: Row(
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("SKILLS IN PROGRESS", style: TextStyle(color: Colors.white38, fontSize: 11, letterSpacing: 1.5, fontWeight: FontWeight.w900)),
              Text("SKILLS STACK", style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
            ],
          ),
          const Spacer(),
          Icon(Icons.construction_rounded, color: primaryAccent),
        ],
      ),
    );
  }

  Widget _buildSkillCard(String name, double level, String id) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: glassBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(name.toUpperCase(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 1)),
              Text("${(level * 100).toInt()}%", style: const TextStyle(color: Colors.white38, fontSize: 11, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: level,
            backgroundColor: Colors.white.withOpacity(0.05),
            color: Colors.white,
            minHeight: 2,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                icon: const Icon(Icons.add_circle_outline, color: Colors.white10, size: 20),
                onPressed: () => _updateLevel(id, (level * 100) + 5),
              ),
              IconButton(
                icon: const Icon(Icons.remove_circle_outline, color: Colors.white10, size: 20),
                onPressed: () => _updateLevel(id, (level * 100) - 5),
              ),
            ],
          )
        ],
      ),
    );
  }

  void _updateLevel(String id, double newLevel) {
    _skillsCollection.doc(id).update({'level': newLevel.clamp(0, 100)});
  }

  void _showAddSkillDialog() {
    final textController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: glassBg,
        title: const Text("NEW SKILL", style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: textController,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(hintText: "e.g., Flutter API Integration", hintStyle: TextStyle(color: Colors.white10)),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("CANCEL")),
          TextButton(onPressed: () {
            if (textController.text.isNotEmpty) {
              _skillsCollection.add({'name': textController.text, 'level': 10.0});
              Navigator.pop(context);
            }
          }, child: const Text("ADD")),
        ],
      ),
    );
  }
}