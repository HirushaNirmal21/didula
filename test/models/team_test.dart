import 'package:flutter_test/flutter_test.dart';
// ⚠️ ඔයාගේ project එකේ හැටියට මේ ඉම්පෝර්ට් පාර නිවැරදි කරගන්න
import 'package:didula_api/models/teammodel.dart';

void main() {
  group('TeamModel Tests', () {
    // 1 වන ටෙස්ට් එක: Normal Constructor එකෙන් instance එකක් නිවැරදිව හැදෙනවාද බැලීම
    test('should create a TeamModel instance correctly with constructor', () {
      final team = TeamModel(
        teamid: 'TEAM_001',
        teamName: 'Super Strikers',
        members: ['USER_1', 'USER_2', 'USER_3'],
      );

      expect(team.teamid, 'TEAM_001');
      expect(team.teamName, 'Super Strikers');
      expect(team.members, ['USER_1', 'USER_2', 'USER_3']);
      expect(team.members.length, 3);
    });

    // 2 වන ටෙස්ට් එක: fromMap මඟින් Firestore Map එකක් Model එකක් බවට හැරවීම
    test('should create a TeamModel instance from Map correctly', () {
      final Map<String, dynamic> mockMap = {
        'teamid': 'TEAM_002',
        'teamName': 'Golden Eagles',
        'members': ['USER_A', 'USER_B'], // Firestore එකෙන් එන ලිස්ට් එක
      };

      final team = TeamModel.fromMap(mockMap);

      expect(team.teamid, 'TEAM_002');
      expect(team.teamName, 'Golden Eagles');
      expect(
        team.members,
        isA<List<String>>(),
      ); // ලිස්ට් එක String ලිස්ට් එකක්ද බලයි
      expect(team.members, ['USER_A', 'USER_B']);
    });

    // 3 වන ටෙස්ට් එක: toMap මඟින් Model එකක් නිවැරදිව Map එකක් බවට හැරවීම
    test('should convert TeamModel instance to Map correctly', () {
      final team = TeamModel(
        teamid: 'TEAM_003',
        teamName: 'Royal Kings',
        members: ['USER_X'],
      );

      final resultMap = team.toMap();

      expect(resultMap['teamid'], 'TEAM_003');
      expect(resultMap['teamName'], 'Royal Kings');
      expect(resultMap['members'], ['USER_X']);
    });

    // 4 වන ටෙස්ට් එක: Null Safety (Members ලිස්ට් එක හෝ වෙනත් ෆීල්ඩ්ස් හිස්ව ආවොත් බැලීම)
    test('should handle missing fields and empty members list gracefully', () {
      final Map<String, dynamic> emptyMap = {};

      final team = TeamModel.fromMap(emptyMap);

      expect(team.teamid, '');
      expect(team.teamName, '');
      expect(team.members, isA<List<String>>());
      expect(
        team.members,
        isEmpty,
      ); // ?? [] නිසා ලිස්ට් එක හිස් ලිස්ට් එකක් විය යුතුයි
    });
  });
}
