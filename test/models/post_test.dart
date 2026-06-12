import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:didula_api/utils/moods.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:didula_api/models/postmodel.dart';

void main() {
  group('PostModel Tests', () {
    final fixedDate = DateTime(2026, 06, 07, 10, 0, 0);
    final mockTimestamp = Timestamp.fromDate(fixedDate);

    test('should create a PostModel instance correctly with constructor', () {
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

      expect(post.postId, 'POST123');
      expect(post.mood, Moods.happy);
      expect(post.postCaption, 'Hello World');
      expect(post.like, 5);
      expect(post.datePublished, fixedDate);
    });

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
        expect(post.datePublished, fixedDate);
      },
    );

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
        expect(resultJson['mood'], 'Happy');
        expect(resultJson['like'], 5);
        expect(resultJson['datePublished'], isA<Timestamp>());
        expect((resultJson['datePublished'] as Timestamp).toDate(), fixedDate);
      },
    );
  });
}
