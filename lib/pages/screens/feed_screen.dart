import 'package:didula_api/functions/util_function.dart';
import 'package:didula_api/models/postmodel.dart';
import 'package:didula_api/pages/screens/leaderboardscreen.dart';
import 'package:didula_api/services/feed/feedservices.dart';
import 'package:didula_api/widgets/main/feed/post.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _migrateOldUsers();
    });
  }

  // ignore: unused_element
  Future<void> _migrateOldUsers() async {
    final firestore = FirebaseFirestore.instance;
    try {
      final usersSnapshot = await firestore.collection('users').get();

      WriteBatch batch = firestore.batch();
      int count = 0;

      for (var doc in usersSnapshot.docs) {
        final data = doc.data();

        if (data['points'] == null) {
          int userLevel = 3; // Default level 3
          if (data['level'] != null) {
            userLevel = int.tryParse(data['level'].toString()) ?? 3;
          }

          int initialPoints = 50;

          if (userLevel == 1) {
            initialPoints = 100;
          } else if (userLevel == 2) {
            initialPoints = 70;
          }

          batch.update(doc.reference, {
            'points': initialPoints,
            'matchesPlayed': 0,
            'matchesWon': 0,
            'matchesLost': 0,
          });
          count++;
        }
      }

      if (count > 0) {
        await batch.commit();
        print("⚡ [SUCCESS] Leaderboard Migration: Updated $count old users!");
      } else {
        print("⚡ [INFO] Leaderboard Migration: No old users to update.");
      }
    } catch (e) {
      print("❌ [ERROR] Leaderboard Migration Failed: $e");
    }
  }

  Future<void> _deletePost({
    required String postId,
    required String postUrl,
    required BuildContext context,
  }) async {
    try {
      await Feedservices().deletePost(postId: postId, postUrl: postUrl);
      UtilFunction().showSnackBar(context, "Post Deleted");
    } catch (e) {
      UtilFunction().showSnackBar(context, "Post Not Deleted");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 0, 1, 18),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 0, 1, 18),
        elevation: 0,
        title: Text(
          "Didula අපි",
          style: GoogleFonts.poppins(
            letterSpacing: 0.5,
            shadows: [
              Shadow(
                blurRadius: 10.0,
                color: Colors.black.withOpacity(0.3),
                offset: const Offset(0, 5),
              ),
            ],
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: const Color.fromARGB(255, 255, 255, 255),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.emoji_events_rounded,
              color: Colors.amber,
              size: 28,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const FullLeaderboardScreen(),
                ),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: StreamBuilder(
          stream: Feedservices().getPostStream(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return const Center(
                child: Text(
                  "Fail to Fetch Posts",
                  style: TextStyle(color: Colors.white),
                ),
              );
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Column(
                children: [
                  _buildTop3GlassCard(),
                  const Expanded(
                    child: Center(
                      child: Text(
                        "No Available Post",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              );
            }

            final List<PostModel> posts = snapshot.data!;

            return ListView.builder(
              itemCount: posts.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return _buildTop3GlassCard();
                }

                final Post = posts[index - 1];
                return Column(
                  children: [
                    PostWidget(
                      post: Post,
                      onEdit: () {},
                      onDelete: () async {
                        _deletePost(
                          context: context,
                          postId: Post.postId,
                          postUrl: Post.postUrl,
                        );
                      },
                      CurrentUserId: FirebaseAuth.instance.currentUser!.uid,
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildTop3GlassCard() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .orderBy('points', descending: true)
          .limit(3)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const SizedBox.shrink();
        }

        var top3Docs = snapshot.data!.docs;

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.04),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.08)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "🏆 Current Top 3",
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.cyanAccent.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      "LIVE RANKINGS",
                      style: GoogleFonts.poppins(
                        color: Colors.cyanAccent,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: top3Docs.length,
                itemBuilder: (context, index) {
                  var data = top3Docs[index].data() as Map<String, dynamic>;

                  String badge = index == 0
                      ? "🥇"
                      : index == 1
                      ? "🥈"
                      : "🥉";

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6.0),
                    child: Row(
                      children: [
                        Text(badge, style: const TextStyle(fontSize: 22)),
                        const SizedBox(width: 12),
                        CircleAvatar(
                          radius: 18,
                          backgroundColor: Colors.white.withOpacity(0.1),
                          backgroundImage: data['imageUrl'] != null
                              ? NetworkImage(data['imageUrl'])
                              : null,
                          child: data['imageUrl'] == null
                              ? Text(
                                  data['name']?[0].toUpperCase() ?? 'P',
                                  style: const TextStyle(color: Colors.white),
                                )
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          data['name'] ?? 'Unknown Player',
                          style: GoogleFonts.poppins(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          "${data['points'] ?? 0} pts",
                          style: GoogleFonts.poppins(
                            color: const Color.fromARGB(255, 0, 183, 255),
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
