import 'package:didula_api/firebase_options.dart';
import 'package:didula_api/routers/routers.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      theme: ThemeData(
        fontFamily: GoogleFonts.poppins().fontFamily,
        brightness: Brightness.dark,
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: const Color.fromARGB(255, 0, 1, 18),
          selectedItemColor: Color.fromARGB(255, 2, 24, 165),
          unselectedItemColor: Colors.white,
        ),
        snackBarTheme: SnackBarThemeData(
          backgroundColor: Colors.white,
          //backgroundColor: Color.fromARGB(255, 237, 163, 4),
          contentTextStyle: TextStyle(fontSize: 16, color: Colors.black),
        ),
      ),
      title: "Didula අපි",
      debugShowCheckedModeBanner: false,
      routerConfig: RouterClass().router,
    );
  }
}
