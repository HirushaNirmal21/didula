import 'package:cloud_firestore/cloud_firestore.dart';

class Usermodel {
  final String userId;
  final String name;
  final String email;
  final String imageUrl;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String password;
  final int level;
  final int points;
  final int wins;
  final int totalMatches;

  Usermodel({
    required this.userId,
    required this.name,
    required this.imageUrl,
    required this.createdAt,
    required this.updatedAt,
    required this.password,
    required this.level,
    required this.email,
    this.points = 0,
    this.wins = 0,
    this.totalMatches = 0,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'name': name,
      'imageUrl': imageUrl,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'password': password,
      'level': level,
      'email': email,
      'points': points,
      'wins': wins,
      'totalMatches': totalMatches,
    };
  }

  // Factory constructor to create a Usermodel from JSON
  factory Usermodel.fromJson(Map<String, dynamic> data) {
    return Usermodel(
      userId: data['userId'] ?? '',
      name: data['name'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      password: data['password'] ?? '',
      level: data['level'] ?? 1,
      email: data['email'] ?? '',
      points: data['points'] ?? 0,
      wins: data['wins'] ?? 0,
      totalMatches: data['totalMatches'] ?? 0,
    );
  }
}
