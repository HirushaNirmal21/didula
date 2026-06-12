import 'package:flutter/material.dart';

import 'dart:ui';

class SponsorCard extends StatefulWidget {
  final String imageUrl;
  final String name;
  final VoidCallback onDelete;

  const SponsorCard({
    super.key,
    required this.imageUrl,
    required this.name,
    required this.onDelete,
  });

  @override
  State<SponsorCard> createState() => _SponsorCardState();
}

class _SponsorCardState extends State<SponsorCard> {
  String userRole = "user";
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserRole();
  }

  Future<void> _fetchUserRole() async {
    setState(() {
      userRole = "admin";
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showActionDialog(context),
      child: Container(
        width: 165,
        margin: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                // ✨ Glassmorphic Gradient Fill
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF0D1527).withOpacity(0.7),
                    const Color(0xFF050914).withOpacity(0.9),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                // ⚡ Electric Cyber Outline Border
                border: Border.all(
                  width: 1.5,
                  color: const Color(0xFF00D2FF).withOpacity(0.3),
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00D2FF).withOpacity(0.08),
                    blurRadius: 12,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                    width: 85,
                    height: 85,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.1),
                        width: 1,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(17),
                      child: widget.imageUrl.isNotEmpty
                          ? Image.network(widget.imageUrl, fit: BoxFit.cover)
                          : Container(
                              color: const Color(0xFF1E293B),
                              child: const Icon(
                                Icons.business_rounded,
                                color: Color(0xFF00D2FF),
                                size: 35,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // ✍️ Sponsor Name
                  Text(
                    widget.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),

                  const SizedBox(height: 4),

                  // 🏷️ Futuristic Cyber Sponsor Tag
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00D2FF).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: const Color(0xFF00D2FF).withOpacity(0.4),
                        width: 1,
                      ),
                    ),
                    child: const Text(
                      'SPONSOR',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF00D2FF), // Electric Neon Cyan Text
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showActionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return userRole == "admin"
            ? AlertDialog(
                backgroundColor: const Color(0xFF0D1527),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                title: const Text(
                  "Manage Sponsor",
                  style: TextStyle(color: Colors.white),
                ),
                content: const Text(
                  "Do you want to delete this sponsor?",
                  style: TextStyle(color: Colors.white70),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      "Cancel",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      widget.onDelete();
                      Navigator.pop(context);
                    },
                    child: const Text(
                      "Delete",
                      style: TextStyle(color: Colors.redAccent),
                    ),
                  ),
                ],
              )
            : AlertDialog(
                backgroundColor: const Color(0xFF0D1527),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                content: Row(
                  children: [
                    const Icon(
                      Icons.warning_amber_rounded,
                      color: Colors.amber,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        "You don't have permission to remove sponsors.",
                        style: TextStyle(color: Colors.white.withOpacity(0.9)),
                      ),
                    ),
                  ],
                ),
              );
      },
    );
  }
}
