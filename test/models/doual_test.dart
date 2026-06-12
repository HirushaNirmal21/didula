import 'package:flutter_test/flutter_test.dart';

import 'package:didula_api/models/doualmodel.dart';

void main() {
  group('DoualModel Tests', () {
    final Map<String, dynamic> sampleJson = {
      'doualId': 'D123',
      'player1Ids': 'P001',
      'player2Ids': 'P002',
      'player1Name': 'Hirusha',
      'player2Name': 'Nirmal',
      'player1Image': 'https://example.com/p1.png',
      'player2Image': 'https://example.com/p2.png',
    };

    test('should create a DoualModel instance correctly with constructor', () {
      final model = DoualModel(
        doualId: 'D123',
        player1Ids: 'P001',
        player2Ids: 'P002',
        player1Name: 'Hirusha',
        player2Name: 'Nirmal',
        player1Image: 'https://example.com/p1.png',
        player2Image: 'https://example.com/p2.png',
      );

      expect(model.doualId, 'D123');
      expect(model.player1Ids, 'P001');
      expect(model.player2Ids, 'P002');
      expect(model.player1Name, 'Hirusha');
      expect(model.player2Name, 'Nirmal');
      expect(model.player1Image, 'https://example.com/p1.png');
      expect(model.player2Image, 'https://example.com/p2.png');
    });

    test('should create a DoualModel instance from JSON correctly', () {
      final model = DoualModel.fromJson(sampleJson);

      expect(model.doualId, 'D123');
      expect(model.player1Ids, 'P001');
      expect(model.player2Ids, 'P002');
      expect(model.player1Name, 'Hirusha');
      expect(model.player2Name, 'Nirmal');
      expect(model.player1Image, 'https://example.com/p1.png');
      expect(model.player2Image, 'https://example.com/p2.png');
    });

    test('should convert DoualModel instance to JSON correctly', () {
      final model = DoualModel(
        doualId: 'D123',
        player1Ids: 'P001',
        player2Ids: 'P002',
        player1Name: 'Hirusha',
        player2Name: 'Nirmal',
        player1Image: 'https://example.com/p1.png',
        player2Image: 'https://example.com/p2.png',
      );

      final resultJson = model.toJson();

      expect(resultJson, sampleJson);
      expect(resultJson['doualId'], 'D123');
      expect(resultJson['player1Name'], 'Hirusha');
    });

    test(
      'should handle missing JSON fields gracefully and use default values',
      () {
        final Map<String, dynamic> emptyJson = {};
        final model = DoualModel.fromJson(emptyJson);

        expect(model.doualId, '');
        expect(model.player1Ids, '');
        expect(model.player2Ids, '');
        expect(model.player1Name, '');
        expect(model.player2Name, '');
        expect(model.player1Image, '');
        expect(model.player2Image, '');
      },
    );
  });
}
