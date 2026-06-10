import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:didula_api/services/douleservices.dart';
import 'package:flutter/material.dart';

//create doual

class CreateDoualBottomSheet extends StatefulWidget {
  const CreateDoualBottomSheet({super.key});

  @override
  State<CreateDoualBottomSheet> createState() => _CreateDoualBottomSheetState();
}

class _CreateDoualBottomSheetState extends State<CreateDoualBottomSheet> {
  final DoualService doualService = DoualService();
  final TextEditingController searchController = TextEditingController();
  List<String> selectedUserIds = [];
  String searchText = '';

  @override
  void dispose() {
    searchController.dispose(); // Memory leak වීම වැළැක්වීමට dispose කරන්න
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
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            "Create Doual",
            style: TextStyle(
              color: Colors.white,
              fontSize: 25,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: searchController,
            style: const TextStyle(
              color: Colors.white,
            ), // Type කරන අකුරු සුදු පාටින් පෙනීමට
            onChanged: (value) {
              setState(() {
                searchText = value.toLowerCase();
              });
            },
            decoration: InputDecoration(
              hintText: "Search Player",
              hintStyle: const TextStyle(color: Colors.grey),
              prefixIcon: const Icon(Icons.search, color: Colors.grey),
              filled: true,
              fillColor: Colors.white10,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide:
                    BorderSide.none, // Input border එක වඩාත් ලස්සන කිරීමට
              ),
            ),
          ),
          const SizedBox(height: 15),
          Text(
            "Selected Players : ${selectedUserIds.length}/2",
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
                  // ආරක්ෂිතව නම string එකක් බවට හරවා check කිරීම
                  final name = (user['name'] ?? '').toString().toLowerCase();
                  return name.contains(searchText);
                }).toList();

                if (filteredUsers.isEmpty) {
                  return const Center(
                    child: Text(
                      'No Players Found',
                      style: TextStyle(color: Colors.white),
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: filteredUsers.length,
                  itemBuilder: (context, index) {
                    final user = filteredUsers[index];
                    final isSelected = selectedUserIds.contains(user.id);

                    // Image URL එක ආරක්ෂිතව check කිරීම 🔍
                    final String? imageUrl = user['imageUrl'];
                    final bool hasValidUrl =
                        imageUrl != null &&
                        imageUrl.isNotEmpty &&
                        imageUrl.startsWith('http');

                    return Material(
                      color: Colors
                          .transparent, // Material එක transparent කිරීමෙන් background color එකට බාධාවක් නොවේ
                      child: CheckboxListTile(
                        value: isSelected,
                        activeColor: const Color.fromARGB(255, 1, 53, 136),
                        checkColor: Colors.white,
                        // Checkbox එකේ කොටුව නිසි පරිදි පෙනීමට
                        side: const BorderSide(color: Colors.white60, width: 2),
                        onChanged: (_) {
                          setState(() {
                            if (isSelected) {
                              selectedUserIds.remove(user.id);
                            } else {
                              if (selectedUserIds.length < 2) {
                                selectedUserIds.add(user.id);
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Only 2 players allowed'),
                                  ),
                                );
                              }
                            }
                          });
                        },
                        secondary: CircleAvatar(
                          backgroundColor: Colors.grey[700],
                          backgroundImage: hasValidUrl
                              ? NetworkImage(imageUrl)
                              : null,
                          child: !hasValidUrl
                              ? const Icon(Icons.person, color: Colors.white)
                              : null,
                        ),
                        title: Text(
                          user['name'] ?? 'Unknown',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
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
                if (selectedUserIds.length != 2) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Select 2 players')),
                  );
                  return;
                }

                try {
                  final player1Doc = await FirebaseFirestore.instance
                      .collection('users')
                      .doc(selectedUserIds[0])
                      .get();

                  final player2Doc = await FirebaseFirestore.instance
                      .collection('users')
                      .doc(selectedUserIds[1])
                      .get();

                  final player1 = player1Doc.data() as Map<String, dynamic>;

                  final player2 = player2Doc.data() as Map<String, dynamic>;

                  await doualService.createDoual(
                    player1Ids: selectedUserIds[0],
                    player2Ids: selectedUserIds[1],

                    player1Name: player1['name'] ?? '',
                    player2Name: player2['name'] ?? '',

                    player1Image: player1['imageUrl'] ?? '',
                    player2Image: player2['imageUrl'] ?? '',
                  );

                  if (!mounted) return;

                  Navigator.pop(context);

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Doual Created Successfully')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Error: $e')));
                }
              },
              child: const Text(
                "Create Doual",
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
