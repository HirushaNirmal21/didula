import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

class FullLeaderboardScreen extends StatefulWidget {
  const FullLeaderboardScreen({super.key});

  @override
  State<FullLeaderboardScreen> createState() => _FullLeaderboardScreenState();
}

class _FullLeaderboardScreenState extends State<FullLeaderboardScreen> {
  String userRole = "user";

  @override
  void initState() {
    super.initState();
    _fetchUserRole();
  }

  Future<void> _fetchUserRole() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (mounted) setState(() => userRole = doc.data()?['role'] ?? 'user');
    }
  }

  void _showEditPointsDialog(
    BuildContext context,
    String userId,
    Map<String, dynamic> player,
  ) {
    final pCtrl = TextEditingController(
      text: (player['points'] ?? 0).toString(),
    );
    final wCtrl = TextEditingController(text: (player['wins'] ?? 0).toString());
    final tCtrl = TextEditingController(
      text: (player['totalMatches'] ?? 0).toString(),
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text(
          "Edit Player Stats",
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: pCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: "Points",
                labelStyle: TextStyle(color: Colors.white54),
              ),
            ),
            TextField(
              controller: wCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: "Wins",
                labelStyle: TextStyle(color: Colors.white54),
              ),
            ),
            TextField(
              controller: tCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: "Total Matches",
                labelStyle: TextStyle(color: Colors.white54),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              await FirebaseFirestore.instance
                  .collection('users')
                  .doc(userId)
                  .update({
                    'points': int.tryParse(pCtrl.text) ?? 0,
                    'wins': int.tryParse(wCtrl.text) ?? 0,
                    'totalMatches': int.tryParse(tCtrl.text) ?? 0,
                  });
              Navigator.pop(context);
            },
            child: const Text("Update"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF000112),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(
          "CHAMPIONSHIP RANKINGS",
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .orderBy('points', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return const Center(child: CircularProgressIndicator());
          final all = snapshot.data!.docs;
          final top3 = all.take(3).toList();
          final rest = all.skip(3).toList();

          return Column(
            children: [
              const SizedBox(height: 20),
              _buildPodium(top3, context), // මෙතන 1, 2, 3 Edit කරන්න පුළුවන්
              const SizedBox(height: 30),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.03),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(40),
                    ),
                  ),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: rest.length,
                    itemBuilder: (context, i) {
                      var p = rest[i].data() as Map<String, dynamic>;
                      return _buildRankingRow(context, p, rest[i].id, i + 4);
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildRankingRow(
    BuildContext context,
    Map<String, dynamic> player,
    String id,
    int rank,
  ) {
    double winRate = ((player['totalMatches'] ?? 0) > 0)
        ? ((player['wins'] ?? 0) / (player['totalMatches'])) * 100
        : 0.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Text(
            "$rank",
            style: const TextStyle(
              color: Colors.white54,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 15),
          CircleAvatar(
            backgroundImage: player['imageUrl'] != null
                ? NetworkImage(player['imageUrl'])
                : null,
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  player['name'] ?? 'User',
                  style: const TextStyle(color: Colors.white),
                ),
                Text(
                  "${winRate.toStringAsFixed(1)}% Win Rate",
                  style: TextStyle(
                    color: Colors.cyan.withOpacity(0.7),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          if (userRole == "admin")
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.white30, size: 18),
              onPressed: () => _showEditPointsDialog(context, id, player),
            ),
          Text(
            "${player['points'] ?? 0} pts",
            style: const TextStyle(
              color: Color(0xFF00D2FF),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPodium(List<DocumentSnapshot> top3, BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (top3.length > 1)
          _buildPodiumCol(
            context,
            top3[1].data() as Map<String, dynamic>,
            top3[1].id,
            "2ND",
            Colors.grey,
          ),
        if (top3.isNotEmpty)
          _buildPodiumCol(
            context,
            top3[0].data() as Map<String, dynamic>,
            top3[0].id,
            "1ST",
            Colors.amber,
          ),
        if (top3.length > 2)
          _buildPodiumCol(
            context,
            top3[2].data() as Map<String, dynamic>,
            top3[2].id,
            "3RD",
            Colors.brown,
          ),
      ],
    );
  }

  Widget _buildPodiumCol(
    BuildContext context,
    Map<String, dynamic> p,
    String id,
    String rank,
    Color color,
  ) {
    double winRate = ((p['totalMatches'] ?? 0) > 0)
        ? ((p['wins'] ?? 0) / (p['totalMatches'])) * 100
        : 0.0;

    return Expanded(
      child: GestureDetector(
        onLongPress: () {
          if (userRole == "admin") {
            _showEditPointsDialog(context, id, p);
          }
        },
        child: Column(
          children: [
            Stack(
              alignment: Alignment.topCenter,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 15),
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: color, width: 3),
                  ),
                  child: CircleAvatar(
                    radius: 35,
                    backgroundImage: p['imageUrl'] != null
                        ? NetworkImage(p['imageUrl'])
                        : null,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    rank,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              p['name'] ?? '',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              "${winRate.toStringAsFixed(1)}% Win Rate",
              style: TextStyle(color: color, fontSize: 11),
            ),
            Text(
              "${p['points'] ?? 0} pts",
              style: const TextStyle(
                color: Colors.cyan,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
