import 'package:flutter_test/flutter_test.dart';

import 'package:didula_api/models/teammodel.dart';

void main() {
  group('TeamModel Tests', () {
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

    test('should create a TeamModel instance from Map correctly', () {
      final Map<String, dynamic> mockMap = {
        'teamid': 'TEAM_002',
        'teamName': 'Golden Eagles',
        'members': ['USER_A', 'USER_B'],
      };

      final team = TeamModel.fromMap(mockMap);

      expect(team.teamid, 'TEAM_002');
      expect(team.teamName, 'Golden Eagles');
      expect(team.members, isA<List<String>>());
      expect(team.members, ['USER_A', 'USER_B']);
    });

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

    test('should handle missing fields and empty members list gracefully', () {
      final Map<String, dynamic> emptyMap = {};

      final team = TeamModel.fromMap(emptyMap);

      expect(team.teamid, '');
      expect(team.teamName, '');
      expect(team.members, isA<List<String>>());
      expect(team.members, isEmpty);
    });
  });
}
