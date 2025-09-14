// lib/widgets/gradient_card.dart

import 'package:flutter/material.dart';

class GradientCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;

  const GradientCard({
    super.key,
    required this.child,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        // --- UPDATED LIGHT RED GRADIENT ---
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFEF5350), // Light Red
            Color(0xFF5C6BC0), // Indigo
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(15),
              child: Center(
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}