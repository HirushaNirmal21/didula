import 'package:flutter_test/flutter_test.dart';

import 'package:didula_api/models/teamwinnermodel.dart';

void main() {
  group('TeamWinnerModel Tests', () {
    test(
      'should create a TeamWinnerModel instance correctly with constructor',
      () {
        final winnerTeam = TeamWinnerModel(
          winteamid: 'WIN_TEAM_777',
          winteamName: 'Invincible XI',
          membersId: ['USER_10', 'USER_11'],
        );

        expect(winnerTeam.winteamid, 'WIN_TEAM_777');
        expect(winnerTeam.winteamName, 'Invincible XI');
        expect(winnerTeam.membersId, ['USER_10', 'USER_11']);
      },
    );

    test('should create a TeamWinnerModel instance from Map correctly', () {
      final Map<String, dynamic> mockMap = {
        'winteamid': 'WIN_TEAM_888',
        'winteamName': 'Champions',
        'memberId': ['USER_X', 'USER_Y', 'USER_Z'],
      };

      final winnerTeam = TeamWinnerModel.fromMap(mockMap);

      expect(winnerTeam.winteamid, 'WIN_TEAM_888');
      expect(winnerTeam.winteamName, 'Champions');
      expect(winnerTeam.membersId, isA<List<String>>());
      expect(winnerTeam.membersId, ['USER_X', 'USER_Y', 'USER_Z']);
    });

    test('should convert TeamWinnerModel instance to Map correctly', () {
      final winnerTeam = TeamWinnerModel(
        winteamid: 'WIN_TEAM_999',
        winteamName: 'Legends',
        membersId: ['USER_M'],
      );

      final resultMap = winnerTeam.toMap();

      expect(resultMap['winteamid'], 'WIN_TEAM_999');
      expect(resultMap['winteamName'], 'Legends');
      expect(resultMap['memberId'], ['USER_M']);
    });

    test('should handle missing fields and empty memberId list gracefully', () {
      final Map<String, dynamic> emptyMap = {};

      final winnerTeam = TeamWinnerModel.fromMap(emptyMap);

      expect(winnerTeam.winteamid, '');
      expect(winnerTeam.winteamName, '');
      expect(winnerTeam.membersId, isA<List<String>>());
      expect(winnerTeam.membersId, isEmpty);
    });
  });
}
