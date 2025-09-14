// lib/widgets/animated_emoji_button.dart

import 'package:flutter/material.dart'; // <-- THIS IS THE FIX

class AnimatedEmojiButton extends StatelessWidget {
  final String emoji;
  final bool isSelected;
  final VoidCallback onTap;

  const AnimatedEmojiButton({
    super.key,
    required this.emoji,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedScale(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        scale: isSelected ? 1.3 : 1.0,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: isSelected ? 1.0 : 0.6,
          child: Text(
            emoji,
            style: const TextStyle(fontSize: 36),
          ),
        ),
      ),
    );
  }
}