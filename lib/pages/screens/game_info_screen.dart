import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:didula_api/services/sponser_service.dart';
import 'package:didula_api/widgets/custom/custom_button.dart';
import 'package:didula_api/widgets/main/sponsers/sponser_bottom_sheet.dart';
import 'package:didula_api/widgets/main/sponsers/sponser_card.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gradient_borders/box_borders/gradient_box_border.dart';

class GameInfoPage extends StatefulWidget {
  const GameInfoPage({super.key});

  @override
  State<GameInfoPage> createState() => _GameInfoPageState();
}

class _GameInfoPageState extends State<GameInfoPage> {
  final SponsorService sponsorService = SponsorService();

  // change this later
  bool isLoading = true;
  String userRole = "user";

  @override
  initState() {
    super.initState();
    _fetchUserRole();
  }

  Future<void> _fetchUserRole() async {
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
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 0, 1, 18),

      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color.fromARGB(255, 0, 1, 18),

        title: Text(
          "Game Info",
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
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 20, horizontal: 4),

              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: const Color(
                      0xFF00D2FF,
                    ).withOpacity(0.15), // Neon Cyan Glow
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Container(
                padding: const EdgeInsets.all(2.5),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF00D2FF), // Electric Cyan
                      Color(0xFF0047FF), // Deep Cyber Blue
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(22),
                  child: Image.asset(
                    "assets/pro.jpeg",
                    fit: BoxFit.cover,

                    color: Colors.black.withOpacity(0.05),
                    colorBlendMode: BlendMode.darken,
                  ),
                ),
              ),
            ),

            const Text(
              'Table Tennis Arena',

              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 255, 255, 255),
              ),
            ),

            const SizedBox(height: 10),
            const Text(
              "Unleash your power, master the speed, and dominate the table. Face the toughest rivals and claim your throne in the arena.",

              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 30),

            // =========================
            // GAME DETAILS
            // =========================
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.02),
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
                    color: const Color(0xFF00D2FF).withOpacity(0.06),
                    blurRadius: 20,
                    spreadRadius: 1,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // 👥 Active Players
                  buildInfoTile(
                    Icons.people_alt_rounded,
                    'Active Players',
                    '50 +',
                  ),

                  // ⚡ Neon Splitter Divider
                  Divider(
                    color: const Color(0xFF00D2FF).withOpacity(0.12),
                    thickness: 1,
                    height: 24,
                  ),

                  // 🏓 Total Matches
                  buildInfoTile(
                    Icons.sports_score_rounded,
                    'Total Matches',
                    '100 +',
                  ),

                  // ⚡ Neon Splitter Divider
                  Divider(
                    color: const Color(0xFF00D2FF).withOpacity(0.12),
                    thickness: 1,
                    height: 24,
                  ),

                  // 🏆 Tournaments
                  buildInfoTile(
                    Icons.emoji_events_rounded,
                    'Tournaments',
                    '10 +',
                  ),

                  // ⚡ Neon Splitter Divider
                  Divider(
                    color: const Color(0xFF00D2FF).withOpacity(0.12),
                    thickness: 1,
                    height: 24,
                  ),

                  // 🤝 Sponsors
                  buildInfoTile(
                    Icons.workspace_premium_rounded,
                    'Sponsors',
                    '20 +',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 35),

            // =========================
            // SPONSORS TITLE
            // =========================
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,

              children: [
                const Text(
                  'Sponsors',

                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),

                // admin only button
                if (userRole == 'admin')
                  IconButton(
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,

                        isScrollControlled: true,

                        backgroundColor: Colors.white,

                        builder: (context) {
                          return SingleChildScrollView(
                            child: const SponsorBottomSheet(),
                          );
                        },
                      );
                    },

                    icon: const Icon(Icons.add, color: Colors.white, size: 30),
                  ),
              ],
            ),

            const SizedBox(height: 20),

            // =========================
            // SPONSOR LIST
            // =========================
            SizedBox(
              height: 230,

              child: StreamBuilder<QuerySnapshot>(
                stream: sponsorService.getSponsors(),

                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final sponsors = snapshot.data!.docs;

                  if (sponsors.isEmpty) {
                    return const Center(
                      child: Text(
                        'No Sponsors Yet',

                        style: TextStyle(color: Colors.white70),
                      ),
                    );
                  }

                  return ListView.builder(
                    physics: AlwaysScrollableScrollPhysics(),
                    shrinkWrap: true,
                    scrollDirection: Axis.horizontal,

                    itemCount: sponsors.length,

                    itemBuilder: (context, index) {
                      final sponsor = sponsors[index];

                      return SponsorCard(
                        imageUrl: sponsor['imageUrl'],

                        name: sponsor['name'],
                        onDelete: () async {
                          try {
                            await FirebaseFirestore.instance
                                .collection('users')
                                .doc(sponsor.id)
                                .update({'isSponsor': false});

                            if (!context.mounted) return;

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Sponsor removed")),
                            );
                          } catch (e) {
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(e.toString())),
                            );
                          }
                        },
                      );
                    },
                  );
                },
              ),
            ),
            Padding(padding: const EdgeInsets.only(top: 30)),
            SizedBox(height: 30),

            const Text(
              'Game Sections',

              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 30),
            Custombutton(
              text: "Winners",
              width: double.infinity,
              onPressed: () {
                GoRouter.of(context).push('/WinnersPage');
              },
            ),
            const SizedBox(height: 5),
            Custombutton(
              text: "Teams",
              width: double.infinity,
              onPressed: () {
                GoRouter.of(context).push('/TeamsPage');
              },
            ),
            const SizedBox(height: 5),
            Custombutton(
              text: "Douels",
              width: double.infinity,
              onPressed: () {
                GoRouter.of(context).push('/DuelPage');
              },
            ),
            const SizedBox(height: 5),

            FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('users')
                  .doc(FirebaseAuth.instance.currentUser?.uid)
                  .get(),
              builder: (context, userSnapshot) {
                if (userSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (userSnapshot.hasError ||
                    !userSnapshot.hasData ||
                    !userSnapshot.data!.exists) {
                  return const SizedBox.shrink();
                }

                final userData =
                    userSnapshot.data!.data() as Map<String, dynamic>;
                final userLevel = userData['level'] ?? 0;

                // 💡 3. යූසර් Level 1 හෝ 2 නම් විතරක් බටන් එක පෙන්වනවා
                if (userLevel == 1 || userLevel == 2) {
                  return Container(
                    width: double.infinity,
                    height: 50,
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.04),
                      borderRadius: BorderRadius.circular(14),
                      border: const GradientBoxBorder(
                        width: 1.5,
                        gradient: LinearGradient(
                          colors: [
                            Color(0xFF00D2FF), // Electric Cyan
                            Color(0xFF0066FF), // Neon Blue
                          ],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                      ),

                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF00D2FF).withOpacity(0.12),
                          blurRadius: 12,
                          spreadRadius: -2,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,

                        foregroundColor: const Color(
                          0xFF00D2FF,
                        ).withOpacity(0.2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),

                      icon: const Icon(
                        Icons.how_to_vote,
                        color: Color(0xFF00D2FF),
                        size: 20,
                      ),
                      label: const Text(
                        "Vote for Junior Players",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.8,
                        ),
                      ),
                      onPressed: () {
                        userData['id'] = userSnapshot.data!.id;

                        context.push('/vote', extra: userData);
                      },
                    ),
                  );
                }

                // Level 3 අයට බටන් එක පේන්නේ නැහැ
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }

  // =========================
  // CUSTOM INFO TILE
  // =========================

  Widget buildInfoTile(IconData icon, String title, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.white),

        const SizedBox(width: 15),

        Text(title, style: const TextStyle(color: Colors.white, fontSize: 16)),

        const Spacer(),

        Text(
          value,

          style: const TextStyle(
            color: Colors.white70,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
