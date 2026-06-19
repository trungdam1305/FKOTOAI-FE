import 'package:flutter/material.dart';

class GradientBackground extends StatelessWidget {
  final Widget child;

  const GradientBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF97CADB),
            Color(0xFFD6E8EE),
            Color(0xFFF8F8F8),
            Colors.white,
          ],
          stops: [0.0, 0.4, 0.7, 1.0],
        ),
      ),
      child: child,
    );
  }
}