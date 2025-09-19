import 'package:flutter/material.dart';

class GlowPlusButton extends StatelessWidget {
  final VoidCallback onPressed;

  const GlowPlusButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD9B0FF).withOpacity(0.7),
            blurRadius: 25,
            spreadRadius: 2,
            offset: const Offset(0, 0),
          ),
        ],
        borderRadius: BorderRadius.circular(50),
      ),
      child: FloatingActionButton(
        onPressed: onPressed,
        backgroundColor: const Color(0xFF643D88),
        foregroundColor: const Color(0xFFD9B0FF),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50),
          side: const BorderSide(
            color: Color(0xFFD9B0FF),
            width: 3,
          ),
        ),
        child: const Icon(Icons.add, size: 30),
      ),
    );
  }
}