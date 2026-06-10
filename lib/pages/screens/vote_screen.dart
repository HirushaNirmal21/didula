import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class VoteScreen extends StatefulWidget {
  final dynamic currentUser;
  const VoteScreen({super.key, required this.currentUser});

  @override
  State<VoteScreen> createState() => _VoteScreenState();
}

class _VoteScreenState extends State<VoteScreen> {
  bool _hasVotedCurrently = false;
  int _totalSeniors = 0;
  bool _isLoadingCount = true;
  bool _isAdmin = false;
  bool _isVotingEnabled = false;
  StreamSubscription<DocumentSnapshot>? _settingsSubscription;

  @override
  void initState() {
    super.initState();
    if (widget.currentUser is Map) {
      _hasVotedCurrently = widget.currentUser['hasVoted'] ?? false;
      _isAdmin = widget.currentUser['role'] == 'admin';
    } else {
      _hasVotedCurrently = widget.currentUser.hasVoted ?? false;
      _isAdmin = widget.currentUser.role == 'admin';
    }
    _fetchTotalSeniors();
    _listenToVotingStatus();
  }

  @override
  void dispose() {
    _settingsSubscription?.cancel();
    super.dispose();
  }

  void _listenToVotingStatus() {
    _settingsSubscription = FirebaseFirestore.instance
        .collection('settings')
        .doc('voting')
        .snapshots()
        .listen((snapshot) {
          if (snapshot.exists) {
            setState(() {
              _isVotingEnabled = snapshot.data()?['isEnabled'] ?? false;
            });
          } else {
            setState(() {
              _isVotingEnabled = false;
            });
          }
        });
  }

  Future<void> _toggleVotingStatus() async {
    try {
      await FirebaseFirestore.instance.collection('settings').doc('voting').set(
        {'isEnabled': !_isVotingEnabled},
        SetOptions(merge: true),
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isVotingEnabled ? "Voting Closed! 🔒" : "Voting Opened Live! 🔓",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: _isVotingEnabled
              ? Colors.orangeAccent
              : const Color(0xFF00D2FF),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error toggling voting: $e"),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  Future<void> _fetchTotalSeniors() async {
    try {
      final aggregateQuery = await FirebaseFirestore.instance
          .collection('users')
          .where('level', whereIn: [1, 2])
          .count()
          .get();

      setState(() {
        _totalSeniors = aggregateQuery.count ?? 0;
        _isLoadingCount = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingCount = false;
      });
      print("Error fetching senior count: $e");
    }
  }

  Future<void> _resetAllVotes() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: Color(0xFF00D2FF)),
      ),
    );

    try {
      final usersSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .get();
      final batch = FirebaseFirestore.instance.batch();

      for (var doc in usersSnapshot.docs) {
        final data = doc.data();
        final level = data['level'] ?? 0;

        if (level == 1 || level == 2) {
          batch.update(doc.reference, {'hasVoted': false});
        } else if (level == 3) {
          batch.update(doc.reference, {'votesCount': 0});
        }
      }

      await batch.commit();

      setState(() {
        _hasVotedCurrently = false;
      });

      if (!mounted) return;
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Vote Page Reset Successfully! 🔄",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: Color.fromARGB(255, 255, 255, 255),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.redAccent),
      );
    }
  }

  void _showResetConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0B0E26),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          "Reset All Votes?",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          "Are you sure? Do you want to Reset this page!",
          style: TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "Cancel",
              style: TextStyle(color: Color(0xFF00D2FF)),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              Navigator.pop(context);
              _resetAllVotes();
            },
            child: const Text(
              "Yes, Reset",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submitVote(String juniorId, int currentVotes) async {
    if (_hasVotedCurrently) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("You can't vote again! ❌"),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    try {
      final batch = FirebaseFirestore.instance.batch();

      final juniorRef = FirebaseFirestore.instance
          .collection('users')
          .doc(juniorId);
      batch.update(juniorRef, {'votesCount': currentVotes + 1});

      String currentUserId = '';
      if (widget.currentUser is Map) {
        currentUserId = widget.currentUser['id'] ?? '';
      } else {
        currentUserId = widget.currentUser.id ?? '';
      }

      final seniorRef = FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserId);
      batch.update(seniorRef, {'hasVoted': true});

      await batch.commit();

      setState(() {
        _hasVotedCurrently = true;
      });

      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Nice Vote! 🎉"),
          backgroundColor: Color(0xFF00D2FF),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.redAccent),
      );
    }
  }

  void _showJuniorSelectionSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF06091F),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (context) {
        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .where('level', isEqualTo: 3)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: Color(0xFF00D2FF)),
              );
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(30.0),
                child: Text(
                  "No Junior Players Found",
                  style: TextStyle(color: Colors.white54, fontSize: 16),
                ),
              );
            }

            final juniors = snapshot.data!.docs;

            return Padding(
              padding: const EdgeInsets.all(25.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 4,
                        height: 20,
                        decoration: BoxDecoration(
                          color: const Color(0xFF00D2FF),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        "Select a Junior Player",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: ListView.builder(
                      itemCount: juniors.length,
                      itemBuilder: (context, index) {
                        final junior =
                            juniors[index].data() as Map<String, dynamic>;
                        final juniorId = juniors[index].id;
                        final votes = junior['votesCount'] ?? 0;

                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.02),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.05),
                            ),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 6,
                            ),
                            leading: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: const Color(
                                    0xFF00D2FF,
                                  ).withOpacity(0.3),
                                  width: 1.5,
                                ),
                              ),
                              child: CircleAvatar(
                                radius: 24,
                                backgroundColor: Colors.white10,
                                backgroundImage:
                                    junior['imageUrl'] != null &&
                                        junior['imageUrl'].toString().isNotEmpty
                                    ? NetworkImage(junior['imageUrl'])
                                    : null,
                                child:
                                    junior['imageUrl'] != null &&
                                        junior['imageUrl'].toString().isNotEmpty
                                    ? null
                                    : const Icon(
                                        Icons.person,
                                        color: Colors.white54,
                                      ),
                              ),
                            ),
                            title: Text(
                              junior['name'] ?? '',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            trailing: Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFF00D2FF).withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: IconButton(
                                icon: const Icon(
                                  Icons.how_to_vote_rounded,
                                  color: Color(0xFF00D2FF),
                                ),
                                onPressed: () => _submitVote(juniorId, votes),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF020412), // Deep Cyber Background
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: const Color(0xFF020412),
        elevation: 0,
        title: const Text(
          "Junior Player Votes",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        actions: [
          if (_isAdmin) ...[
            IconButton(
              icon: Icon(
                _isVotingEnabled ? Icons.lock_open_rounded : Icons.lock_rounded,
                color: _isVotingEnabled
                    ? const Color(0xFF00D2FF)
                    : Colors.orangeAccent,
                size: 26,
              ),
              onPressed: _toggleVotingStatus,
            ),
            IconButton(
              icon: const Icon(
                Icons.delete_sweep_rounded,
                color: Colors.redAccent,
                size: 28,
              ),
              onPressed: _showResetConfirmation,
            ),
          ],
        ],
      ),
      body: _isLoadingCount
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF00D2FF)),
            )
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .where('level', isEqualTo: 3)
                  .orderBy('votesCount', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: Color(0xFF00D2FF)),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text(
                      "Thama kawruth vote karala ne!",
                      style: TextStyle(color: Colors.white54, fontSize: 16),
                    ),
                  );
                }

                final votedJuniors = snapshot.data!.docs;

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  itemCount: votedJuniors.length,
                  itemBuilder: (context, index) {
                    final junior =
                        votedJuniors[index].data() as Map<String, dynamic>;
                    final voteCount = junior['votesCount'] ?? 0;

                    double progressValue = _totalSeniors > 0
                        ? (voteCount / _totalSeniors)
                        : 0.0;
                    int percentageText = (progressValue * 100).toInt();

                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      padding: const EdgeInsets.all(16),
                      // 🌌 Premium Glassmorphic Card Styling
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.02),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(
                            0xFF00D2FF,
                          ).withOpacity(0.15), // Smooth Neon Cyan Outline
                          width: 1.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF00D2FF).withOpacity(0.03),
                            blurRadius: 15,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          // 👤 Premium Profile Image Border
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: const Color(0xFF00D2FF).withOpacity(0.3),
                                width: 2,
                              ),
                            ),
                            child: CircleAvatar(
                              radius: 28,
                              backgroundColor: Colors.white10,
                              backgroundImage:
                                  junior['imageUrl'] != null &&
                                      junior['imageUrl'].toString().isNotEmpty
                                  ? NetworkImage(junior['imageUrl'])
                                  : null,
                              child:
                                  junior['imageUrl'] != null &&
                                      junior['imageUrl'].toString().isNotEmpty
                                  ? null
                                  : const Icon(
                                      Icons.person,
                                      color: Colors.white54,
                                      size: 28,
                                    ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  junior['name'] ?? '',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "$voteCount / $_totalSeniors Votes",
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.4),
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // 📊 Cyber Progress Circle
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              SizedBox(
                                width: 60,
                                height: 60,
                                child: CircularProgressIndicator(
                                  value: progressValue,
                                  backgroundColor: Colors.white.withOpacity(
                                    0.05,
                                  ),
                                  valueColor:
                                      const AlwaysStoppedAnimation<Color>(
                                        Color(0xFF00D2FF),
                                      ), // Electric Cyan Progress
                                  strokeWidth: 5,
                                ),
                              ),
                              Text(
                                "$percentageText%",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
      // ⚡ Premium Floating Action Button Style
      floatingActionButton: _hasVotedCurrently
          ? null
          : _isVotingEnabled
          ? Container(
              height: 54,
              margin: const EdgeInsets.symmetric(horizontal: 40),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: const Color(
                      0xFF00D2FF,
                    ).withOpacity(0.3), // Button Outer Neon Glow
                    blurRadius: 15,
                    spreadRadius: 1,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: FloatingActionButton.extended(
                onPressed: _showJuniorSelectionSheet,
                elevation: 0,
                backgroundColor:
                    Colors.transparent, // Gradient එක පේන්න transparent කළා
                label: const Text(
                  "Cast Your Vote",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    letterSpacing: 0.5,
                  ),
                ),
                icon: const Icon(
                  Icons.how_to_vote_rounded,
                  color: Colors.white,
                ),
                // 🎨 Button Background Gradient
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
