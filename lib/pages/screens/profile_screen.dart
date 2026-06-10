import 'dart:ui';
import 'package:didula_api/models/usermodel.dart';
import 'package:didula_api/services/auth_services.dart';
import 'package:didula_api/services/userservices.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<Usermodel?> _userFuture;

  late String _currentUserId;

  late UserService _userService;

  bool _isEditing = false;

  bool _isSaving = false;

  final TextEditingController _nameController = TextEditingController();

  final TextEditingController _levelController = TextEditingController();

  File? _pickedImage;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();

    _userService = UserService();

    _currentUserId = FirebaseAuth.instance.currentUser!.uid;

    _userFuture = _fetchUserDetails();
  }

  @override
  void dispose() {
    _nameController.dispose();

    _levelController.dispose();

    super.dispose();
  }

  Future<Usermodel?> _fetchUserDetails() async {
    try {
      final userId = AuthService().getCurrentUser()?.uid ?? "";

      if (userId.isEmpty) return null;

      return await _userService.getUserById(userId);
    } catch (e) {
      print("Error fetching user details: $e");

      return null;
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,

      imageQuality: 50,
    );

    if (pickedFile != null) {
      setState(() {
        _pickedImage = File(pickedFile.path);
      });
    }
  }

  void _startEditing(Usermodel user) {
    setState(() {
      _nameController.text = user.name;

      _levelController.text = user.level.toString();

      _pickedImage = null;

      _isEditing = true;
    });
  }

  Future<void> _updateProfile(String currentImageUrl) async {
    if (_nameController.text.trim().isEmpty ||
        _levelController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Fields cannot be empty!")));

      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      String finalImageUrl = currentImageUrl;

      if (_pickedImage != null) {
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('profile_pictures')
            .child('$_currentUserId.jpg');

        await storageRef.putFile(_pickedImage!);

        finalImageUrl = await storageRef.getDownloadURL();
      }

      await FirebaseFirestore.instance
          .collection('users')
          .doc(_currentUserId)
          .update({
            'name': _nameController.text.trim(),

            'level': int.tryParse(_levelController.text.trim()) ?? 0,

            'imageUrl': finalImageUrl,
          });

      setState(() {
        _isEditing = false;

        _isSaving = false;

        _pickedImage = null;

        _userFuture = _fetchUserDetails();
      });

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Profile updated")));
    } catch (e) {
      setState(() {
        _isSaving = false;
      });

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error updating profile: $e")));
    }
  }

  void _signOut(BuildContext context) async {
    await AuthService().signOut();

    GoRouter.of(context).go("/login");
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Usermodel?>(
      future: _userFuture,

      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting || _isSaving) {
          return const Scaffold(
            backgroundColor: Color(0xFF000112),

            body: Center(
              child: CircularProgressIndicator(color: Color(0xFF00D2FF)),
            ),
          );
        }

        if (snapshot.hasError || snapshot.data == null) {
          return const Scaffold(
            backgroundColor: Color(0xFF000112),

            body: Center(
              child: Text(
                "Error Loading Profile",

                style: TextStyle(color: Colors.white),
              ),
            ),
          );
        }

        final user = snapshot.data!;

        return Scaffold(
          backgroundColor: const Color(0xFF000112),

          appBar: AppBar(
            backgroundColor: const Color(0xFF000112),

            elevation: 0,

            title: Text(
              _isEditing ? "Edit Profile" : "Player Profile",

              style: GoogleFonts.poppins(
                letterSpacing: 1.0,

                fontSize: 24,

                fontWeight: FontWeight.bold,

                color: Colors.white,
              ),
            ),

            actions: [
              if (!_isEditing)
                PopupMenuButton<String>(
                  icon: const Icon(
                    Icons.settings_rounded,

                    color: Colors.white,

                    size: 26,
                  ),

                  color: const Color(0xFF0D1527),

                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),

                  onSelected: (value) {
                    if (value == 'edit') _startEditing(user);

                    if (value == 'logout') _signOut(context);
                  },

                  itemBuilder: (BuildContext context) => [
                    PopupMenuItem(
                      value: 'edit',

                      child: Row(
                        children: [
                          const Icon(
                            Icons.edit_rounded,

                            color: Color(0xFF00D2FF),

                            size: 20,
                          ),

                          const SizedBox(width: 12),

                          Text(
                            'Edit Profile',

                            style: GoogleFonts.poppins(color: Colors.white),
                          ),
                        ],
                      ),
                    ),

                    PopupMenuItem(
                      value: 'logout',

                      child: Row(
                        children: [
                          const Icon(
                            Icons.logout_rounded,

                            color: Colors.redAccent,

                            size: 20,
                          ),

                          const SizedBox(width: 12),

                          Text(
                            'Sign Out',

                            style: GoogleFonts.poppins(color: Colors.redAccent),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
            ],
          ),

          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),

              child: Column(
                children: [
                  const SizedBox(height: 10),

                  // 🪐 PROFILE IMAGE WIDGET (With Cyber Neon Glow Border)
                  Center(
                    child: Stack(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),

                          decoration: BoxDecoration(
                            shape: BoxShape.circle,

                            gradient: const LinearGradient(
                              colors: [Color(0xFF00D2FF), Color(0xFF0047FF)],
                            ),

                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF00D2FF).withOpacity(0.2),

                                blurRadius: 20,

                                spreadRadius: 2,
                              ),
                            ],
                          ),

                          child: CircleAvatar(
                            radius: 68,

                            backgroundColor: const Color(0xFF0D1527),

                            backgroundImage: _pickedImage != null
                                ? FileImage(_pickedImage!)
                                : (user.imageUrl.isNotEmpty
                                      ? NetworkImage(user.imageUrl)
                                      : const AssetImage("assets/profile.png")
                                            as ImageProvider),
                          ),
                        ),

                        if (_isEditing)
                          Positioned(
                            bottom: 4,

                            right: 4,

                            child: GestureDetector(
                              onTap: _pickImage,

                              child: Container(
                                padding: const EdgeInsets.all(10),

                                decoration: const BoxDecoration(
                                  color: Color(0xFF00D2FF),

                                  shape: BoxShape.circle,
                                ),

                                child: const Icon(
                                  Icons.camera_alt_rounded,

                                  color: Colors.black,

                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 35),

                  // 🎴 GLASSMORPHIC ID CARD / FIELDS CONTAINER
                  ClipRRect(
                    borderRadius: BorderRadius.circular(24),

                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),

                      child: Container(
                        padding: const EdgeInsets.all(24),

                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),

                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFF0D1527).withOpacity(0.6),

                              const Color(0xFF050914).withOpacity(0.8),
                            ],

                            begin: Alignment.topLeft,

                            end: Alignment.bottomRight,
                          ),

                          border: Border.all(
                            color: const Color(0xFF00D2FF).withOpacity(0.15),

                            width: 1.5,
                          ),
                        ),

                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,

                          children: [
                            // NAME FIELD
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 5,
                                horizontal: 15,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  _buildStatItem(
                                    "Points",
                                    user.points.toString(),
                                    Colors.amber,
                                  ),
                                  _buildStatItem(
                                    "Wins",
                                    user.wins.toString(),
                                    Colors.greenAccent,
                                  ),
                                  _buildStatItem(
                                    "Win Rate",
                                    "${((user.totalMatches > 0) ? (user.wins / user.totalMatches) * 100 : 0.0).toStringAsFixed(1)}%",
                                    Colors.cyanAccent,
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 20),
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 16),

                              child: Divider(
                                color: Colors.white10,

                                thickness: 1,
                              ),
                            ),
                            _isEditing
                                ? _buildTextField(
                                    controller: _nameController,

                                    label: "Player Name",

                                    icon: Icons.person_rounded,
                                  )
                                : _buildInfoRow(
                                    icon: Icons.person_rounded,

                                    label: "PLAYER NAME",

                                    value: user.name,

                                    valueColor: const Color(0xFF00D2FF),
                                  ),

                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 16),

                              child: Divider(
                                color: Colors.white10,

                                thickness: 1,
                              ),
                            ),

                            // EMAIL FIELD (Non-editable style always look slick)
                            _buildInfoRow(
                              icon: Icons.email_rounded,

                              label: "EMAIL ADDRESS",

                              value: user.email,

                              isDimmed: _isEditing,
                            ),

                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 16),

                              child: Divider(
                                color: Colors.white10,

                                thickness: 1,
                              ),
                            ),

                            // LEVEL FIELD
                            _isEditing
                                ? _buildTextField(
                                    controller: _levelController,

                                    label: "Level",

                                    icon: Icons.emoji_events_rounded,

                                    isNumber: true,
                                  )
                                : _buildInfoRow(
                                    icon: Icons.emoji_events_rounded,

                                    label: "CURRENT LEVEL",

                                    value: "LVL ${user.level}",

                                    valueColor: Colors.amberAccent,
                                  ),

                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 16),

                              child: Divider(
                                color: Colors.white10,

                                thickness: 1,
                              ),
                            ),

                            // CREATED AT FIELD
                            _buildInfoRow(
                              icon: Icons.calendar_today_rounded,

                              label: "JOINED DATE",

                              value: DateFormat(
                                "dd MMM yyyy",
                              ).format(user.createdAt),

                              isDimmed: _isEditing,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // 🎮 ACTION BUTTONS (SAVE / CANCEL)
                  if (_isEditing)
                    Row(
                      children: [
                        Expanded(
                          child: _buildCyberButton(
                            text: "CANCEL",

                            color: Colors.redAccent.withOpacity(0.1),

                            borderColor: Colors.redAccent.withOpacity(0.5),

                            textColor: Colors.redAccent,

                            onPressed: () => setState(() => _isEditing = false),
                          ),
                        ),

                        const SizedBox(width: 16),

                        Expanded(
                          child: _buildCyberButton(
                            text: "SAVE CHANGES",

                            color: const Color(0xFF00D2FF).withOpacity(0.2),

                            borderColor: const Color(0xFF00D2FF),

                            textColor: const Color(0xFF00D2FF),

                            onPressed: () => _updateProfile(user.imageUrl),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Helper Widget: Info Display Row

  Widget _buildInfoRow({
    required IconData icon,

    required String label,

    required String value,

    Color valueColor = Colors.white,

    bool isDimmed = false,
  }) {
    return Opacity(
      opacity: isDimmed ? 0.4 : 1.0,

      child: Row(
        children: [
          Icon(
            icon,

            color: isDimmed
                ? Colors.grey
                : const Color(0xFF00D2FF).withOpacity(0.8),

            size: 22,
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(
                  label,

                  style: GoogleFonts.poppins(
                    fontSize: 11,

                    fontWeight: FontWeight.bold,

                    color: Colors.grey,

                    letterSpacing: 1.5,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  value,

                  style: GoogleFonts.poppins(
                    fontSize: 16,

                    fontWeight: FontWeight.w600,

                    color: valueColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper Widget: Futuristic Text Field

  Widget _buildTextField({
    required TextEditingController controller,

    required String label,

    required IconData icon,

    bool isNumber = false,
  }) {
    return TextFormField(
      controller: controller,

      keyboardType: isNumber ? TextInputType.number : TextInputType.text,

      style: GoogleFonts.poppins(color: Colors.white, fontSize: 16),

      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: const Color(0xFF00D2FF)),

        labelText: label,

        labelStyle: const TextStyle(color: Colors.grey),

        filled: true,

        fillColor: Colors.white.withOpacity(0.03),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),

          borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),

          borderSide: const BorderSide(color: Color(0xFF00D2FF), width: 1.5),
        ),
      ),
    );
  }

  // Helper Widget: Cyberpunk Stylized Button

  Widget _buildCyberButton({
    required String text,

    required Color color,

    required Color borderColor,

    required Color textColor,

    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      onPressed: onPressed,

      style: ElevatedButton.styleFrom(
        backgroundColor: color,

        elevation: 0,

        padding: const EdgeInsets.symmetric(vertical: 16),

        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),

          side: BorderSide(color: borderColor, width: 1.5),
        ),
      ),

      child: Text(
        text,

        style: GoogleFonts.orbitron(
          fontSize: 14,

          fontWeight: FontWeight.bold,

          color: textColor,

          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(
            color: color,
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
