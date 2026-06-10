import 'package:flutter_test/flutter_test.dart';
// ⚠️ ඔයාගේ project එකේ හැටියට මේ ඉම්පෝර්ට් පාර නිවැරදි කරගන්න
import 'package:didula_api/models/rulesmodel.dart';

void main() {
  group('Rulesmodel Tests', () {
    // 1 වන ටෙස්ට් එක: Normal Constructor එකෙන් instance එකක් නිවැරදිව හැදෙනවාද බැලීම
    test('should create a Rulesmodel instance correctly with constructor', () {
      final rule = Rulesmodel(
        ruleId: 'RULE001',
        description: 'No smoking inside the arena',
        userId: 'ADMIN123',
      );

      expect(rule.ruleId, 'RULE001');
      expect(rule.description, 'No smoking inside the arena');
      expect(rule.userId, 'ADMIN123');
    });

    // 2 වන ටෙස්ට් එක: fromJson මඟින් Map එකක් සහ ID එකක් එකතු කර Model එකක් සාර්ථකව සෑදීම
    test(
      'should create a Rulesmodel instance from JSON and explicit ID correctly',
      () {
        final Map<String, dynamic> mockJson = {
          "description": "Wear proper sports shoes",
          "userId": "ADMIN456",
        };
        const String mockDocId = "RULE002";

        // ඔයාගේ factory එකට parameters දෙකක් යන නිසා ඒ විදිහටම ටෙස්ට් කරනවා
        final rule = Rulesmodel.fromJson(mockJson, mockDocId);

        expect(rule.ruleId, 'RULE002'); // ID එක හරියට map වෙලාද බලයි
        expect(rule.description, 'Wear proper sports shoes');
        expect(rule.userId, 'ADMIN456');
      },
    );

    // 3 වන ටෙස්ට් එක: toJson මඟින් Model එකක් නිවැරදිව Map එකක් බවට හැරවීම
    test('should convert Rulesmodel instance to JSON correctly', () {
      final rule = Rulesmodel(
        ruleId: 'RULE003',
        description: 'Maintain silence near the court',
        userId: 'ADMIN789',
      );

      final resultJson = rule.toJson();

      expect(resultJson['ruleId'], 'RULE003');
      expect(resultJson['description'], 'Maintain silence near the court');
      expect(resultJson['userId'], 'ADMIN789');
    });

    // 4 වන ටෙස්ට් එක: Null Safety (JSON එකේ fields හිස්ව ආවොත් default values වැටෙනවාද බැලීම)
    test(
      'should handle missing JSON fields gracefully and use default empty strings',
      () {
        final Map<String, dynamic> emptyJson = {};
        const String mockDocId = "RULE_EMPTY";

        final rule = Rulesmodel.fromJson(emptyJson, mockDocId);

        expect(rule.ruleId, 'RULE_EMPTY');
        expect(
          rule.description,
          '',
        ); // ?? "" නිසා හිස් string එකක් ලැබිය යුතුයි
        expect(rule.userId, ''); // ?? "" නිසා හිස් string එකක් ලැබිය යුතුයි
      },
    );
  });
}
