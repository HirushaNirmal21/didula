import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gradient_borders/gradient_borders.dart';

class DoualCard extends StatefulWidget {
  final String doualId;
  final String player1Id;
  final String player2Id;
  final VoidCallback onDelete;

  const DoualCard({
    super.key,
    required this.doualId,
    required this.player1Id,
    required this.player2Id,
    required this.onDelete,
  });

  @override
  State<DoualCard> createState() => _DoualCardState();
}

class _DoualCardState extends State<DoualCard> {
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

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance
          .collection('users')
          .where(
            FieldPath.documentId,
            whereIn: [widget.player1Id, widget.player2Id],
          )
          .get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            height: 140,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25),
              color: Colors.white.withOpacity(0.02),
            ),
            child: const Center(
              child: CircularProgressIndicator(color: Color(0xFF00D2FF)),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.length < 2) {
          return const SizedBox();
        }

        final docs = snapshot.data!.docs;
        final player1 = docs.firstWhere((e) => e.id == widget.player1Id);
        final player2 = docs.firstWhere((e) => e.id == widget.player2Id);

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 18),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.03),
            borderRadius: BorderRadius.circular(25),

            border: const GradientBoxBorder(
              width: 1.5,
              gradient: LinearGradient(
                colors: [
                  Color(0xFF00D2FF), // Neon Electric Cyan
                  Color(0xFF0066FF), // Neon Vibrant Blue
                  Color(0xFF1E3A8A), // Deep Cyber Blue
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),

            boxShadow: [
              BoxShadow(
                color: const Color(0xFF00D2FF).withOpacity(0.08),
                blurRadius: 15,
                spreadRadius: 1,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0066FF).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      "DOUBLES TEAM",
                      style: TextStyle(
                        color: Color(0xFF00D2FF),
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  if (userRole == "admin")
                    GestureDetector(
                      onTap: widget.onDelete,
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          color: Colors.redAccent.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close_rounded,
                          color: Colors.redAccent,
                          size: 16,
                        ),
                      ),
                    ),
                  if (userRole != "admin") const SizedBox(height: 22),
                ],
              ),
              const SizedBox(height: 10),

              // 👥 Players Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Player 1
                  Expanded(
                    child: _buildPlayer(player1['name'], player1['imageUrl']),
                  ),

                  // 🏓 VS/With Center Area
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text("🏓", style: TextStyle(fontSize: 28)),
                      const SizedBox(height: 2),
                      Text(
                        "LINKED",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.3),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),

                  // Player 2
                  Expanded(
                    child: _buildPlayer(player2['name'], player2['imageUrl']),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // 👤 Player Avatar with matching Neon Cyan border
  Widget _buildPlayer(String name, String image) {
    final bool isImageValid = image.isNotEmpty && image.startsWith('http');

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: const Color(0xFF00D2FF).withOpacity(0.4),
              width: 1.5,
            ),
          ),
          child: CircleAvatar(
            radius: 34,
            backgroundColor: Colors.white10,
            backgroundImage: isImageValid ? NetworkImage(image) : null,
            child: !isImageValid
                ? const Icon(Icons.person, color: Colors.white60, size: 30)
                : null,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: 95,
          child: Text(
            name,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
