import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:didula_api/services/sponser_service.dart';
import 'package:flutter/material.dart';

class SponsorBottomSheet extends StatefulWidget {
  const SponsorBottomSheet({super.key});

  @override
  State<SponsorBottomSheet> createState() => _SponsorBottomSheetState();
}

class _SponsorBottomSheetState extends State<SponsorBottomSheet> {
  final TextEditingController searchController = TextEditingController();
  final SponsorService sponsorService = SponsorService();
  String searchText = '';

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xff111827),
      padding: const EdgeInsets.all(20),
      height: 500,
      child: Column(
        children: [
          TextField(
            controller: searchController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Search user',
              hintStyle: const TextStyle(color: Colors.grey),
              prefixIcon: const Icon(Icons.search, color: Colors.grey),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            onChanged: (value) {
              setState(() {
                searchText = value;
              });
            },
          ),
          const SizedBox(height: 20),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: sponsorService.searchUsers(searchText),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final users = snapshot.data!.docs;

                if (users.isEmpty) {
                  return const Center(
                    child: Text(
                      'No Users Found',
                      style: TextStyle(color: Colors.white),
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index];

                    final String? imageUrl = user['imageUrl'];
                    final bool hasValidUrl =
                        imageUrl != null &&
                        imageUrl.isNotEmpty &&
                        imageUrl.startsWith('http');

                    return Card(
                      color: const Color(0xff1E293B),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.grey[700],

                          backgroundImage: hasValidUrl
                              ? NetworkImage(imageUrl)
                              : null,
                          child: !hasValidUrl
                              ? const Icon(Icons.person, color: Colors.white)
                              : null,
                        ),
                        title: Text(
                          user['name'] ?? 'Unknown User',
                          style: const TextStyle(
                            color: Color.fromARGB(255, 255, 255, 255),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        trailing: IconButton(
                          icon: const Icon(
                            Icons.add,
                            color: Color.fromARGB(255, 255, 255, 255),
                          ),
                          onPressed: () async {
                            await sponsorService.makeSponsor(user.id);

                            if (!mounted) return;

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Sponsor Added')),
                            );

                            Navigator.pop(context);
                          },
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
