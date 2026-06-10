import 'package:flutter_test/flutter_test.dart';
// ⚠️ ඔයාගේ project එකේ හැටියට මේ ඉම්පෝර්ට් පාර නිවැරදි කරගන්න
import 'package:didula_api/models/teamwinnermodel.dart';

void main() {
  group('TeamWinnerModel Tests', () {
    // 1 වන ටෙස්ට් එක: Normal Constructor එකෙන් instance එකක් නිවැරදිව හැදෙනවාද බැලීම
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

    // 2 වන ටෙස්ට් එක: fromMap මඟින් Firestore Map එකක් Model එකක් බවට හැරවීම
    test('should create a TeamWinnerModel instance from Map correctly', () {
      final Map<String, dynamic> mockMap = {
        'winteamid': 'WIN_TEAM_888',
        'winteamName': 'Champions',
        'memberId': [
          'USER_X',
          'USER_Y',
          'USER_Z',
        ], // 👈 ඔයාගේ කෝඩ් එකේ තියෙන විදිහට 'memberId' ලෙස දැම්මා
      };

      final winnerTeam = TeamWinnerModel.fromMap(mockMap);

      expect(winnerTeam.winteamid, 'WIN_TEAM_888');
      expect(winnerTeam.winteamName, 'Champions');
      expect(winnerTeam.membersId, isA<List<String>>());
      expect(winnerTeam.membersId, ['USER_X', 'USER_Y', 'USER_Z']);
    });

    // 3 වන ටෙස්ට් එක: toMap මඟින් Model එකක් නිවැරදිව Map එකක් බවට හැරවීම
    test('should convert TeamWinnerModel instance to Map correctly', () {
      final winnerTeam = TeamWinnerModel(
        winteamid: 'WIN_TEAM_999',
        winteamName: 'Legends',
        membersId: ['USER_M'],
      );

      final resultMap = winnerTeam.toMap();

      expect(resultMap['winteamid'], 'WIN_TEAM_999');
      expect(resultMap['winteamName'], 'Legends');
      expect(resultMap['memberId'], [
        'USER_M',
      ]); // 👈 Map එක ඇතුළේ 'memberId' වෙලාද බලයි
    });

    // 4 වන ටෙස්ට් එක: Null Safety (Fields හිස්ව ආවොත් default values වැටෙනවාද බැලීම)
    test('should handle missing fields and empty memberId list gracefully', () {
      final Map<String, dynamic> emptyMap = {};

      final winnerTeam = TeamWinnerModel.fromMap(emptyMap);

      expect(winnerTeam.winteamid, '');
      expect(winnerTeam.winteamName, '');
      expect(winnerTeam.membersId, isA<List<String>>());
      expect(
        winnerTeam.membersId,
        isEmpty,
      ); // ?? [] නිසා හිස් ලිස්ට් එකක් විය යුතුයි
    });
  });
}
