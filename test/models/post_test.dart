import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:didula_api/utils/moods.dart';
import 'package:flutter_test/flutter_test.dart';
// ⚠️ ඔයාගේ project එකේ හැටියට මේ ඉම්පෝර්ට් පාරවල් නිවැරදි කරගන්න
import 'package:didula_api/models/postmodel.dart';
// Moods enum එක තියෙන තැන

void main() {
  group('PostModel Tests', () {
    final fixedDate = DateTime(2026, 06, 07, 10, 0, 0);
    final mockTimestamp = Timestamp.fromDate(fixedDate);

    // 1 වන ටෙස්ට් එක: Normal Constructor එකෙන් instance එකක් හැදීම
    test('should create a PostModel instance correctly with constructor', () {
      final post = PostModel(
        postId: 'POST123',
        mood: Moods
            .happy, // 👈 ඔයාගේ enum එකේ තියෙන අගයක් දාන්න (e.g. Moods.happy හෝ Moods.Happy)
        postCaption: 'Hello World',
        userId: 'USER123',
        userName: 'Saman',
        profileImage: 'https://example.com/profile.png',
        like: 5,
        datePublished: fixedDate,
        postUrl: 'https://example.com/post.png',
      );

      expect(post.postId, 'POST123');
      expect(post.mood, Moods.happy);
      expect(post.postCaption, 'Hello World');
      expect(post.like, 5);
      expect(post.datePublished, fixedDate);
    });

    // 2 වන ටෙස්ට් එක: fromJson මඟින් Firestore Map එකක් Model එකක් කිරීම
    test(
      'should create a PostModel instance from JSON correctly (with Timestamp)',
      () {
        final Map<String, dynamic> mockJson = {
          "postId": "POST123",
          "mood": "Happy", // Enum name as String
          "postCaption": "Hello World",
          "userId": "USER123",
          "userName": "Saman",
          "profileImage": "https://example.com/profile.png",
          "like": 5,
          "datePublished": mockTimestamp, // Firebase Timestamp
          "postUrl": "https://example.com/post.png",
        };

        final post = PostModel.fromJson(mockJson);

        expect(post.postId, 'POST123');
        expect(post.mood, isA<Moods>());
        expect(post.postCaption, 'Hello World');
        expect(post.like, 5);
        expect(
          post.datePublished,
          fixedDate,
        ); // Timestamp එක DateTime වෙලාද බලයි
      },
    );

    // 3 වන ටෙස්ට් එක: toJson මඟින් Model එකක් Firestore Map එකක් කිරීම
    test(
      'should convert PostModel instance to JSON correctly (with Timestamp)',
      () {
        final post = PostModel(
          postId: 'POST123',
          mood: Moods.happy,
          postCaption: 'Hello World',
          userId: 'USER123',
          userName: 'Saman',
          profileImage: 'https://example.com/profile.png',
          like: 5,
          datePublished: fixedDate,
          postUrl: 'https://example.com/post.png',
        );

        final resultJson = post.toJson();

        expect(resultJson['postId'], 'POST123');
        expect(resultJson['mood'], 'Happy'); // Enum එක string වෙලාද බලයි
        expect(resultJson['like'], 5);
        expect(
          resultJson['datePublished'],
          isA<Timestamp>(),
        ); // DateTime එක Timestamp වෙලාද බලයි
        expect((resultJson['datePublished'] as Timestamp).toDate(), fixedDate);
      },
    );
  });
}
