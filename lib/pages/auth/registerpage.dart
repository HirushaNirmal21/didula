import 'dart:io';

import 'package:didula_api/models/usermodel.dart';
import 'package:didula_api/services/auth_services.dart';
import 'package:didula_api/services/userservices.dart';
import 'package:didula_api/services/userstorageservice.dart';
import 'package:didula_api/utils/function.dart';
import 'package:didula_api/widgets/custom/custom_button.dart';
import 'package:didula_api/widgets/custom/custom_textfield.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

class Registerpage extends StatefulWidget {
  const Registerpage({super.key});

  @override
  State<Registerpage> createState() => _RegisterpageState();
}

class _RegisterpageState extends State<Registerpage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _levelController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confremPasswordController =
      TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  File? _imageFile;

  Future<void> _createUser(BuildContext context) async {
    // ---------------------------------------------------------

    if (_nameController.text.trim().isEmpty ||
        _emailController.text.trim().isEmpty ||
        _passwordController.text.trim().isEmpty ||
        _confremPasswordController.text.trim().isEmpty ||
        _levelController.text.trim().isEmpty) {
      UtileFunctions().showSnackBar(context, "Please fill in all the fields!");
      return;
    }

    final emailText = _emailController.text.trim();
    if (!emailText.contains("@") || !emailText.contains(".")) {
      UtileFunctions().showSnackBar(
        context,
        "Please enter a valid email address!",
      );
      return;
    }

    if (int.tryParse(_levelController.text.trim()) == null) {
      UtileFunctions().showSnackBar(context, "Level must be a valid number!");
      return;
    }

    if (_passwordController.text.trim().length < 6) {
      UtileFunctions().showSnackBar(
        context,
        "Password must be at least 6 characters long!",
      );
      return;
    }

    if (_passwordController.text.trim() !=
        _confremPasswordController.text.trim()) {
      UtileFunctions().showSnackBar(context, "Passwords do not match!");
      return;
    }

    // ---------------------------------------------------------

    try {
      final userCredential = await AuthService().registerUser(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      final String? firebaseUid = userCredential.user?.uid;

      if (firebaseUid == null) {
        throw Exception("Firebase UID integration failed.");
      }

      if (_imageFile != null) {
        final imageUrl = await UserProfileStorageService().uploadImage(
          profileImage: _imageFile!,
          userEmail: _emailController.text.trim(),
        );
        _imageUrlController.text = imageUrl;
      }

      await UserService().saveUser(
        Usermodel(
          userId: firebaseUid,
          name: _nameController.text.trim(),
          imageUrl: _imageUrlController.text,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          password: _passwordController.text.trim(),
          level: int.tryParse(_levelController.text.trim()) ?? 0,
          email: _emailController.text.trim(),
        ),
      );

      if (!mounted) return;
      UtileFunctions().showSnackBar(context, "User created successfully 🎉");

      GoRouter.of(context).go("/HomePage");
    } catch (e) {
      print('Error signing up: $e');
      if (!mounted) return;
      UtileFunctions().showSnackBar(
        context,
        e.toString().replaceAll("Exception:", ""),
      );
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    // Implement image picking logic here
    final picker = ImagePicker();
    // ignore: non_constant_identifier_names
    final PickerImage = await picker.pickImage(source: source);
    if (PickerImage != null) {
      setState(() {
        _imageFile = File(PickerImage.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // ignore: no_leading_underscores_for_local_identifiers

    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color.fromARGB(255, 0, 1, 18),
        // ignore: sized_box_for_whitespace
        body: Container(
          width: double.infinity,
          height: double.infinity,
          child: Container(
            width: double.infinity,
            height: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 0, 1, 18),
              borderRadius: BorderRadius.circular(100),
            ),

            child: SingleChildScrollView(
              child: Column(
                children: [
                  Image.asset(
                    "assets/logo.jpeg",
                    width: double.infinity,
                    height: MediaQuery.of(context).size.height * 0.54,
                    fit: BoxFit.cover,
                  ),
                  Text(
                    "MORE THAN A TOURNAMENT",
                    style: TextStyle(
                      letterSpacing: 6,
                      fontWeight: FontWeight.bold,
                      color: Colors.white.withOpacity(0.3),
                    ),
                  ),

                  SizedBox(height: 20),
                  Form(
                    key: _formKey,
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          Stack(
                            children: [
                              _imageFile != null
                                  ? CircleAvatar(
                                      radius: 50,
                                      backgroundColor: Colors.purpleAccent,
                                      backgroundImage: FileImage(_imageFile!),
                                    )
                                  : Center(
                                      child: CircleAvatar(
                                        radius: 50,
                                        backgroundColor: Colors.grey,
                                        child: Icon(
                                          Icons.person,
                                          size: 64,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                              Positioned(
                                bottom: -5,
                                left: 210,
                                child: IconButton(
                                  icon: Icon(Icons.add_a_photo, size: 25),
                                  onPressed: () async {
                                    _pickImage(ImageSource.gallery);
                                    // Handle image selection
                                  },
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 4,
                            ),
                            child: Custominput(
                              controller: _nameController,
                              lableText: "Name",
                              icon: Icons.person,
                              obscureText: false,
                            ),
                          ),

                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 4,
                            ),
                            child: Custominput(
                              controller: _emailController,
                              lableText: "Email",
                              icon: Icons.email,
                              obscureText: false,
                              validator: (value) {
                                if (!RegExp(
                                  r'^[^@]+@[^@]+\.[^@]+',
                                ).hasMatch(value!)) {
                                  return "Please enter a valid email address";
                                }
                                return null;
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 4,
                            ),
                            child: Custominput(
                              controller: _levelController,
                              lableText: "Level",
                              icon: Icons.workspace_premium,
                              obscureText: false,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 4,
                            ),
                            child: Custominput(
                              controller: _passwordController,
                              lableText: "Password",
                              icon: Icons.lock,
                              obscureText: true,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 4,
                            ),
                            child: Custominput(
                              controller: _confremPasswordController,
                              lableText: "Confirm Password",
                              icon: Icons.lock,
                              obscureText: true,
                            ),
                          ),
                          SizedBox(height: 20),
                          Custombutton(
                            text: "Register",
                            width: MediaQuery.of(context).size.width * 0.9,
                            onPressed: () async {
                              if (_formKey.currentState?.validate() ?? false) {
                                await _createUser(context);
                              }
                            },
                          ),
                          SizedBox(height: 2),
                          TextButton(
                            onPressed: () {
                              GoRouter.of(context).go("/login");
                            },
                            child: Text(
                              "Already have an account?  Log in",
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.5),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
