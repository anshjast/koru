import 'package:flutter/material.dart';

class AnimatedMuscleChip extends StatefulWidget {
  final String label;
  final bool isSelected;
  final ValueChanged<bool> onSelected;

  const AnimatedMuscleChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onSelected,
  });

  @override
  State<AnimatedMuscleChip> createState() => _AnimatedMuscleChipState();
}

class _AnimatedMuscleChipState extends State<AnimatedMuscleChip> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final selectedColor = const Color(0xFFEF5350);
    final unselectedColor = Colors.grey[800];

    return GestureDetector(
      onTap: () => widget.onSelected(!widget.isSelected),
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: widget.isSelected ? selectedColor : unselectedColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 4,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: AnimatedScale(
          duration: const Duration(milliseconds: 200),
          scale: _isPressed ? 0.95 : 1.0,
          child: Text(
            widget.label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}