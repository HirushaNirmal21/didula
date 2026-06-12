import 'package:flutter/material.dart';
import 'package:gradient_borders/gradient_borders.dart';

class Custombutton extends StatelessWidget {
  final String text;
  final double width;
  final VoidCallback onPressed;

  const Custombutton({
    super.key,
    required this.text,
    required this.width,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: 50,
      margin: const EdgeInsets.symmetric(vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(14),
        border: const GradientBoxBorder(
          width: 1.5,
          gradient: LinearGradient(
            colors: [
              Color(0xFF00D2FF), // Electric Cyan
              Color(0xFF0066FF), // Neon Blue
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
        ),

        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00D2FF).withOpacity(0.12),
            blurRadius: 12,
            spreadRadius: -2,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: TextButton(
        style: TextButton.styleFrom(
          backgroundColor: Colors.transparent,

          foregroundColor: const Color(0xFF00D2FF).withOpacity(0.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        onPressed: onPressed,
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 15,
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.8,
          ),
        ),
      ),
    );
  }
}
