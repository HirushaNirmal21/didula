import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gradient_borders/gradient_borders.dart';

class WinnerPlaceCard extends StatefulWidget {
  final String title;
  final String name;
  final String imageUrl;
  final Gradient borderGradient; // 👈 1. කාඩ් බෝඩර් එකට ග්‍රේඩියන්ට් එක
  final Gradient avatarGradient; // 👈 2. Avatar බෝඩර් එකට ග්‍රේඩියන්ට් එක
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const WinnerPlaceCard({
    super.key,
    required this.title,
    required this.name,
    required this.imageUrl,
    required this.borderGradient, // Required කළා
    required this.avatarGradient, // Required කළා
    this.onTap,
    this.onDelete,
  });

  @override
  State<WinnerPlaceCard> createState() => _WinnerPlaceCardState();
}

class _WinnerPlaceCardState extends State<WinnerPlaceCard> {
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

  Map<String, dynamic> _getPlaceDetails() {
    String titleLower = widget.title.toLowerCase();
    if (titleLower.contains('1st')) {
      return {
        'medal': '🥇',
        'glowColor': const Color(0xFFBF953F).withOpacity(0.18),
      };
    } else if (titleLower.contains('2nd')) {
      return {
        'medal': '🥈',
        'glowColor': const Color(0xFFBDBDBD).withOpacity(0.12),
      };
    } else if (titleLower.contains('3rd')) {
      return {
        'medal': '🥉',
        'glowColor': const Color(0xFF82572C).withOpacity(0.12),
      };
    } else {
      return {'medal': '🏅', 'glowColor': Colors.transparent};
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isImageValid =
        widget.imageUrl.isNotEmpty && widget.imageUrl.startsWith('http');
    final placeDetails = _getPlaceDetails();

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.04), // Glassmorphic background
          borderRadius: BorderRadius.circular(25),

          // ✨ මෙතනට වදින්නේ කාඩ් එකේ බෝඩර් ග්‍රේඩියන්ට් එක:
          border: GradientBoxBorder(width: 2, gradient: widget.borderGradient),

          boxShadow: [
            if (placeDetails['glowColor'] != Colors.transparent)
              BoxShadow(
                color: placeDetails['glowColor'],
                blurRadius: 18,
                spreadRadius: 1,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Delete Button
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (userRole == "admin" && widget.name != "Add Winner")
                  GestureDetector(
                    onTap: widget.onDelete,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.black45,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close_rounded,
                        color: Colors.redAccent,
                        size: 16,
                      ),
                    ),
                  ),
                if (!(userRole == "admin" && widget.name != "Add Winner"))
                  const SizedBox(height: 20),
              ],
            ),

            // 👤 Player Avatar
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                // ✨ මෙතනට වදින්නේ Avatar එක වටේට ඔයා දෙන වෙනම ග්‍රේඩියන්ට් එක:
                border: GradientBoxBorder(
                  width: 1.5,
                  gradient: widget.avatarGradient,
                ),
              ),
              child: CircleAvatar(
                radius: 38,
                backgroundColor: Colors.white10,
                backgroundImage: isImageValid
                    ? NetworkImage(widget.imageUrl)
                    : null,
                child: !isImageValid
                    ? const Icon(Icons.person, color: Colors.white60, size: 35)
                    : null,
              ),
            ),
            const SizedBox(height: 12),

            // Winner Name
            Text(
              widget.name,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 6),

            // Place Title Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black38,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: Text(
                      widget.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    placeDetails['medal'],
                    style: const TextStyle(fontSize: 13),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
