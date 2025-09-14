// lib/widgets/animated_diet_card.dart

import 'package:flutter/material.dart';

class AnimatedDietCard extends StatefulWidget {
  final Widget child;
  final int delayMilliseconds; // To stagger the animations

  const AnimatedDietCard({
    super.key,
    required this.child,
    this.delayMilliseconds = 0,
  });

  @override
  State<AnimatedDietCard> createState() => _AnimatedDietCardState();
}

class _AnimatedDietCardState extends State<AnimatedDietCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _slide;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    // Start the animation after the specified delay
    Future.delayed(Duration(milliseconds: widget.delayMilliseconds), () {
      if (mounted) {
        _controller.forward();
      }
    });

    _slide = Tween<double>(begin: 30, end: 0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    _fade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slide.value),
          child: Opacity(
            opacity: _fade.value,
            child: child,
          ),
        );
      },
      child: widget.child,
    );
  }
}
