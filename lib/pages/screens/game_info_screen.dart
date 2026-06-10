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
            letterSpacing: 0.5, // අකුරු අතර පරතරය ලස්සන කළා
            shadows: [
              Shadow(
                blurRadius: 10.0,
                color: Colors.black.withOpacity(0.3),
                offset: const Offset(0, 5), // පල්ලෙහාට හෙවනැල්ලක් දාන්න
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
              // 🌌 ෆොටෝ එක වටේට Neon Glow එකක් දාන්න මේ Shadow එක උදව් වෙනවා
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
              padding: const EdgeInsets.all(
                22,
              ), // Padding එක ලාවට වැඩි කළා හුස්ම ගන්න ඉඩ තියෙන්න
              decoration: BoxDecoration(
                // 🌌 Glassmorphic Background: ඇතුළත ලාවට විනිවිද පෙනෙන සුපිරි ඩාර්ක් ලුක් එක
                color: Colors.white.withOpacity(0.02),
                borderRadius: BorderRadius.circular(25),

                // ⚡ Cyber Neon Gradient Border: ඇස් නිලංකාර වෙන තියුණු සයන් සහ නිල් ග්‍රේඩියන්ට් බෝඩර් එක
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

                // 🔮 Premium Glow Shadow: කාඩ් එක වටෙන් ලාවට නිල් පාටින් ස්මූත් එකට දිලිසෙන ඉෆෙක්ට් එක
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
            const SizedBox(height: 5), // Douels බටන් එකට යටින් තියෙන පරතරය

            FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('users')
                  .doc(FirebaseAuth.instance.currentUser?.uid)
                  .get(),
              builder: (context, userSnapshot) {
                // 💡 1. ඩේටා ලෝඩ් වෙනකම් සරලව ලෝඩර් එකක් පෙන්වනවා (බ්ලැක් ස්ක්‍රීන් වීම වළක්වයි)
                if (userSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                // 💡 2. මොකක් හරි error එකක් ආවොත් ක්‍රෑෂ් නොවී shrink වෙනවා
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
                    margin: const EdgeInsets.symmetric(
                      vertical: 6,
                    ), // බටන් අතර ලස්සන පරතරයක්
                    decoration: BoxDecoration(
                      // 🌌 Glassmorphic Background: ඇතුළත ලාවට විනිවිද පෙනෙන ඩාර්ක් ලුක් එක
                      color: Colors.white.withOpacity(0.04),
                      borderRadius: BorderRadius.circular(
                        14,
                      ), // Corner radius එක 14 කළා Soft ලුක් එකක් ගන්න
                      // ⚡ Cyber Neon Border: අනිත් බටන්ස් වලට මැච් වෙන Electric Cyan සහ Neon Blue බෝඩර් එක
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

                      // 🔮 Cyber Glow Shadow: බටන් එක වටෙන් ලාවට දිලිසෙන ලස්සන Neon Effect එක
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
                        // බටන් එක ඔබද්දී ඇතුළෙන් ලස්සනට Splash (Ripple) එකක් යන්න
                        foregroundColor: const Color(
                          0xFF00D2FF,
                        ).withOpacity(0.2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      // 🗳️ අයිකන් එකත් Neon නිල් පාටින් දිලිසෙන්න සෙට් කළා
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
                          letterSpacing:
                              0.8, // අකුරු අතර පරතරය වැඩි කරලා Premium ගතිය ගත්තා
                        ),
                      ),
                      onPressed: () {
                        userData['id'] = userSnapshot.data!.id;
                        // 🚀 ඔයාගේ සුපිරි GoRouter Navigation එක එහෙම්මම වැඩ!
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
