// lib/widgets/gradient_card.dart

import 'package:flutter/material.dart';

class GradientCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final List<Color>? gradientColors; // <-- New optional property

  const GradientCard({
    super.key,
    required this.child,
    this.onTap,
    this.gradientColors,
  });

  @override
  Widget build(BuildContext context) {
    // Use the provided colors, or fall back to the default red/indigo gradient
    final colors = gradientColors ??
        [const Color(0xFFEF5350), const Color(0xFF5C6BC0)];

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
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
