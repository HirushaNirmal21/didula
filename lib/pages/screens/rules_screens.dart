import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:didula_api/functions/util_function.dart';
import 'package:didula_api/models/rulesmodel.dart';
import 'package:didula_api/services/Ruleservice.dart';
import 'package:didula_api/widgets/custom/custom_textfield.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'dart:ui';

class RulesScreens extends StatefulWidget {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;

  RulesScreens({super.key, FirebaseFirestore? firestore, FirebaseAuth? auth})
    : firestore = firestore ?? FirebaseFirestore.instance,
      auth = auth ?? FirebaseAuth.instance;

  @override
  State<RulesScreens> createState() => _RulesScreensState();
}

class _RulesScreensState extends State<RulesScreens> {
  final _formKey = GlobalKey<FormState>();
  String userRole = "user";
  bool isLoading = true;

  final TextEditingController _ruleEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchUserRole();
  }

  @override
  void dispose() {
    _ruleEditingController.dispose();
    super.dispose();
  }

  Future<void> _fetchUserRole() async {
    final user = widget.auth.currentUser;
    if (user == null) {
      setState(() => isLoading = false);
      return;
    }

    try {
      final doc = await widget.firestore
          .collection('users')
          .doc(user.uid)
          .get();
      if (mounted) {
        setState(() {
          userRole = doc.data()?['role'] ?? 'user';
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  Future<void> _deleteRule({
    required String ruleId,
    required BuildContext context,
  }) async {
    try {
      await Ruleservice().deleteRule(ruleId: ruleId);
      if (context.mounted) {
        UtilFunction().showSnackBar(context, "Rule Deleted");
      }
    } catch (e) {
      if (context.mounted) {
        UtilFunction().showSnackBar(context, "Can't Delete Rule");
      }
    }
  }

  void _submitRules(BuildContext context) async {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();

      try {
        final Rulesmodel rule = Rulesmodel(
          ruleId: "",
          description: _ruleEditingController.text,
          userId: widget.auth.currentUser?.uid ?? "currentUserId",
        );

        await Ruleservice().createRule(rule);

        if (context.mounted) {
          UtilFunction().showSnackBar(context, "Rule Created");
        }

        await Future.delayed(const Duration(milliseconds: 500));

        if (context.mounted) {
          Navigator.pop(context);
        }
        _ruleEditingController.clear();
      } catch (e) {
        if (context.mounted) {
          UtilFunction().showSnackBar(context, "Can't create rule");
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 0, 1, 18),
      body: SafeArea(
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Colors.white),
              )
            : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 15,
                    horizontal: 14,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // --- Header Area ---
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Game Rules",
                            style: GoogleFonts.poppins(
                              letterSpacing: 0.5,
                              shadows: [
                                Shadow(
                                  blurRadius: 10.0,
                                  color: Colors.black.withOpacity(0.3),
                                  offset: const Offset(0, 5),
                                ),
                              ],
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          // Admin ට විතරක් පේන Add Button එක
                          if (userRole == "admin")
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white.withOpacity(0.95),
                                foregroundColor: Colors.black,
                                elevation: 2,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                  horizontal: 16,
                                ),
                              ),
                              onPressed: () {
                                showModalBottomSheet(
                                  context: context,
                                  backgroundColor: const Color(0xff111827),
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(30),
                                    ),
                                  ),
                                  isScrollControlled: true,
                                  builder: (context) {
                                    return Padding(
                                      padding: EdgeInsets.only(
                                        left: 20,
                                        right: 20,
                                        top: 20,
                                        bottom:
                                            MediaQuery.of(
                                              context,
                                            ).viewInsets.bottom +
                                            20,
                                      ),
                                      child: Form(
                                        key: _formKey,
                                        child: SingleChildScrollView(
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Container(
                                                width: 60,
                                                height: 5,
                                                decoration: BoxDecoration(
                                                  color: Colors.white24,
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                ),
                                              ),
                                              const SizedBox(height: 20),
                                              Text(
                                                "Add Tournament Rule",
                                                style: GoogleFonts.poppins(
                                                  fontSize: 18,
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(height: 15),
                                              Custominput(
                                                controller:
                                                    _ruleEditingController,
                                                lableText:
                                                    "Type your rule here...",
                                                obscureText: false,
                                                validator: (value) {
                                                  if (value?.isEmpty ?? true) {
                                                    return "Please Enter a Rule";
                                                  }
                                                  return null;
                                                },
                                              ),
                                              const SizedBox(height: 20),
                                              ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.white,
                                                  minimumSize: const Size(
                                                    double.infinity,
                                                    48,
                                                  ),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          12,
                                                        ),
                                                  ),
                                                ),
                                                onPressed: () =>
                                                    _submitRules(context),
                                                child: Text(
                                                  "Save Rule",
                                                  style: GoogleFonts.poppins(
                                                    color: Colors.black,
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                              child: const Row(
                                children: [
                                  Icon(
                                    Icons.add_rounded,
                                    color: Colors.black,
                                    size: 20,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    "Add Rule",
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // --- Main Notice Glass Container ---
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                          child: Container(
                            padding: const EdgeInsets.all(16.0),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.04),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.1),
                                width: 1.2,
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(
                                  Icons.gavel_rounded,
                                  color: Colors.amber,
                                  size: 24,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    "All tournament decisions are strictly based on these rules. Every participant is required to adhere to them. Any breach of these regulations will lead to immediate termination from the tournament.",
                                    style: GoogleFonts.poppins(
                                      color: Colors.white.withOpacity(0.85),
                                      fontSize: 16,
                                      height: 1.4,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 15),
                      Divider(
                        color: Colors.white.withOpacity(0.1),
                        thickness: 1,
                      ),
                      const SizedBox(height: 10),

                      // --- Rules List Stream ---
                      StreamBuilder(
                        stream: Ruleservice().rules,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(20.0),
                                child: CircularProgressIndicator(
                                  color: Colors.cyan,
                                ),
                              ),
                            );
                          } else if (snapshot.hasError) {
                            return Center(
                              child: Text(
                                'Error: ${snapshot.error}',
                                style: const TextStyle(color: Colors.white),
                              ),
                            );
                          } else if (!snapshot.hasData ||
                              snapshot.data!.isEmpty) {
                            return Center(
                              child: Padding(
                                padding: const EdgeInsets.all(30.0),
                                child: Text(
                                  'No rules available yet.',
                                  style: GoogleFonts.poppins(
                                    color: Colors.white54,
                                  ),
                                ),
                              ),
                            );
                          }

                          final ruleList = snapshot.data!;

                          return ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: ruleList.length,
                            itemBuilder: (context, index) {
                              final currentRule = ruleList[index];

                              // ⭐ Glassmorphic Rule Card Component ⭐
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8.0,
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: BackdropFilter(
                                    filter: ImageFilter.blur(
                                      sigmaX: 12,
                                      sigmaY: 12,
                                    ),
                                    child: Container(
                                      padding: const EdgeInsets.all(16.0),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.06),
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color: Colors.white.withOpacity(0.12),
                                          width: 1.5,
                                        ),
                                        gradient: LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [
                                            Colors.white.withOpacity(0.08),
                                            Colors.white.withOpacity(0.01),
                                          ],
                                        ),
                                      ),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          // 🏓 Table Tennis Styled Bullet Point
                                          const Padding(
                                            padding: EdgeInsets.only(
                                              top: 3.0,
                                              right: 12.0,
                                            ),
                                            child: Icon(
                                              Icons.sports_tennis_rounded,
                                              color: Color.fromARGB(
                                                255,
                                                0,
                                                221,
                                                255,
                                              ), // Cyan Accent
                                              size: 18,
                                            ),
                                          ),

                                          // Rule Content
                                          Expanded(
                                            child: Text(
                                              currentRule.description,
                                              style: GoogleFonts.poppins(
                                                color: Colors.white.withOpacity(
                                                  0.9,
                                                ),
                                                fontSize: 15,
                                                height: 1.4,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),

                                          if (userRole == "admin")
                                            IconButton(
                                              icon: const Icon(
                                                Icons.delete_outline_rounded,
                                                color: Colors.redAccent,
                                                size: 22,
                                              ),
                                              constraints:
                                                  const BoxConstraints(),
                                              padding: const EdgeInsets.only(
                                                left: 8.0,
                                              ),
                                              onPressed: () => _deleteRule(
                                                ruleId: currentRule.ruleId,
                                                context: context,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
