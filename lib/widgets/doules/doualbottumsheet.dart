import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SelectDualBottomSheet extends StatefulWidget {
  const SelectDualBottomSheet({super.key});

  @override
  State<SelectDualBottomSheet> createState() => _SelectDualBottomSheetState();
}

class _SelectDualBottomSheetState extends State<SelectDualBottomSheet> {
  final TextEditingController searchController = TextEditingController();

  String searchText = '';

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,

      padding: const EdgeInsets.all(16),

      decoration: const BoxDecoration(
        color: Color(0xFF0D1B3E),

        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),

      child: Column(
        children: [
          Container(
            width: 50,
            height: 5,

            decoration: BoxDecoration(
              color: Colors.white30,

              borderRadius: BorderRadius.circular(20),
            ),
          ),

          const SizedBox(height: 20),

          const Text(
            "Select Dual Winner",

            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 20),

          TextField(
            controller: searchController,

            onChanged: (value) {
              setState(() {
                searchText = value.toLowerCase();
              });
            },

            style: const TextStyle(color: Colors.white),

            decoration: InputDecoration(
              hintText: "Search Dual",

              hintStyle: const TextStyle(color: Colors.white54),

              prefixIcon: const Icon(Icons.search, color: Colors.white),

              filled: true,

              fillColor: Colors.white10,

              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
          ),

          const SizedBox(height: 20),

          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('douals')
                  .snapshots(),

              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final duals = snapshot.data!.docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;

                  final p1 = data['player1Name'] ?? '';

                  final p2 = data['player2Name'] ?? '';

                  return p1.toLowerCase().contains(searchText) ||
                      p2.toLowerCase().contains(searchText);
                }).toList();

                if (duals.isEmpty) {
                  return const Center(
                    child: Text(
                      "No Duals Found",

                      style: TextStyle(color: Colors.white),
                    ),
                  );
                }

                return ListView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: duals.length,

                  itemBuilder: (context, index) {
                    final dual = duals[index];

                    final data = dual.data() as Map<String, dynamic>;

                    return Card(
                      color: Colors.white10,

                      margin: const EdgeInsets.only(bottom: 12),

                      child: ListTile(
                        onTap: () {
                          Navigator.pop(context, dual.id);
                        },

                        leading: CircleAvatar(
                          backgroundImage:
                              data['player1Image'] != null &&
                                  data['player1Image'].toString().isNotEmpty
                              ? NetworkImage(data['player1Image'])
                              : null,

                          child: data['player1Image'] == null
                              ? const Icon(Icons.person)
                              : null,
                        ),

                        title: Text(
                          "${data['player1Name']} 🤝 ${data['player2Name']}",

                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        subtitle: const Text(
                          "Tap to Select",

                          style: TextStyle(color: Colors.white70),
                        ),

                        trailing: const Icon(
                          Icons.arrow_forward_ios,

                          color: Colors.white,
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
