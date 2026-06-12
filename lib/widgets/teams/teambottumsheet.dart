import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:didula_api/services/teamservise.dart';
import 'package:flutter/material.dart';

class CreateTeamBottomSheet extends StatefulWidget {
  const CreateTeamBottomSheet({super.key});

  @override
  State<CreateTeamBottomSheet> createState() => _CreateTeamBottomSheetState();
}

class _CreateTeamBottomSheetState extends State<CreateTeamBottomSheet> {
  final TextEditingController teamNameController = TextEditingController();
  final TextEditingController searchController = TextEditingController();
  final Teamservise teamService =
      Teamservise(); // Ensure spelling matches your service

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
      height: MediaQuery.of(context).size.height * 0.85,
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Color(0xff081420),
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        children: [
          Container(
            width: 60,
            height: 5,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(20),
            ),
          ),

          TextField(
            controller: teamNameController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Team Name',
              hintStyle: const TextStyle(color: Colors.grey),
              filled: true,
              fillColor: Colors.white10,
              // ShapedInputBorder වෙනුවට OutlineInputBorder භාවිතා කලා 🛠️
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none,
              ),
            ),
          ),

          const SizedBox(height: 15),

          TextField(
            controller: searchController,
            style: const TextStyle(color: Colors.white),
            onChanged: (value) {
              setState(() {
                searchText = value.toLowerCase();
              });
            },
            decoration: InputDecoration(
              hintText: 'Search User',
              hintStyle: const TextStyle(color: Colors.grey),
              prefixIcon: const Icon(Icons.search, color: Colors.grey),
              filled: true,
              fillColor: Colors.white10,

              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none,
              ),
            ),
          ),

          const SizedBox(height: 15),

          Text(
            "Selected Players : ${selectedUserIds.length}",
            style: const TextStyle(color: Colors.white),
          ),

          const SizedBox(height: 15),

          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final users = snapshot.data!.docs;

                final filteredUsers = users.where((user) {
                  final name = (user['name'] ?? '').toString().toLowerCase();
                  return name.contains(searchText);
                }).toList();

                if (filteredUsers.isEmpty) {
                  return const Center(
                    child: Text(
                      'No Users Found',
                      style: TextStyle(color: Colors.white),
                    ),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,

                  itemCount: filteredUsers.length,
                  itemBuilder: (context, index) {
                    final user = filteredUsers[index];
                    final isSelected = selectedUserIds.contains(user.id);
                    final imageUrl = user['imageUrl'] ?? '';

                    return Material(
                      color: Colors.transparent,
                      child: CheckboxListTile(
                        value: isSelected,
                        activeColor: const Color.fromARGB(255, 1, 53, 136),
                        checkColor: Colors.white,
                        side: const BorderSide(color: Colors.white60, width: 2),
                        onChanged: (_) {
                          setState(() {
                            if (isSelected) {
                              selectedUserIds.remove(user.id);
                            } else {
                              selectedUserIds.add(user.id);
                            }
                          });
                        },
                        title: Text(
                          user['name'] ?? 'Unknown',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        secondary: CircleAvatar(
                          backgroundColor: Colors.grey[700],
                          backgroundImage:
                              imageUrl.isNotEmpty && imageUrl.startsWith('http')
                              ? NetworkImage(imageUrl)
                              : null,
                          child:
                              imageUrl.isEmpty || !imageUrl.startsWith('http')
                              ? const Icon(Icons.person, color: Colors.white)
                              : null,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          const SizedBox(height: 10),

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
                if (teamNameController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter a team name')),
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

                await teamService.createTeam(
                  teamName: teamNameController.text.trim(),
                  memberIds: selectedUserIds,
                );

                if (!mounted) return;
                Navigator.pop(context);
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
      ),
    );
  }
}
