import 'package:didula_api/pages/auth/registerpage.dart';
import 'package:didula_api/pages/responsive/home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';

class Weblayout extends StatelessWidget {
  const Weblayout({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasData) {
          return Homepage();
        } else {
          return Registerpage();
        }
      },
    );
  }
}
