import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:didula_api/models/rulesmodel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'dart:ui';

class RuleWidget extends StatefulWidget {
  final Rulesmodel rule;
  final VoidCallback onDelete;
  final String CurrentUserId;

  const RuleWidget({
    super.key,
    required this.rule,
    required this.onDelete,
    required this.CurrentUserId,
  });

  @override
  State<RuleWidget> createState() => _RuleWidgetState();
}

class _RuleWidgetState extends State<RuleWidget> {
  String userRole = "user";
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserRole();
  }

  Future<void> _fetchUserRole() async {
    // ඔයාගේ Firebase Role Fetch Logic එක
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    setState(() {
      userRole = doc.data()?['role'] ?? 'user';
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 2.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              // ✨ Glassmorphic Fill (ඩාර්ක් තීම් එකට මැච් වෙන්න)
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF0D1527).withOpacity(0.6),
                  const Color(0xFF050914).withOpacity(0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              // ⚡ ලාවට පෙනෙන Cyber Blue Border එක
              border: Border.all(
                width: 1,
                color: const Color(0xFF00D2FF).withOpacity(0.2),
              ),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 6,
              ),
              // 🟦 වම් පැත්තෙන් වැටෙන Neon Rule Number Indicator එක
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF00D2FF).withOpacity(0.1),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFF00D2FF).withOpacity(0.4),
                  ),
                ),
                child: const Icon(
                  Icons.gavel_rounded, // නීති වලට ගැලපෙන සිරාම Icon එකක්
                  color: Color(0xFF00D2FF),
                  size: 18,
                ),
              ),
              title: Text(
                widget.rule.description,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors
                      .white, // සුදු පාට Text එකක් (Dark Background එකට පැහැදිලිව පෙනෙන්න)
                  height: 1.4,
                ),
              ),
              // 👑 Admin කෙනෙක් නම් විතරක් Delete Icon එක කෙලින්ම Card එකේ දකුණු පැත්තේ පෙන්වන්න පුළුවන් (UI UX අතින් වඩාත් සුදුසුයි)
              trailing: userRole == "admin"
                  ? IconButton(
                      icon: const Icon(
                        Icons.delete_outline_rounded,
                        color: Colors.redAccent,
                      ),
                      onPressed: () => _showDeleteDialog(context),
                    )
                  : null,
              onTap: userRole != "admin"
                  ? () => _showPermissionDialog(context)
                  : () => _showDeleteDialog(context),
            ),
          ),
        ),
      ),
    );
  }

  // 🗑️ Rule එක Delete කරන Dialog එක (Text බග් එක Fix කර ඇත)
  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF0D1527),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            "Delete Rule",
            style: TextStyle(color: Colors.white),
          ),
          content: const Text(
            "Are you sure you want to delete this tournament rule?",
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                widget.onDelete();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Rule Deleted Successfully"),
                    backgroundColor: Colors.redAccent,
                  ),
                );
              },
              child: const Text(
                "Delete",
                style: TextStyle(color: Colors.redAccent),
              ),
            ),
          ],
        );
      },
    );
  }

  // ⚠️ Permission නැති බව පෙන්වන Dialog එක
  void _showPermissionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF0D1527),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          content: Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: Colors.amber),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  "Only admins can delete rules.",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
