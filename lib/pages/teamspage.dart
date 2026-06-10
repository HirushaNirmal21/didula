import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:didula_api/models/teammodel.dart';
import 'package:didula_api/services/teamservise.dart';
import 'package:didula_api/widgets/teams/teambottumsheet.dart';
import 'package:didula_api/widgets/teams/teamcard.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class TeamsPage extends StatefulWidget {
  TeamsPage({super.key});

  @override
  State<TeamsPage> createState() => _TeamsPageState();
}

class _TeamsPageState extends State<TeamsPage> {
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

  final Teamservise teamServise = Teamservise();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color.fromARGB(255, 0, 1, 18),

        title: const Text(
          'Teams',

          style: TextStyle(
            color: Color.fromARGB(255, 255, 255, 255),
            fontWeight: FontWeight.bold,
            fontSize: 26,
          ),
        ),
      ),
      backgroundColor: const Color(0xff020617),

      floatingActionButton: userRole == "admin"
          ? FloatingActionButton(
              onPressed: () {
                showModalBottomSheet(
                  context: context,

                  isScrollControlled: true,

                  backgroundColor: Colors.transparent,

                  builder: (context) {
                    return const CreateTeamBottomSheet();
                  },
                );
              },

              child: const Icon(Icons.add),
            )
          : null,

      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(15),

            child: StreamBuilder(
              stream: teamServise.getTeams(),

              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final teams = snapshot.data!.docs;

                if (teams.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,

                      children: [
                        Icon(
                          Icons.groups_2,
                          size: 80,
                          color: Colors.grey.shade600,
                        ),

                        const SizedBox(height: 15),

                        Text(
                          "No Teams Yet",
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
                  itemCount: teams.length,
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,

                  itemBuilder: (context, index) {
                    final team = TeamModel.fromMap(
                      teams[index].data() as Map<String, dynamic>,
                    );

                    return TeamCard(
                      teamId: team.teamid,

                      teamName: team.teamName,

                      memberIds: team.members,

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

                                    await teamServise.deleteTeam(team.teamid);

                                    ScaffoldMessenger.of(context).showSnackBar(
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
      ),
    );
  }
}
