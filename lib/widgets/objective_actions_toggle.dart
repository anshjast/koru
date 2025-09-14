// lib/widgets/objective_actions_toggle.dart

import 'package:flutter/material.dart';

class ObjectiveActionsToggle extends StatelessWidget {
  final bool isDone;
  final VoidCallback onDone;
  final VoidCallback onDelete;

  const ObjectiveActionsToggle({
    super.key,
    required this.isDone,
    required this.onDone,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      width: 150,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[700]!, width: 1.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          // Done button
          Expanded(
            child: GestureDetector(
              onTap: onDone,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: isDone ? const Color(0xFF5C6BC0) : Colors.transparent, // Indigo when done
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(7),
                    bottomLeft: Radius.circular(7),
                  ),
                ),
                child: Center(
                  child: Text(
                    "Done",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isDone ? Colors.white : Colors.grey[400],
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Delete button
          Expanded(
            child: GestureDetector(
              onTap: onDelete,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: const BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(7),
                    bottomRight: Radius.circular(7),
                  ),
                ),
                child: Center(
                  child: Text(
                    "Delete",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.red[300],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}