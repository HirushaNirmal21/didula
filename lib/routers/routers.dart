import 'package:didula_api/pages/auth/login.dart';
import 'package:didula_api/pages/auth/registerpage.dart';
import 'package:didula_api/pages/responsive/home_screen.dart';
import 'package:didula_api/pages/responsive/mobilelayout.dart';
import 'package:didula_api/pages/responsive/responsivelayout.dart';
import 'package:didula_api/pages/responsive/weblayout.dart';
import 'package:didula_api/pages/screens/feed_screen.dart';
import 'package:didula_api/pages/screens/game_info_screen.dart';
import 'package:didula_api/pages/screens/profile_screen.dart';
import 'package:didula_api/pages/screens/rules_screens.dart';
import 'package:didula_api/pages/screens/vote_screen.dart';
import 'package:didula_api/pages/teamspage.dart';
import 'package:didula_api/pages/winnerspage.dart';
import 'package:didula_api/pages/douelspage.dart';
import 'package:didula_api/widgets/custom/cardpage.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RouterClass {
  final router = GoRouter(
    initialLocation: "/",
    errorPageBuilder: (context, state) {
      return MaterialPage(
        child: Scaffold(body: Center(child: Text("Page not found"))),
      );
    },
    routes: [
      GoRoute(
        path: "/",
        name: "Nav layout",
        builder: (context, state) {
          return Responsivelayout(
            mobilelayout: Mobilelayout(),
            weblayout: Weblayout(),
          );
        },
      ),
      GoRoute(
        path: "/CardPage",
        name: "CardPage",
        builder: (context, state) {
          return Cardpage();
        },
      ),
      GoRoute(
        path: "/Register",
        name: "Register",
        builder: (context, state) {
          return Registerpage();
        },
      ),
      GoRoute(
        path: "/login",
        name: "login",
        builder: (context, state) {
          return Login();
        },
      ),
      GoRoute(
        path: "/HomePage",
        name: "HomePage",
        builder: (context, state) {
          return Homepage();
        },
      ),
      GoRoute(
        path: "/FeedScreen",
        name: "FeedScreen",
        builder: (context, state) {
          return FeedScreen();
        },
      ),
      GoRoute(
        path: "/GameInfoPage",
        name: "GameInfoPage",
        builder: (context, state) {
          return GameInfoPage();
        },
      ),
      GoRoute(
        path: "/ProfilePage",
        name: "ProfilePage",
        builder: (context, state) {
          return ProfileScreen();
        },
      ),
      GoRoute(
        path: "/RulePage",
        name: "RulePage",
        builder: (context, state) {
          return RulesScreens();
        },
      ),
      GoRoute(
        path: "/WinnersPage",
        name: "WinnersPage",
        builder: (context, state) {
          return WinTeamsPage();
        },
      ),
      GoRoute(
        path: "/TeamsPage",
        name: "TeamsPage",
        builder: (context, state) {
          return TeamsPage();
        },
      ),
      GoRoute(
        path: '/vote',
        name: 'vote',
        builder: (context, state) {
          // 🔴 game_info_screen එකෙන් 'extra' විදිහට එවන userData මැප් එක මෙතනින් අල්ලගන්නවා
          final currentUserData = state.extra;

          return VoteScreen(currentUser: currentUserData);
        },
      ),
      GoRoute(
        path: "/DuelPage",
        name: "DuelPage",
        builder: (context, state) {
          return DoualsPage();
        },
      ),
    ],
  );
}
