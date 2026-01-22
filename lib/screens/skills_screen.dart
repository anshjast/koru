import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SkillsScreen extends StatefulWidget {
  const SkillsScreen({super.key});

  @override
  State<SkillsScreen> createState() => _SkillsScreenState();
}

class _SkillsScreenState extends State<SkillsScreen> {
  final _skillsCollection = FirebaseFirestore.instance.collection('skills');

  final Color primaryAccent = Colors.amberAccent;
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
                color: primaryAccent.withOpacity(0.08),
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
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator(color: Colors.amberAccent));
                      }
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const Center(
                          child: Text("NO SKILLS DEPLOYED",
                              style: TextStyle(color: Colors.white10, fontWeight: FontWeight.w900, letterSpacing: 2)),
                        );
                      }

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
        backgroundColor: primaryAccent,
        onPressed: _showAddSkillDialog,
        child: const Icon(Icons.add_rounded, color: Colors.black, size: 32),
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
              Text("PROFICIENCY STACK", style: TextStyle(color: Colors.white38, fontSize: 11, letterSpacing: 1.5, fontWeight: FontWeight.w900)),
              Text("SKILLS HUB", style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
            ],
          ),
          const Spacer(),
          Icon(Icons.architecture_rounded, color: primaryAccent),
        ],
      ),
    );
  }

  Widget _buildSkillCard(String name, double level, String id) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
              Text(name.toUpperCase(),
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 1)),
              Text("${(level * 100).toInt()}%",
                  style: TextStyle(color: primaryAccent, fontSize: 11, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: level.clamp(0.0, 1.0),
              backgroundColor: Colors.white.withOpacity(0.05),
              color: primaryAccent,
              minHeight: 4,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _buildAdjustButton(Icons.add_rounded, () => _updateLevel(id, (level * 100) + 1)),
              const SizedBox(width: 8),
              _buildAdjustButton(Icons.remove_rounded, () => _updateLevel(id, (level * 100) - 1)),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded, color: Colors.white10, size: 20),
                onPressed: () => _showDeleteConfirmation(id, name),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildAdjustButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: primaryAccent.withOpacity(0.05),
          shape: BoxShape.circle,
          border: Border.all(color: primaryAccent.withOpacity(0.1)),
        ),
        child: Icon(icon, color: primaryAccent, size: 18),
      ),
    );
  }

  void _updateLevel(String id, double newLevel) {
    _skillsCollection.doc(id).update({'level': newLevel.clamp(0.0, 100.0)});
  }

  void _showDeleteConfirmation(String id, String name) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: glassBg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
          side: const BorderSide(color: Colors.redAccent, width: 0.5),
        ),
        title: const Text("TERMINATE SKILL?",
            style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w900, fontSize: 16)),
        content: Text("Purge all progress data for '${name.toUpperCase()}'?",
            style: const TextStyle(color: Colors.white38, fontSize: 13)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("CANCEL", style: TextStyle(color: Colors.white24))),
          TextButton(
            onPressed: () {
              _skillsCollection.doc(id).delete();
              Navigator.pop(context);
            },
            child: const Text("TERMINATE", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );
  }

  void _showAddSkillDialog() {
    final textController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: glassBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28), side: BorderSide(color: primaryAccent.withOpacity(0.2))),
        title: const Text("INITIALIZE SKILL", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16)),
        content: TextField(
          controller: textController,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: "Skill name...",
            hintStyle: const TextStyle(color: Colors.white10),
            filled: true,
            fillColor: Colors.white.withOpacity(0.03),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("CANCEL", style: TextStyle(color: Colors.white24))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: primaryAccent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            onPressed: () {
              if (textController.text.isNotEmpty) {
                _skillsCollection.add({'name': textController.text.trim(), 'level': 0.0});
                Navigator.pop(context);
              }
            },
            child: const Text("DEPLOY", style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );
  }
}