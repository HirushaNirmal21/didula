import 'package:didula_api/models/usermodel.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test("user model should create an instance correctly", () {
    final User = Usermodel(
      userId: "1",
      name: "saman",
      imageUrl: "wgetg.png",
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      password: "123456",
      level: 2,
      email: "sdp@gmail.com",
    );

    expect(User.userId, "1");
    expect(User.name, "saman");
    expect(User.imageUrl, "wgetg.png");
    expect(User.createdAt, isA<DateTime>());
    expect(User.updatedAt, isA<DateTime>());
    expect(User.password, "123456");
    expect(User.level, 2);
    expect(User.email, "sdp@gmail.com");
  });
}
