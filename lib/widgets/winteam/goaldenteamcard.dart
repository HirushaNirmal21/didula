import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gradient_borders/box_borders/gradient_box_border.dart';

class Goaldenteamcard extends StatefulWidget {
  final String WinteamId;
  final String WinteamName;
  final List<dynamic> membersId;

  final VoidCallback onDelete;

  const Goaldenteamcard({
    super.key,
    required this.WinteamId,
    required this.WinteamName,
    required this.membersId,
    required this.onDelete,
  });

  @override
  State<Goaldenteamcard> createState() => _GoaldenteamcardState();
}

class _GoaldenteamcardState extends State<Goaldenteamcard> {
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

      if (!mounted) return;

      if (doc.exists && doc.data() != null) {
        setState(() {
          userRole = doc.data()?['role'] ?? 'user';
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
    if (widget.membersId.isEmpty) {
      return _buildCardContent(
        child: const Text(
          "No members in this team",
          style: TextStyle(color: Colors.white70, fontStyle: FontStyle.italic),
        ),
      );
    }

    return _buildCardContent(
      child: FutureBuilder<QuerySnapshot>(
        future: FirebaseFirestore.instance
            .collection('users')
            .where(
              FieldPath.documentId,
              whereIn: widget.membersId.take(30).toList(),
            )
            .get(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Text(
              "Error loading members",
              style: TextStyle(color: Colors.white),
            );
          }

          if (!snapshot.hasData) {
            return const Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Color(0xFFFCF6BA),
                ),
              ),
            );
          }

          final users = snapshot.data!.docs;

          return SizedBox(
            height: 95,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: users.length,
              itemBuilder: (context, index) {
                final userData = users[index].data() as Map<String, dynamic>;
                final imageUrl = userData.containsKey('imageUrl')
                    ? userData['imageUrl']
                    : '';
                final name = userData.containsKey('name')
                    ? userData['name']
                    : 'Unknown';

                return Padding(
                  padding: const EdgeInsets.only(right: 15.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFFBF953F),
                            width: 1.5,
                          ),
                        ),
                        child: CircleAvatar(
                          radius: 26,
                          backgroundColor: Colors.white10,
                          backgroundImage:
                              imageUrl != null && imageUrl.toString().isNotEmpty
                              ? NetworkImage(imageUrl)
                              : null,
                          child: imageUrl == null || imageUrl.toString().isEmpty
                              ? const Icon(Icons.person, color: Colors.white70)
                              : null,
                        ),
                      ),
                      const SizedBox(height: 5),
                      SizedBox(
                        width: 65,
                        child: Text(
                          name,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildCardContent({required Widget child}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        // 🌌 Glassmorphic Background
        color: const Color(0xFFBF953F).withOpacity(0.06),
        borderRadius: BorderRadius.circular(25),

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
            blurRadius: 25,
            spreadRadius: 1,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const ShaderMask(
                shaderCallback: _goldShader,
                child: Icon(
                  Icons.emoji_events_rounded,
                  color: Colors.white,
                  size: 45,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "CHAMPIONS",
                      style: TextStyle(
                        color: const Color(0xFFFCF6BA).withOpacity(0.8),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                    Text(
                      widget.WinteamName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              if (!isLoading && userRole == "admin")
                IconButton(
                  onPressed: widget.onDelete,
                  icon: const Icon(
                    Icons.delete_sweep_rounded,
                    color: Colors.redAccent,
                    size: 28,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }
}

//
// ignore: unused_element
RenderBox? _safeRenderBox(BuildContext context) =>
    context.findRenderObject() as RenderBox?;
Shader _goldShader(Rect bounds) {
  return const LinearGradient(
    colors: [Color(0xFFBF953F), Color(0xFFFCF6BA), Color(0xFFAA771C)],
  ).createShader(bounds);
}
