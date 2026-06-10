import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SeniorIndividualBottomSheet extends StatefulWidget {
  final Function(String) onUserSelected;

  const SeniorIndividualBottomSheet({super.key, required this.onUserSelected});

  @override
  State<SeniorIndividualBottomSheet> createState() =>
      _SeniorIndividualBottomSheetState();
}

class _SeniorIndividualBottomSheetState
    extends State<SeniorIndividualBottomSheet> {
  String search = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
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
      // ⚡ StreamBuilder එක මුලටම ගත්තා. දැන් Firebase එකෙන් ඩේටා ගන්නේ එකම එක පාරයි!
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
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
            return const SizedBox(
              height: 200,
              child: Center(child: CircularProgressIndicator()),
            );
          }

          final allUsers = snapshot.data!.docs;

          // ⚡ StatefulBuilder එක දැම්මේ සර්ච් ටයිප් කරනකොට UI එක විතරක් අප්ඩේට් වෙන්න
          return StatefulBuilder(
            builder: (BuildContext context, StateSetter setSheetState) {
              // ⚡ ෆෝන් එකේ මෙමරි එක ඇතුළෙන්ම සර්ච් එක ෆිල්ටර් කරනවා (No More Firebase Re-fetch)
              final filteredUsers = allUsers.where((user) {
                final userData = user.data() as Map<String, dynamic>;
                final name = userData.containsKey('name')
                    ? user['name'].toString().toLowerCase()
                    : '';
                return name.contains(search);
              }).toList();

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

                  // Search Field
                  TextField(
                    controller: _searchController,
                    style: const TextStyle(color: Colors.white),
                    onChanged: (value) {
                      setSheetState(() {
                        search = value.toLowerCase();
                      });
                    },
                    decoration: InputDecoration(
                      hintText: "Search User",
                      hintStyle: const TextStyle(color: Colors.white54),
                      prefixIcon: const Icon(
                        Icons.search,
                        color: Colors.white70,
                      ),
                      filled: true,
                      fillColor: Colors.white10,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),

                  // Users List
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.45,
                    child: filteredUsers.isEmpty
                        ? const Center(
                            child: Text(
                              "No players found",
                              style: TextStyle(color: Colors.white54),
                            ),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: filteredUsers.length,
                            itemBuilder: (context, index) {
                              final user = filteredUsers[index];
                              final userData =
                                  user.data() as Map<String, dynamic>;
                              final imageUrl = userData.containsKey('imageUrl')
                                  ? user['imageUrl']
                                  : '';

                              return Material(
                                color: Colors.transparent,
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: Colors.grey[800],
                                    backgroundImage:
                                        imageUrl != null &&
                                            imageUrl.toString().isNotEmpty &&
                                            imageUrl.toString().startsWith(
                                              'http',
                                            )
                                        ? NetworkImage(imageUrl.toString())
                                        : null,
                                    child:
                                        imageUrl == null ||
                                            imageUrl.toString().isEmpty ||
                                            !imageUrl.toString().startsWith(
                                              'http',
                                            )
                                        ? const Icon(
                                            Icons.person,
                                            color: Colors.white,
                                          )
                                        : null,
                                  ),
                                  title: Text(
                                    user['name'] ?? 'Unknown',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  onTap: () {
                                    widget.onUserSelected(user.id);
                                    Navigator.pop(
                                      context,
                                    ); // සිලෙක්ට් කරපු ගමන් වහන්න
                                  },
                                ),
                              );
                            },
                          ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
