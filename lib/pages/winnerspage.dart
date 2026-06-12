import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:didula_api/models/teamwinnermodel.dart';
import 'package:didula_api/services/imaginplayer.dart';
import 'package:didula_api/services/junior_individualservice.dart';
import 'package:didula_api/services/seniorindividualservices.dart';
import 'package:didula_api/services/winner_dual_service.dart';
import 'package:didula_api/services/winner_junior_doual_service.dart';
import 'package:didula_api/services/winteamlservice.dart';
import 'package:didula_api/widgets/doules/doualbottumsheet.dart';
import 'package:didula_api/widgets/imagineplayer/imaginbottumsheet.dart';
import 'package:didula_api/widgets/imagineplayer/imagineplayercard.dart';
import 'package:didula_api/widgets/individual_winner_bottum_sheet.dart';
import 'package:didula_api/widgets/winteam/goaldenteamcard.dart';
import 'package:didula_api/widgets/winner_place_card.dart';
import 'package:didula_api/widgets/winning_doul_card.dart';
import 'package:didula_api/widgets/winteam/winningteambottomsheet.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class WinTeamsPage extends StatefulWidget {
  WinTeamsPage({super.key});

  @override
  State<WinTeamsPage> createState() => _WinTeamsPageState();
}

class _WinTeamsPageState extends State<WinTeamsPage> {
  bool isLoading = true;
  String userRole = "user";
  final JuniorDualWinnerService juniorDualWinnerService =
      JuniorDualWinnerService();
  final SpecialPlayerService specialPlayerService = SpecialPlayerService();
  final SeniorIndividualService service = SeniorIndividualService();
  final JuniorIndividualService juniorIndividualService =
      JuniorIndividualService();
  final SeniorDualWinnerService seniorDualWinnerService =
      SeniorDualWinnerService();

  final goldGradient = const LinearGradient(
    transform: GradientRotation(90 * 3.14 / 180),
    colors: [
      Color(0xFFBF953F), // Deep Gold
      Color(0xFFFCF6BA), // Light Gold Highlight
      Color(0xFFB38728), // Darker Metallic Gold
      Color(0xFFFBF5B7), // Soft Highlight
      Color(0xFFAA771C), // Deep Bronze Gold
    ],
    stops: [0.0, 0.25, 0.5, 0.75, 1.0],
  );

  final silverGradient = const LinearGradient(
    transform: GradientRotation(90 * 3.14 / 180),

    colors: [
      Color(0xFFE0E0E0), // Light silver / Platinum
      Color(0xFFF5F5F5), // Very light / White highlight
      Color(0xFFBDBDBD), // Medium metallic silver
      Color(0xFFE0E0E0), // Light silver transition
      Color(0xFF9E9E9E), // Darker silver shadow
    ],
    stops: [0.0, 0.25, 0.5, 0.75, 1.0],
  );

  final bronzeGradient = const LinearGradient(
    transform: GradientRotation(90 * 3.14 / 180),
    colors: [
      Color(0xFF593C1E), // Deep Dark Bronze
      Color(0xFF82572C), // Medium Bronze
      Color(0xFFCE8946), // Light Metallic Bronze
      Color(0xFFFCA956), // Bronze Highlight
      Color(0xFF593C1E), // Deep Dark Bronze
    ],
    stops: [0.0, 0.25, 0.5, 0.75, 1.0],
  );

  @override
  void initState() {
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

  final WinTeamservise winTeamservise = WinTeamservise();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color.fromARGB(255, 0, 1, 18),
        title: const Text(
          'Winners',
          style: TextStyle(
            color: Color.fromARGB(255, 255, 255, 255),
            fontWeight: FontWeight.bold,
            fontSize: 26,
          ),
        ),
      ),
      backgroundColor: const Color(0xff020617),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Flexible(
                      child: Text(
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        'Winning Teams',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
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
                              return const SingleChildScrollView(
                                child: WinTeamBottomSheet(),
                              );
                            },
                          );
                        },
                        icon: const Icon(
                          Icons.add,
                          color: Colors.white,
                          size: 26,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              Padding(
                padding: const EdgeInsets.all(15.0),
                child: SizedBox(
                  height: 210,
                  width: double.infinity,
                  child: StreamBuilder<QuerySnapshot>(
                    stream: WinTeamservise().getWinTeam(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final Winteam = snapshot.data!.docs;

                      if (Winteam.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.emoji_events_outlined,
                                size: 50,
                                color: Colors.grey.shade600,
                              ),
                              const SizedBox(height: 15),
                              Text(
                                "No Winning Teams Yet",
                                style: TextStyle(
                                  color: Colors.grey.shade500,
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      return ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: Winteam.length,
                        itemBuilder: (context, index) {
                          final winTeam = TeamWinnerModel.fromMap(
                            Winteam[index].data() as Map<String, dynamic>,
                          );

                          return Goaldenteamcard(
                            WinteamId: winTeam.winteamid,
                            WinteamName: winTeam.winteamName,
                            membersId: winTeam.membersId,
                            onDelete: () async {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: const Text("Delete Team"),
                                    content: const Text(
                                      "Are you sure you want to delete this team?",
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: const Text("Cancel"),
                                      ),
                                      TextButton(
                                        onPressed: () async {
                                          Navigator.pop(context);
                                          await winTeamservise.deleteWinTeam(
                                            winTeam.winteamid,
                                          );
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text("Team Deleted"),
                                            ),
                                          );
                                        },
                                        child: const Text(
                                          "Delete",
                                          style: TextStyle(color: Colors.red),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
              ),

              Divider(
                color: Colors.white10,
                thickness: 1,
                indent: 20,
                endIndent: 20,
              ),
              SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Flexible(
                    child: Padding(
                      padding: EdgeInsets.all(15.0),
                      child: Text(
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        'Senior & Junior Imagine players',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: _buildSeniorCard(),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: _buildJuniorCard(),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),
              Divider(
                color: Colors.grey.shade700,
                thickness: 1,
                indent: 15,
                endIndent: 15,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Flexible(
                    child: Padding(
                      padding: EdgeInsets.all(15.0),
                      child: Text(
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        'Senior Individual Winners',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 220,
                width: MediaQuery.of(context).size.width * 0.95,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: _buildFirstPlace()),
                    const SizedBox(width: 10),
                    Expanded(child: _buildSecondPlace()),
                    const SizedBox(width: 10),
                    Expanded(child: _buildThirdPlace()),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Divider(
                color: Colors.grey.shade700,
                thickness: 1,
                indent: 15,
                endIndent: 15,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Flexible(
                    child: Padding(
                      padding: EdgeInsets.all(15.0),
                      child: Text(
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        'Senior Doual Winners',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Column(
                children: [
                  _buildFirstDual(),
                  const SizedBox(height: 15),
                  _buildSecondDual(),
                  const SizedBox(height: 15),
                  _buildThirdDual(),
                ],
              ),
              const SizedBox(height: 16),
              Divider(
                color: Colors.grey.shade700,
                thickness: 1,
                indent: 15,
                endIndent: 15,
              ),
              Padding(
                padding: const EdgeInsets.all(15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Flexible(
                      child: Text(
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        'Junior Individual Winners',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 220,
                width: MediaQuery.of(context).size.width * 0.95,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: _buildJuniorFirstPlace()),
                    const SizedBox(width: 10),
                    Expanded(child: _buildJuniorSecondPlace()),
                    const SizedBox(width: 10),
                    Expanded(child: _buildJuniorThirdPlace()),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Divider(
                color: Colors.grey.shade700,
                thickness: 1,
                indent: 15,
                endIndent: 15,
              ),
              Row(
                children: [
                  const Flexible(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.all(15.0),
                          child: Text(
                            'Junior Doual Winners',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Column(
                children: [
                  _buildJuniorFirstDual(),
                  const SizedBox(height: 15),
                  _buildJuniorSecondDual(),
                  const SizedBox(height: 15),
                  _buildJuniorThirdDual(),
                ],
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSeniorCard() {
    return StreamBuilder(
      stream: specialPlayerService.getSeniorPlayer(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox();

        final data = snapshot.data!.data() as Map<String, dynamic>?;
        final userId = data?['userId'];

        if (userId == null) {
          return SpecialPlayerCard(
            title: "Senior MVP",
            name: "Add Player",
            imageUrl: "",
            onTap: () {
              if (userRole == "admin") {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  builder: (_) => SpecialPlayerBottomSheet(
                    onUserSelected: (id) async {
                      await specialPlayerService.setSeniorPlayer(id);
                    },
                  ),
                );
              }
            },
          );
        }

        return FutureBuilder(
          future: FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .get(),
          builder: (context, userSnap) {
            if (!userSnap.hasData) return const SizedBox();
            final user = userSnap.data!;

            return SpecialPlayerCard(
              title: "Senior MVP",
              name: user['name'] ?? 'Unknown',
              imageUrl: user['imageUrl'] ?? '',
              onTap: () {
                if (userRole == "admin") {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    builder: (_) => SpecialPlayerBottomSheet(
                      onUserSelected: (id) async {
                        await specialPlayerService.setSeniorPlayer(id);
                      },
                    ),
                  );
                }
              },
              onDelete: () async {
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text("Delete Player"),
                      content: const Text(
                        "Are you sure you want to delete this player?",
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text("Cancel"),
                        ),
                        TextButton(
                          onPressed: () async {
                            Navigator.pop(context);
                            await specialPlayerService.removeSeniorPlayer();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Player Deleted")),
                            );
                          },
                          child: const Text(
                            "Delete",
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildJuniorCard() {
    return StreamBuilder(
      stream: specialPlayerService.getJuniorPlayer(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox();

        final data = snapshot.data!.data() as Map<String, dynamic>?;
        final userId = data?['userId'];

        if (userId == null) {
          return SpecialPlayerCard(
            title: "Junior MVP",
            name: "Add Player",
            imageUrl: "",
            onTap: () {
              if (userRole == "admin") {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  builder: (_) => SpecialPlayerBottomSheet(
                    onUserSelected: (id) async {
                      await specialPlayerService.setJuniorPlayer(id);
                    },
                  ),
                );
              }
            },
          );
        }

        return FutureBuilder(
          future: FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .get(),
          builder: (context, userSnap) {
            if (!userSnap.hasData) return const SizedBox();
            final user = userSnap.data!;

            return SpecialPlayerCard(
              title: "Junior MVP",
              name: user['name'] ?? 'Unknown',
              imageUrl: user['imageUrl'] ?? '',
              onTap: () {
                if (userRole == "admin") {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    builder: (_) => SpecialPlayerBottomSheet(
                      onUserSelected: (id) async {
                        await specialPlayerService.setJuniorPlayer(id);
                      },
                    ),
                  );
                }
              },
              onDelete: () async {
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text("Delete Player"),
                      content: const Text(
                        "Are you sure you want to delete this player?",
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text("Cancel"),
                        ),
                        TextButton(
                          onPressed: () async {
                            Navigator.pop(context);
                            await specialPlayerService.removeJuniorPlayer();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Player Deleted")),
                            );
                          },
                          child: const Text(
                            "Delete",
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildFirstPlace() {
    return StreamBuilder(
      stream: service.getFirstPlace(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox();

        final data = snapshot.data!.data() as Map<String, dynamic>?;
        final userId = data?['userId'];

        if (userId == null) {
          return WinnerPlaceCard(
            title: "1st Place",
            name: "Add Winner",
            imageUrl: "",
            avatarGradient: goldGradient,
            borderGradient: goldGradient,
            onTap: () {
              if (userRole == "admin") {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  builder: (_) {
                    return SeniorIndividualBottomSheet(
                      onUserSelected: (id) async {
                        await service.setFirstPlace(id);
                      },
                    );
                  },
                );
              }
            },
          );
        }

        return FutureBuilder(
          future: FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .get(),
          builder: (context, userSnap) {
            if (!userSnap.hasData) return const SizedBox();
            final user = userSnap.data!;

            return WinnerPlaceCard(
              title: "1st Place",

              name: user['name'] ?? 'Unknown',
              imageUrl: user['imageUrl'] ?? '',
              avatarGradient: goldGradient,
              borderGradient: goldGradient,
              onTap: () {
                if (userRole == "admin") {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    builder: (_) {
                      return SeniorIndividualBottomSheet(
                        onUserSelected: (id) async {
                          await service.setFirstPlace(id);
                        },
                      );
                    },
                  );
                }
              },
              onDelete: () async {
                await service.removeFirstPlace();
              },
            );
          },
        );
      },
    );
  }

  Widget _buildSecondPlace() {
    return StreamBuilder(
      stream: service.getSecondPlace(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox();

        final data = snapshot.data!.data() as Map<String, dynamic>?;
        final userId = data?['userId'];

        if (userId == null) {
          return WinnerPlaceCard(
            title: "2nd Place",
            name: "Add Winner",
            imageUrl: "",
            avatarGradient: silverGradient,
            borderGradient: silverGradient,
            onTap: () {
              if (userRole == "admin") {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  builder: (_) {
                    return SeniorIndividualBottomSheet(
                      onUserSelected: (id) async {
                        await service.setSecondPlace(id);
                      },
                    );
                  },
                );
              }
            },
          );
        }

        return FutureBuilder(
          future: FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .get(),
          builder: (context, userSnap) {
            if (!userSnap.hasData) return const SizedBox();
            final user = userSnap.data!;

            return WinnerPlaceCard(
              title: "2nd Place",
              name: user['name'] ?? 'Unknown',
              imageUrl: user['imageUrl'] ?? '',
              avatarGradient: silverGradient,
              borderGradient: silverGradient,
              onTap: () {
                if (userRole == "admin") {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    builder: (_) {
                      return SeniorIndividualBottomSheet(
                        onUserSelected: (id) async {
                          await service.setSecondPlace(id);
                        },
                      );
                    },
                  );
                }
              },
              onDelete: () async {
                await service.removeSecondPlace();
              },
            );
          },
        );
      },
    );
  }

  Widget _buildThirdPlace() {
    return StreamBuilder(
      stream: service.getThirdPlace(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox();

        final data = snapshot.data!.data() as Map<String, dynamic>?;
        final userId = data?['userId'];

        if (userId == null) {
          return WinnerPlaceCard(
            title: "3rd Place",
            name: "Add Winner",
            imageUrl: "",
            avatarGradient: bronzeGradient,
            borderGradient: bronzeGradient,
            onTap: () {
              if (userRole == "admin") {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  builder: (_) {
                    return SeniorIndividualBottomSheet(
                      onUserSelected: (id) async {
                        await service.setThirdPlace(id);
                      },
                    );
                  },
                );
              }
            },
          );
        }

        return FutureBuilder(
          future: FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .get(),
          builder: (context, userSnap) {
            if (!userSnap.hasData) return const SizedBox();
            final user = userSnap.data!;

            return WinnerPlaceCard(
              title: "3rd Place",
              name: user['name'] ?? 'Unknown',
              imageUrl: user['imageUrl'] ?? '',
              avatarGradient: bronzeGradient,
              borderGradient: bronzeGradient,
              onTap: () {
                if (userRole == "admin") {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    builder: (_) {
                      return SeniorIndividualBottomSheet(
                        onUserSelected: (id) async {
                          await service.setThirdPlace(id);
                        },
                      );
                    },
                  );
                }
              },
              onDelete: () async {
                await service.removeThirdPlace();
              },
            );
          },
        );
      },
    );
  }

  Widget _buildJuniorFirstPlace() {
    return StreamBuilder(
      stream: juniorIndividualService.getJuniorFirstPlace(),

      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox();
        }

        final data = snapshot.data!.data() as Map<String, dynamic>?;

        final userId = data?['userId'];

        if (userId == null) {
          return WinnerPlaceCard(
            title: "1st Place",
            name: "Add Winner",
            imageUrl: "",
            avatarGradient: goldGradient,
            borderGradient: goldGradient,
            onTap: () {
              if (userRole == "admin") {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  builder: (_) {
                    return SeniorIndividualBottomSheet(
                      onUserSelected: (id) async {
                        await juniorIndividualService.setJuniorFirstPlace(id);
                      },
                    );
                  },
                );
              }
            },
          );
        }

        return FutureBuilder(
          future: FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .get(),

          builder: (context, userSnap) {
            if (!userSnap.hasData) {
              return const SizedBox();
            }

            final user = userSnap.data!;

            return WinnerPlaceCard(
              title: "1st Place",

              name: user['name'],

              imageUrl: user['imageUrl'],

              avatarGradient: goldGradient,
              borderGradient: goldGradient,

              onTap: () {
                if (userRole == "admin") {
                  showModalBottomSheet(
                    context: context,

                    builder: (_) {
                      return SeniorIndividualBottomSheet(
                        onUserSelected: (id) async {
                          await juniorIndividualService.setJuniorFirstPlace(id);
                        },
                      );
                    },
                  );
                }
              },

              onDelete: () async {
                await juniorIndividualService.removeJuniorFirstPlace();
              },
            );
          },
        );
      },
    );
  }

  Widget _buildJuniorSecondPlace() {
    return StreamBuilder(
      stream: juniorIndividualService.getJuniorSecondPlace(),

      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox();
        }

        final data = snapshot.data!.data() as Map<String, dynamic>?;

        final userId = data?['userId'];

        if (userId == null) {
          return WinnerPlaceCard(
            title: "2nd Place",

            name: "Add Winner",

            imageUrl: "",

            avatarGradient: silverGradient,
            borderGradient: silverGradient,

            onTap: () {
              if (userRole == "admin") {
                showModalBottomSheet(
                  context: context,

                  isScrollControlled: true,

                  builder: (_) {
                    return SeniorIndividualBottomSheet(
                      onUserSelected: (id) async {
                        await juniorIndividualService.setJuniorSecondPlace(id);
                      },
                    );
                  },
                );
              }
            },
          );
        }

        return FutureBuilder(
          future: FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .get(),

          builder: (context, userSnap) {
            if (!userSnap.hasData) {
              return const SizedBox();
            }

            final user = userSnap.data!;

            return WinnerPlaceCard(
              title: "2nd Place",

              name: user['name'],

              imageUrl: user['imageUrl'],

              avatarGradient: silverGradient,
              borderGradient: silverGradient,

              onTap: () {
                if (userRole == "admin") {
                  showModalBottomSheet(
                    context: context,

                    builder: (_) {
                      return SeniorIndividualBottomSheet(
                        onUserSelected: (id) async {
                          await juniorIndividualService.setJuniorSecondPlace(
                            id,
                          );
                        },
                      );
                    },
                  );
                }
              },

              onDelete: () async {
                await juniorIndividualService.removeJuniorSecondPlace();
              },
            );
          },
        );
      },
    );
  }

  Widget _buildJuniorThirdPlace() {
    return StreamBuilder(
      stream: juniorIndividualService.getJuniorThirdPlace(),

      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox();
        }

        final data = snapshot.data!.data() as Map<String, dynamic>?;

        final userId = data?['userId'];

        if (userId == null) {
          return WinnerPlaceCard(
            title: "3rd Place",

            name: "Add Winner",

            imageUrl: "",

            avatarGradient: bronzeGradient,
            borderGradient: bronzeGradient,

            onTap: () {
              if (userRole == "admin") {
                showModalBottomSheet(
                  context: context,

                  isScrollControlled: true,

                  builder: (_) {
                    return SeniorIndividualBottomSheet(
                      onUserSelected: (id) async {
                        await juniorIndividualService.setJuniorThirdPlace(id);
                      },
                    );
                  },
                );
              }
            },
          );
        }

        return FutureBuilder(
          future: FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .get(),

          builder: (context, userSnap) {
            if (!userSnap.hasData) {
              return const SizedBox();
            }

            final user = userSnap.data!;

            return WinnerPlaceCard(
              title: "3rd Place",

              name: user['name'],

              imageUrl: user['imageUrl'],

              avatarGradient: bronzeGradient,
              borderGradient: bronzeGradient,

              onTap: () {
                if (userRole == "admin") {
                  showModalBottomSheet(
                    context: context,

                    builder: (_) {
                      return SeniorIndividualBottomSheet(
                        onUserSelected: (id) async {
                          await juniorIndividualService.setJuniorThirdPlace(id);
                        },
                      );
                    },
                  );
                }
              },

              onDelete: () async {
                await juniorIndividualService.removeJuniorThirdPlace();
              },
            );
          },
        );
      },
    );
  }

  Widget _buildFirstDual() {
    return StreamBuilder(
      stream: seniorDualWinnerService.getFirstPlace(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox();

        final data = snapshot.data!.data() as Map<String, dynamic>?;
        final dualId = data?['doualId'];

        if (dualId == null) {
          return DualWinnerCard(
            title: "🥇 1st Place",
            player1Name: "Add Winner",
            player2Name: "",
            player1Image: "",
            player2Image: "",
            gradient: goldGradient,
            onTap: () async {
              final selectedDual = await showModalBottomSheet<String>(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => const SelectDualBottomSheet(),
              );

              if (selectedDual != null) {
                await seniorDualWinnerService.setFirstPlace(selectedDual);
              }
            },
          );
        }

        return FutureBuilder(
          future: FirebaseFirestore.instance
              .collection('douals')
              .doc(dualId)
              .get(),
          builder: (context, dualSnap) {
            if (!dualSnap.hasData) return const SizedBox();
            final dual = dualSnap.data!;

            return DualWinnerCard(
              title: "🥇 1st Place",
              // ⚡ ඩේටා null වුණොත් crash වීම වැළැක්වීමට ආරක්ෂිත ක්‍රම යෙදුවා
              player1Name: dual['player1Name'] ?? 'Unknown',
              player2Name: dual['player2Name'] ?? '',
              player1Image: dual['player1Image'] ?? '',
              player2Image: dual['player2Image'] ?? '',
              gradient: goldGradient,
              onTap: () async {
                final selectedDual = await showModalBottomSheet<String>(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) => const SelectDualBottomSheet(),
                );

                if (selectedDual != null) {
                  await seniorDualWinnerService.setFirstPlace(selectedDual);
                }
              },
              onDelete: () async {
                await seniorDualWinnerService.removeFirstPlace();
              },
            );
          },
        );
      },
    );
  }

  Widget _buildSecondDual() {
    return StreamBuilder(
      stream: seniorDualWinnerService.getSecondPlace(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox();

        final data = snapshot.data!.data() as Map<String, dynamic>?;
        final dualId = data?['doualId'];

        if (dualId == null) {
          return DualWinnerCard(
            title: "🥈 2nd Place",
            player1Name: "Add Winner",
            player2Name: "",
            player1Image: "",
            player2Image: "",
            gradient: silverGradient,
            onTap: () async {
              final selectedDual = await showModalBottomSheet<String>(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => const SelectDualBottomSheet(),
              );

              if (selectedDual != null) {
                await seniorDualWinnerService.setSecondPlace(selectedDual);
              }
            },
          );
        }

        return FutureBuilder(
          future: FirebaseFirestore.instance
              .collection('douals')
              .doc(dualId)
              .get(),
          builder: (context, dualSnap) {
            if (!dualSnap.hasData) return const SizedBox();
            final dual = dualSnap.data!;

            return DualWinnerCard(
              title: "🥈 2nd Place",
              player1Name: dual['player1Name'] ?? 'Unknown',
              player2Name: dual['player2Name'] ?? '',
              player1Image: dual['player1Image'] ?? '',
              player2Image: dual['player2Image'] ?? '',
              gradient: silverGradient,
              onTap: () async {
                final selectedDual = await showModalBottomSheet<String>(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) => const SelectDualBottomSheet(),
                );

                if (selectedDual != null) {
                  await seniorDualWinnerService.setSecondPlace(selectedDual);
                }
              },
              onDelete: () async {
                await seniorDualWinnerService.removeSecondPlace();
              },
            );
          },
        );
      },
    );
  }

  Widget _buildThirdDual() {
    return StreamBuilder(
      stream: seniorDualWinnerService.getThirdPlace(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox();

        final data = snapshot.data!.data() as Map<String, dynamic>?;
        final dualId = data?['doualId'];

        if (dualId == null) {
          return DualWinnerCard(
            title: "🥉 3rd Place",
            player1Name: "Add Winner",
            player2Name: "",
            player1Image: "",
            player2Image: "",
            gradient: bronzeGradient,
            onTap: () async {
              final selectedDual = await showModalBottomSheet<String>(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => const SelectDualBottomSheet(),
              );

              if (selectedDual != null) {
                await seniorDualWinnerService.setThirdPlace(selectedDual);
              }
            },
          );
        }

        return FutureBuilder(
          future: FirebaseFirestore.instance
              .collection('douals')
              .doc(dualId)
              .get(),
          builder: (context, dualSnap) {
            if (!dualSnap.hasData) return const SizedBox();
            final dual = dualSnap.data!;

            return DualWinnerCard(
              title: "🥉 3rd Place",
              player1Name: dual['player1Name'] ?? 'Unknown',
              player2Name: dual['player2Name'] ?? '',
              player1Image: dual['player1Image'] ?? '',
              player2Image: dual['player2Image'] ?? '',
              gradient: bronzeGradient,
              onTap: () async {
                final selectedDual = await showModalBottomSheet<String>(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) => const SelectDualBottomSheet(),
                );

                if (selectedDual != null) {
                  await seniorDualWinnerService.setThirdPlace(selectedDual);
                }
              },
              onDelete: () async {
                await seniorDualWinnerService.removeThirdPlace();
              },
            );
          },
        );
      },
    );
  }

  Widget _buildJuniorFirstDual() {
    return StreamBuilder(
      stream: juniorDualWinnerService.getJuniorFirstPlace(),

      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox();
        }

        final data = snapshot.data!.data() as Map<String, dynamic>?;

        final dualId = data?['doualId'];

        if (dualId == null) {
          return DualWinnerCard(
            title: "🥇 1st Place",

            player1Name: "Add Winner",

            player2Name: "",

            player1Image: "",

            player2Image: "",

            gradient: goldGradient,

            onTap: () async {
              final selectedDual = await showModalBottomSheet<String>(
                context: context,

                isScrollControlled: true,

                backgroundColor: Colors.transparent,

                builder: (_) => const SelectDualBottomSheet(),
              );

              if (selectedDual != null) {
                await juniorDualWinnerService.seJuniortFirstPlace(selectedDual);
              }
            },
          );
        }

        return FutureBuilder(
          future: FirebaseFirestore.instance
              .collection('douals')
              .doc(dualId)
              .get(),

          builder: (context, dualSnap) {
            if (!dualSnap.hasData) {
              return const SizedBox();
            }

            final dual = dualSnap.data!;

            return DualWinnerCard(
              title: "🥇 1st Place",

              player1Name: dual['player1Name'],

              player2Name: dual['player2Name'],

              player1Image: dual['player1Image'],

              player2Image: dual['player2Image'],

              gradient: goldGradient,

              onTap: () async {
                final selectedDual = await showModalBottomSheet<String>(
                  context: context,

                  isScrollControlled: true,

                  backgroundColor: Colors.transparent,

                  builder: (_) => const SelectDualBottomSheet(),
                );

                if (selectedDual != null) {
                  await juniorDualWinnerService.seJuniortFirstPlace(
                    selectedDual,
                  );
                }
              },

              onDelete: () async {
                await juniorDualWinnerService.removeJuniorFirstPlace();
              },
            );
          },
        );
      },
    );
  }

  Widget _buildJuniorSecondDual() {
    return StreamBuilder(
      stream: juniorDualWinnerService.getJuniorSecondPlace(),

      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox();
        }

        final data = snapshot.data!.data() as Map<String, dynamic>?;

        final dualId = data?['doualId'];

        if (dualId == null) {
          return DualWinnerCard(
            title: "🥈 2nd Place",

            player1Name: "Add Winner",

            player2Name: "",

            player1Image: "",

            player2Image: "",

            gradient: silverGradient,

            onTap: () async {
              final selectedDual = await showModalBottomSheet<String>(
                context: context,

                isScrollControlled: true,

                backgroundColor: Colors.transparent,

                builder: (_) => const SelectDualBottomSheet(),
              );

              if (selectedDual != null) {
                await juniorDualWinnerService.setJuniorSecondPlace(
                  selectedDual,
                );
              }
            },
          );
        }

        return FutureBuilder(
          future: FirebaseFirestore.instance
              .collection('douals')
              .doc(dualId)
              .get(),

          builder: (context, dualSnap) {
            if (!dualSnap.hasData) {
              return const SizedBox();
            }

            final dual = dualSnap.data!;

            return DualWinnerCard(
              title: "🥈 2nd Place",

              player1Name: dual['player1Name'],

              player2Name: dual['player2Name'],

              player1Image: dual['player1Image'],

              player2Image: dual['player2Image'],

              gradient: silverGradient,

              onTap: () async {
                final selectedDual = await showModalBottomSheet<String>(
                  context: context,

                  isScrollControlled: true,

                  backgroundColor: Colors.transparent,

                  builder: (_) => const SelectDualBottomSheet(),
                );

                if (selectedDual != null) {
                  await juniorDualWinnerService.setJuniorSecondPlace(
                    selectedDual,
                  );
                }
              },

              onDelete: () async {
                await juniorDualWinnerService.removeJuniorSecondPlace();
              },
            );
          },
        );
      },
    );
  }

  Widget _buildJuniorThirdDual() {
    return StreamBuilder(
      stream: juniorDualWinnerService.getJuniorThirdPlace(),

      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox();
        }

        final data = snapshot.data!.data() as Map<String, dynamic>?;

        final dualId = data?['doualId'];

        if (dualId == null) {
          return DualWinnerCard(
            title: "🥉 3rd Place",

            player1Name: "Add Winner",

            player2Name: "",

            player1Image: "",

            player2Image: "",

            gradient: bronzeGradient,

            onTap: () async {
              final selectedDual = await showModalBottomSheet<String>(
                context: context,

                isScrollControlled: true,

                backgroundColor: Colors.transparent,

                builder: (_) => const SelectDualBottomSheet(),
              );

              if (selectedDual != null) {
                await juniorDualWinnerService.setJuniorThirdPlace(selectedDual);
              }
            },
          );
        }

        return FutureBuilder(
          future: FirebaseFirestore.instance
              .collection('douals')
              .doc(dualId)
              .get(),

          builder: (context, dualSnap) {
            if (!dualSnap.hasData) {
              return const SizedBox();
            }

            final dual = dualSnap.data!;

            return DualWinnerCard(
              title: "🥉 3rd Place",

              player1Name: dual['player1Name'],

              player2Name: dual['player2Name'],

              player1Image: dual['player1Image'],

              player2Image: dual['player2Image'],

              gradient: bronzeGradient,

              onTap: () async {
                final selectedDual = await showModalBottomSheet<String>(
                  context: context,

                  isScrollControlled: true,

                  backgroundColor: Colors.transparent,

                  builder: (_) => const SelectDualBottomSheet(),
                );

                if (selectedDual != null) {
                  await juniorDualWinnerService.setJuniorThirdPlace(
                    selectedDual,
                  );
                }
              },

              onDelete: () async {
                await juniorDualWinnerService.removeJuniorThirdPlace();
              },
            );
          },
        );
      },
    );
  }
}
