import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:didula_api/models/doualmodel.dart';
import 'package:didula_api/services/douleservices.dart';
import 'package:didula_api/widgets/doules/doualcard.dart';
import 'package:didula_api/widgets/doules/doulebottomsheet.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class DoualsPage extends StatefulWidget {
  DoualsPage({super.key});

  @override
  State<DoualsPage> createState() => _DoualsPageState();
}

class _DoualsPageState extends State<DoualsPage> {
  final DoualService doualService = DoualService();

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
      backgroundColor: const Color(0xff020617),

      appBar: AppBar(
        title: const Text(
          "Douals",
          style: TextStyle(
            color: Color.fromARGB(255, 255, 255, 255),
            fontWeight: FontWeight.bold,
            fontSize: 26,
          ),
        ),

        backgroundColor: Colors.transparent,
      ),

      floatingActionButton: userRole == "admin"
          ? FloatingActionButton(
              onPressed: () {
                showModalBottomSheet(
                  context: context,

                  isScrollControlled: true,

                  backgroundColor: Colors.transparent,

                  builder: (context) {
                    return const CreateDoualBottomSheet();
                  },
                );
              },

              child: const Icon(Icons.add),
            )
          : null,

      body: SingleChildScrollView(
        child: StreamBuilder<QuerySnapshot>(
          stream: doualService.getDouals(),

          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,

                  children: [
                    Icon(Icons.groups_2, size: 80, color: Colors.grey.shade600),

                    const SizedBox(height: 15),

                    Text(
                      "No Douals Yet",
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              );
            }

            final douals = snapshot.data!.docs;

            return ListView.builder(
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              padding: const EdgeInsets.only(top: 15, bottom: 100),

              itemCount: douals.length,

              itemBuilder: (context, index) {
                final doual = DoualModel.fromJson(
                  douals[index].data() as Map<String, dynamic>,
                );

                return DoualCard(
                  doualId: doual.doualId,

                  player1Id: doual.player1Ids,

                  player2Id: doual.player2Ids,

                  onDelete: () {
                    showDialog(
                      context: context,

                      builder: (context) {
                        return AlertDialog(
                          title: const Text("Delete Doual"),

                          content: const Text(
                            "Are you sure you want to delete this doual?",
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

                                await doualService.deleteDoual(doual.doualId);

                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Doual Deleted"),
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
    );
  }
}
