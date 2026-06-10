import 'package:flutter/material.dart';

class Custominput extends StatelessWidget {
  final TextEditingController controller;
  final String lableText;
  final IconData? icon;
  final bool obscureText;
  final String? Function(String?)? validator;

  const Custominput({
    super.key,
    required this.controller,
    required this.lableText,
    required this.obscureText,
    this.validator,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        validator: validator,
        cursorColor: const Color(0xFF00D2FF),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          labelText: lableText,

          labelStyle: TextStyle(
            color: Colors.white.withOpacity(0.5),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),

          floatingLabelStyle: const TextStyle(
            color: Color(0xFF00D2FF),
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),

          filled: true,

          fillColor: Colors.white.withOpacity(0.03),

          // 👤 Prefix Icon Setup
          prefixIcon: icon != null
              ? Icon(icon, color: Colors.white.withOpacity(0.5), size: 20)
              : null,

          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(
              color: Colors.white.withOpacity(0.1),
              width: 1,
            ),
          ),

          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(
              color: Color(0xFF00D2FF), // Neon Cyan Border
              width: 1.5,
            ),
          ),

          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(
              color: Colors.redAccent.withOpacity(0.5),
              width: 1,
            ),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
          ),

          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
        ),
      ),
    );
  }
}
