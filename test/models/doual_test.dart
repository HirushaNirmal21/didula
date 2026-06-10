import 'package:flutter_test/flutter_test.dart';
// ⚠️ ඔයාගේ project එකේ හැටියට මේ import path එක නිවැරදි කරගන්න (e.g., package:didula_api/models/...)
import 'package:didula_api/models/doualmodel.dart';

void main() {
  group('DoualModel Tests', () {
    // ටෙස්ට් කිරීමට අවශ්‍ය ඩමි ඩේටා (Mock Data) ටිකක් මුලින්ම සාදා ගනිමු
    final Map<String, dynamic> sampleJson = {
      'doualId': 'D123',
      'player1Ids': 'P001',
      'player2Ids': 'P002',
      'player1Name': 'Hirusha',
      'player2Name': 'Nirmal',
      'player1Image': 'https://example.com/p1.png',
      'player2Image': 'https://example.com/p2.png',
    };

    // 1 වන ටෙස්ට් එක: සාමාන්‍ය ලෙස Object එකක් සෑදීම ටෙස්ට් කිරීම
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

    // 2 වන ටෙස්ට් එක: fromJson මඟින් Map එකක් Model එකක් බවට හැරවීම ටෙස්ට් කිරීම
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

    // 3 වන ටෙස්ට් එක: toJson මඟින් Model එකක් නැවත Map එකක් කරන එක ටෙස්ට් කිරීම
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

    // 4 වන ටෙස්ට් එක: Null Safety (ඩේටා නැතිව හිස්ව ආවොත් default values වැටෙනවද කියා බැලීම)
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
