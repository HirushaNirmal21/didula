import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gradient_borders/gradient_borders.dart'; // 👈 මේක අනිවාර්යයෙන්ම ඕනේ hode!

class TeamCard extends StatefulWidget {
  final String teamId;
  final String teamName;
  final List memberIds;
  final VoidCallback onDelete;

  const TeamCard({
    super.key,
    required this.teamId,
    required this.teamName,
    required this.memberIds,
    required this.onDelete,
  });

  @override
  State<TeamCard> createState() => _TeamCardState();
}

class _TeamCardState extends State<TeamCard> {
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
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(25),

        border: const GradientBoxBorder(
          width: 1.5,
          gradient: LinearGradient(
            colors: [
              Color(0xFF6366F1), // Electric Indigo / Purple Blue
              Color(0xFF3B82F6), // Neon Blue
              Color(0xFF1D4ED8), // Deep Royal Blue
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),

        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366F1).withOpacity(0.08),
            blurRadius: 16,
            spreadRadius: 1,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Text(
                      "🛡️  ${widget.teamName}",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
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
            ],
          ),
          const SizedBox(height: 14),

          FutureBuilder(
            future: FirebaseFirestore.instance
                .collection('users')
                .where(FieldPath.documentId, whereIn: widget.memberIds)
                .get(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const SizedBox(
                  height: 95,
                  child: Center(
                    child: CircularProgressIndicator(color: Color(0xFF6366F1)),
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
                    final user = users[index];
                    // ignore: unnecessary_cast
                    final userData = user.data() as Map<String, dynamic>;
                    final imageUrl = userData.containsKey('imageUrl')
                        ? user['imageUrl']
                        : '';
                    final name = userData.containsKey('name')
                        ? user['name']
                        : 'Unknown';

                    return Padding(
                      padding: const EdgeInsets.only(right: 16.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // 👤 Member Avatar with Neon Purple/Blue Ring
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: const Color(0xFF6366F1).withOpacity(0.4),
                                width: 1.5,
                              ),
                            ),
                            child: CircleAvatar(
                              radius: 28,
                              backgroundColor: Colors.white10,
                              backgroundImage:
                                  imageUrl != null &&
                                      imageUrl.toString().isNotEmpty
                                  ? NetworkImage(imageUrl)
                                  : null,
                              child:
                                  imageUrl == null ||
                                      imageUrl.toString().isEmpty
                                  ? const Icon(
                                      Icons.person,
                                      color: Colors.white60,
                                      size: 24,
                                    )
                                  : null,
                            ),
                          ),
                          const SizedBox(height: 6),

                          // 📝 Member Name
                          SizedBox(
                            width: 65,
                            child: Text(
                              name,
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
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
        ],
      ),
    );
  }
}
