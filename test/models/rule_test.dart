import 'package:flutter_test/flutter_test.dart';

import 'package:didula_api/models/rulesmodel.dart';

void main() {
  group('Rulesmodel Tests', () {
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

    test(
      'should create a Rulesmodel instance from JSON and explicit ID correctly',
      () {
        final Map<String, dynamic> mockJson = {
          "description": "Wear proper sports shoes",
          "userId": "ADMIN456",
        };
        const String mockDocId = "RULE002";

        final rule = Rulesmodel.fromJson(mockJson, mockDocId);

        expect(rule.ruleId, 'RULE002');
        expect(rule.description, 'Wear proper sports shoes');
        expect(rule.userId, 'ADMIN456');
      },
    );

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

    test(
      'should handle missing JSON fields gracefully and use default empty strings',
      () {
        final Map<String, dynamic> emptyJson = {};
        const String mockDocId = "RULE_EMPTY";

        final rule = Rulesmodel.fromJson(emptyJson, mockDocId);

        expect(rule.ruleId, 'RULE_EMPTY');
        expect(rule.description, '');
        expect(rule.userId, '');
      },
    );
  });
}
