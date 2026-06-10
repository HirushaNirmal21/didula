import 'package:didula_api/pages/screens/add_screens.dart';
import 'package:didula_api/pages/screens/feed_screen.dart';
import 'package:didula_api/pages/screens/game_info_screen.dart';
import 'package:didula_api/pages/screens/profile_screen.dart';
import 'package:didula_api/pages/screens/rules_screens.dart';
import 'package:flutter/material.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  int _currentIndex = 0;
  final List<Widget> _pages = [
    FeedScreen(),
    GameInfoPage(),
    AddScreens(),
    RulesScreens(),
    ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: " Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.sports_esports_rounded),
            label: "Game Info",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_rounded),
            label: "Create",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.gavel_rounded),
            label: "Game Rules",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
      ),
      body: _pages[_currentIndex],
    );
  }
}
