import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gradient_borders/gradient_borders.dart';

class DualWinnerCard extends StatefulWidget {
  final String title;
  final String player1Name;
  final String player2Name;
  final String player1Image;
  final String player2Image;
  final Gradient gradient;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const DualWinnerCard({
    super.key,
    required this.title,
    required this.player1Name,
    required this.player2Name,
    required this.player1Image,
    required this.player2Image,
    required this.gradient,
    this.onTap,
    this.onDelete,
  });

  @override
  State<DualWinnerCard> createState() => _DualWinnerCardState();
}

class _DualWinnerCardState extends State<DualWinnerCard> {
  bool isLoading = true;
  String userRole = "user";

  @override
  void initState() {
    super.initState();
    _fetchUserRole();
  }

  Future<void> _fetchUserRole() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        if (mounted) setState(() => isLoading = false);
        return;
      }
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (mounted) {
        setState(() {
          userRole = doc.data()?['role'] ?? 'user';
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Color _getGlowColor() {
    String titleLower = widget.title.toLowerCase();
    if (titleLower.contains('1st')) {
      return const Color(0xFFBF953F).withOpacity(0.15);
    } else if (titleLower.contains('2nd')) {
      return const Color(0xFFBDBDBD).withOpacity(0.10);
    } else if (titleLower.contains('3rd')) {
      return const Color(0xFF82572C).withOpacity(0.10);
    }
    return Colors.transparent;
  }

  @override
  Widget build(BuildContext context) {
    final bool isP1ImageValid =
        widget.player1Image.isNotEmpty &&
        widget.player1Image.startsWith('http');
    final bool isP2ImageValid =
        widget.player2Image.isNotEmpty &&
        widget.player2Image.startsWith('http');
    final glowColor = _getGlowColor();

    return GestureDetector(
      onTap: userRole == "admin" ? widget.onTap : null,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.04),
          borderRadius: BorderRadius.circular(25),

          border: GradientBoxBorder(width: 2, gradient: widget.gradient),

          // 🌟 Neon Glow Shadow
          boxShadow: [
            if (glowColor != Colors.transparent)
              BoxShadow(
                color: glowColor,
                blurRadius: 20,
                spreadRadius: 1,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 🏆 Header Row: Title & Delete Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                //
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black38,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    widget.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),

                if (userRole == "admin")
                  GestureDetector(
                    onTap: widget.onDelete,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.black45,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close_rounded,
                        color: Colors.redAccent,
                        size: 18,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // 👥 Players Area (Side by Side)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Player 1
                Expanded(
                  child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: GradientBoxBorder(
                            width: 1.5,
                            gradient: widget.gradient,
                          ),
                        ),
                        child: CircleAvatar(
                          radius: 35,
                          backgroundColor: Colors.white10,
                          backgroundImage: isP1ImageValid
                              ? NetworkImage(widget.player1Image)
                              : null,
                          child: !isP1ImageValid
                              ? const Icon(
                                  Icons.person,
                                  color: Colors.white60,
                                  size: 30,
                                )
                              : null,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.player1Name,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),

                // 🤝 Handshake Center Icon
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Icon(
                    Icons.handshake_rounded,
                    color: Colors.white.withOpacity(0.6),
                    size: 32,
                  ),
                ),

                // Player 2
                Expanded(
                  child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: GradientBoxBorder(
                            width: 1.5,
                            gradient: widget.gradient,
                          ),
                        ),
                        child: CircleAvatar(
                          radius: 35,
                          backgroundColor: Colors.white10,
                          backgroundImage: isP2ImageValid
                              ? NetworkImage(widget.player2Image)
                              : null,
                          child: !isP2ImageValid
                              ? const Icon(
                                  Icons.person,
                                  color: Colors.white60,
                                  size: 30,
                                )
                              : null,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.player2Name,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // 🏷️ Bottom Subtitle Badge
            Text(
              "Dual Winners 👥",
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 11,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
