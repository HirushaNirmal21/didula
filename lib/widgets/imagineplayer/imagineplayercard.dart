import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gradient_borders/gradient_borders.dart';

class SpecialPlayerCard extends StatefulWidget {
  final String title;
  final String name;
  final String imageUrl;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const SpecialPlayerCard({
    super.key,
    required this.title,
    required this.name,
    required this.imageUrl,
    this.onTap,
    this.onDelete,
  });

  @override
  State<SpecialPlayerCard> createState() => _SpecialPlayerCardState();
}

class _SpecialPlayerCardState extends State<SpecialPlayerCard> {
  String userRole = "user";
  bool isLoading = true;

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

      if (!mounted) return;

      if (doc.exists && doc.data() != null) {
        setState(() {
          userRole = doc.data()!['role'] ?? 'user';
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Container(
        width: MediaQuery.of(context).size.width * 0.44,
        height: 190,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          color: Colors.white.withOpacity(0.03),
        ),
        child: const Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Color(0xFFFCF6BA),
            ),
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.44,
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          // 🌌 Glassmorphic Background
          color: const Color(0xFFBF953F).withOpacity(0.06),
          borderRadius: BorderRadius.circular(25),

          // ✨ Gold Gradient Border
          border: const GradientBoxBorder(
            width: 2,
            gradient: LinearGradient(
              colors: [
                Color(0xFFBF953F), // Deep Gold
                Color(0xFFFCF6BA), // Light Gold Highlight
                Color(0xFFB38728), // Darker Metallic Gold
                Color(0xFFFBF5B7), // Soft Highlight
                Color(0xFFAA771C), // Deep Bronze Gold
              ],
              stops: [0.0, 0.25, 0.5, 0.75, 1.0],
            ),
          ),

          // 🌟 Glow Shadow
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFBF953F).withOpacity(0.18),
              blurRadius: 20,
              spreadRadius: 1,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 🔴 Delete Button
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (userRole == "admin" && widget.name != "Add Player")
                  GestureDetector(
                    onTap: widget.onDelete,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
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
                if (!(userRole == "admin" && widget.name != "Add Player"))
                  const SizedBox(height: 20),
              ],
            ),

            // 👤 MVP Profile Image with Gold Ring
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFBF953F), width: 1.5),
              ),
              child: CircleAvatar(
                radius: 40,
                backgroundColor: Colors.white10,
                backgroundImage: widget.imageUrl.isNotEmpty
                    ? NetworkImage(widget.imageUrl)
                    : null,
                child: widget.imageUrl.isEmpty
                    ? const Icon(Icons.person, size: 40, color: Colors.white60)
                    : null,
              ),
            ),
            const SizedBox(height: 12),

            // 📝 MVP Name
            Text(
              widget.name,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),

            // 🏆 Title and Medal
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
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFFFCF6BA),
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Text("🏅", style: TextStyle(fontSize: 14)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
