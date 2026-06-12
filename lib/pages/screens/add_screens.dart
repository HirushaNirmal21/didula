import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:didula_api/functions/util_function.dart';
import 'package:didula_api/models/usermodel.dart';
import 'package:didula_api/services/feed/feedservices.dart';
import 'package:didula_api/services/userservices.dart';
import 'package:didula_api/utils/moods.dart';
import 'package:didula_api/widgets/custom/custom_button.dart';
import 'package:didula_api/widgets/custom/custom_textfield.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

class AddScreens extends StatefulWidget {
  const AddScreens({super.key});

  @override
  State<AddScreens> createState() => _AddScreensState();
}

class _AddScreensState extends State<AddScreens> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _captionController = TextEditingController();
  File? _imageFile;
  Moods _selectedMood = Moods.happy;
  bool _isUploading = false;
  String role = "user";
  bool isLoading = true;

  @override
  void initState() {
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
      role = doc.data()?['role'] ?? 'user';
      isLoading = false;
    });
  }

  //pick an image from the gallary or camara
  Future<void> _pickedImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: source);

    if (pickedImage != null) {
      setState(() {
        _imageFile = File(pickedImage.path);
      });
    }
  }

  //handle form submition
  void _submitPost() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        setState(() {
          _isUploading = true;
        });
        //check if the platform is web
        if (kIsWeb) {
          return;
        }

        final String postCaption = _captionController.text;
        //get current user
        final User? user = FirebaseAuth.instance.currentUser;

        if (user != null) {
          final Usermodel? userData = await UserService().getUserById(user.uid);

          if (userData != null) {
            final postDetails = {
              "postCaption": postCaption,
              "mood": _selectedMood.name,
              "userId": userData.userId,
              "userName": userData.name,
              "profileImage": userData.imageUrl,
              "postImage": _imageFile,
            };

            //save post
            await Feedservices().savePost(postDetails);
            UtilFunction().showSnackBar(context, "Post Created");
          }
        }
      } catch (e) {
        print("error get form submition :$e");
        UtilFunction().showSnackBar(context, "Post Created failed");
      } finally {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: const Color.fromARGB(255, 0, 1, 18),
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 0, 1, 18),
          title: Text(
            "Create Post",
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
              color: const Color.fromARGB(255, 255, 255, 255),
            ),
          ),
        ),
        body: SafeArea(child: Center(child: CircularProgressIndicator())),
      );
    }

    if (role != "admin") {
      return Scaffold(
        backgroundColor: const Color.fromARGB(255, 0, 1, 18),
        appBar: AppBar(
          title: Text(
            "Create Post",
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
              color: const Color.fromARGB(255, 255, 255, 255),
            ),
          ),
        ),
        body: SafeArea(
          child: Center(child: Text("This page is only for admin")),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 0, 1, 18),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 0, 1, 18),
        title: Text(
          "Create Post",
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
            color: const Color.fromARGB(255, 255, 255, 255),
          ),
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Custominput(
                    controller: _captionController,
                    lableText: "Caption",
                    obscureText: false,
                    icon: Icons.text_fields,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please Enter a caption";
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 15),
                  DropdownButton<Moods>(
                    value: _selectedMood,
                    items: Moods.values.map((Moods mood) {
                      return DropdownMenuItem(
                        value: mood,
                        child: Text("${mood.name} ${mood.Emogi}"),
                      );
                    }).toList(),
                    onChanged: (Moods? newMood) {
                      setState(() {
                        _selectedMood = newMood ?? _selectedMood;
                      });
                    },
                  ),
                  SizedBox(height: 15),
                  _imageFile != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: kIsWeb
                              ? Image.network(_imageFile!.path)
                              : Image.file(_imageFile!),
                        )
                      : Text("No Image Selected"),

                  SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Custombutton(
                        text: "Camera",
                        width: MediaQuery.of(context).size.width * 0.45,
                        onPressed: () => _pickedImage(ImageSource.camera),
                      ),
                      Custombutton(
                        text: "Galary",
                        width: MediaQuery.of(context).size.width * 0.45,
                        onPressed: () => _pickedImage(ImageSource.gallery),
                      ),
                    ],
                  ),
                  SizedBox(height: 5),
                  Custombutton(
                    text: kIsWeb
                        ? "Not Supporeted yet"
                        : _isUploading
                        ? "Uploading...."
                        : "Create Post",
                    width: double.infinity,
                    onPressed: () => _submitPost(),
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
