import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:didula_api/services/winteamlservice.dart';
import 'package:flutter/material.dart';

// සටහන: ඔබේ ව්‍යාපෘතියේ WinTeamservise තියෙන path එක මෙතන import කරගන්න
// import 'path_to_your_service/teamservise.dart';

class WinTeamBottomSheet extends StatefulWidget {
  const WinTeamBottomSheet({super.key});

  @override
  State<WinTeamBottomSheet> createState() => _WinTeamBottomSheetState();
}

class _WinTeamBottomSheetState extends State<WinTeamBottomSheet> {
  final TextEditingController teamNameController = TextEditingController();
  final TextEditingController searchController = TextEditingController();
  final WinTeamservise winTeamservise = WinTeamservise();

  List<String> selectedUserIds = [];
  String searchText = '';

  @override
  void dispose() {
    teamNameController.dispose();
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      decoration: const BoxDecoration(
        color: Color(0xff081420),
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),

      child: StatefulBuilder(
        builder: (BuildContext context, StateSetter setSheetState) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Top Handle Bar
              Container(
                width: 60,
                height: 5,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),

              // Team Name Input Field
              TextField(
                controller: teamNameController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Team Name',
                  hintStyle: const TextStyle(color: Colors.white54),
                  filled: true,
                  fillColor: Colors.white10,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 15),

              // Search User Input Field
              TextField(
                controller: searchController,
                style: const TextStyle(color: Colors.white),
                onChanged: (value) {
                  setSheetState(() {
                    searchText = value.toLowerCase();
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Search User',
                  hintStyle: const TextStyle(color: Colors.white54),
                  prefixIcon: const Icon(Icons.search, color: Colors.white70),
                  filled: true,
                  fillColor: Colors.white10,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 15),

              // Selected Count Text
              Text(
                "Selected Players : ${selectedUserIds.length}",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 15),

              SizedBox(
                height: MediaQuery.of(context).size.height * 0.35,
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return const Center(
                        child: Text(
                          "Something went wrong",
                          style: TextStyle(color: Colors.white),
                        ),
                      );
                    }

                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final users = snapshot.data!.docs;

                    final filteredUsers = users.where((user) {
                      final name = user['name'].toString().toLowerCase();
                      return name.contains(searchText);
                    }).toList();

                    if (filteredUsers.isEmpty) {
                      return const Center(
                        child: Text(
                          "No users found",
                          style: TextStyle(color: Colors.white54),
                        ),
                      );
                    }

                    return ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: filteredUsers.length,
                      itemBuilder: (context, index) {
                        final user = filteredUsers[index];
                        final isSelected = selectedUserIds.contains(user.id);
                        final imageUrl = user['imageUrl'] ?? '';

                        return Material(
                          color: Colors.transparent,
                          child: CheckboxListTile(
                            value: isSelected,
                            activeColor: Colors.blue,
                            checkColor: Colors.white,
                            title: Text(
                              user['name'],
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            onChanged: (_) {
                              setSheetState(() {
                                if (isSelected) {
                                  selectedUserIds.remove(user.id);
                                } else {
                                  selectedUserIds.add(user.id);
                                }
                              });
                            },
                            secondary: CircleAvatar(
                              backgroundColor: Colors.white10,
                              backgroundImage:
                                  imageUrl.toString().startsWith('http')
                                  ? NetworkImage(imageUrl.toString())
                                  : null,
                              child: !imageUrl.toString().startsWith('http')
                                  ? const Icon(
                                      Icons.person,
                                      color: Colors.white70,
                                    )
                                  : null,
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 15),

              // Create Team Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 1, 53, 136),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  onPressed: () async {
                    final teamName = teamNameController.text.trim();

                    if (teamName.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please enter a team name'),
                        ),
                      );
                      return;
                    }

                    if (selectedUserIds.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please select at least one player'),
                        ),
                      );
                      return;
                    }

                    await winTeamservise.createWinTeam(
                      winteamName: teamName,
                      membersId: selectedUserIds,
                    );

                    if (mounted) {
                      Navigator.pop(context); // Bottom Sheet එක වසන්න
                    }
                  },
                  child: const Text(
                    'Create Team',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 25),
            ],
          );
        },
      ),
    );
  }
}
