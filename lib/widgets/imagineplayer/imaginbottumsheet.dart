import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SpecialPlayerBottomSheet extends StatefulWidget {
  final Function(String) onUserSelected;

  const SpecialPlayerBottomSheet({super.key, required this.onUserSelected});

  @override
  State<SpecialPlayerBottomSheet> createState() =>
      _SpecialPlayerBottomSheetState();
}

class _SpecialPlayerBottomSheetState extends State<SpecialPlayerBottomSheet> {
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

      child: StatefulBuilder(
        builder: (BuildContext context, StateSetter setSheetState) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Title
              const Text(
                "Select Player",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 15),

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
                  prefixIcon: const Icon(Icons.search, color: Colors.white70),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: const BorderSide(color: Colors.white30),
                  ),
                ),
              ),
              const SizedBox(height: 15),

              SizedBox(
                height: MediaQuery.of(context).size.height * 0.45,
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

                    final users = snapshot.data!.docs.where((user) {
                      final name =
                          (user.data() as Map<String, dynamic>).containsKey(
                            'name',
                          )
                          ? user['name'].toString().toLowerCase()
                          : '';
                      return name.contains(search);
                    }).toList();

                    if (users.isEmpty) {
                      return const Center(
                        child: Text(
                          "No players found",
                          style: TextStyle(color: Colors.white54),
                        ),
                      );
                    }

                    return ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: users.length,
                      itemBuilder: (context, index) {
                        final user = users[index];
                        final userData = user.data() as Map<String, dynamic>;
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
                                      imageUrl.toString().isNotEmpty
                                  ? NetworkImage(imageUrl.toString())
                                  : null,
                              child:
                                  imageUrl == null ||
                                      imageUrl.toString().isEmpty
                                  ? const Icon(
                                      Icons.person,
                                      color: Colors.white,
                                    )
                                  : null,
                            ),
                            title: Text(
                              user['name'] ?? 'Unknown',
                              style: const TextStyle(color: Colors.white),
                            ),
                            onTap: () {
                              widget.onUserSelected(user.id);
                              Navigator.pop(context);
                            },
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
