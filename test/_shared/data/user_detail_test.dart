import 'package:flutter_test/flutter_test.dart';
import 'package:public_chat/_shared/data/chat_data.dart'; // Adjust import if UserDetail is in a different location

// Mock Firebase User if needed for fromFirebaseUser, or test fromMap/toMap directly
// For simplicity, we'll focus on fromMap and toMap directly as fromFirebaseUser involves a Firebase User object.

void main() {
  group('UserDetail', () {
    test('toMap includes languageCode', () {
      final userDetail = UserDetail.fromMap('123', {
        'displayName': 'Test User',
        'photoUrl': 'http://example.com/photo.jpg',
        'languageCode': 'en',
      });
      // Also test UserDetail.fromFirebaseUser if it's the primary way of constructing with languageCode
      // For fromFirebaseUser, you might need to mock the User object if not done already.
      // Let's assume direct instantiation or fromMap is sufficient for testing languageCode storage.

      final map = userDetail.toMap();
      expect(map['languageCode'], 'en');
      expect(map['displayName'], 'Test User');
      expect(map['photoUrl'], 'http://example.com/photo.jpg');
    });

    test('toMap handles null languageCode', () {
      final userDetail = UserDetail.fromMap('123', {
        'displayName': 'Test User',
        'photoUrl': 'http://example.com/photo.jpg',
        // languageCode is omitted, so it should be null
      });
      final map = userDetail.toMap();
      expect(map['languageCode'], isNull);
    });

    test('fromMap correctly assigns languageCode', () {
      final userDetail = UserDetail.fromMap('123', {
        'displayName': 'Test User',
        'photoUrl': 'http://example.com/photo.jpg',
        'languageCode': 'fr',
      });
      expect(userDetail.languageCode, 'fr');
      expect(userDetail.uid, '123');
      expect(userDetail.displayName, 'Test User');
    });

    test('fromMap handles missing languageCode (should be null)', () {
      final userDetail = UserDetail.fromMap('123', {
        'displayName': 'Test User',
        'photoUrl': 'http://example.com/photo.jpg',
      });
      expect(userDetail.languageCode, isNull);
    });

    // It would also be good to test the UserDetail.fromFirebaseUser constructor
    // but that requires a Firebase User object.
    // Example structure for that (requires firebase_auth mock or real object):
    /*
    // Mock User class for testing
    // You might need a more robust mocking solution like mockito for User
    class MockUser implements User {
      @override
      final String displayName;
      @override
      final String? photoURL;
      @override
      final String uid;

      MockUser({this.displayName = 'Mock User', this.photoURL, required this.uid});

      // Implement other User methods and properties as needed by UserDetail.fromFirebaseUser
      // or by the test, usually returning default/mock values.
      // For example:
      @override
      bool get emailVerified => false;
      @override
      bool get isAnonymous => false;
      @override
      UserMetadata get metadata => UserMetadata(0, 0); // Mocked metadata
      @override
      List<UserInfo> get providerData => [];
      @override
      Future<String> getIdToken([bool forceRefresh = false]) async => 'mock_token';
      @override
      Future<void> reload() async {}
      @override
      Future<void> delete() async {}
      // ... other methods ...
      noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
    }

    test('fromFirebaseUser correctly assigns languageCode', () {
      final mockUser = MockUser(uid: 'firebase123', displayName: 'Firebase User', photoURL: 'http://firebase.com/user.png');
      final userDetail = UserDetail.fromFirebaseUser(mockUser, languageCode: 'es');

      expect(userDetail.uid, 'firebase123');
      expect(userDetail.displayName, 'Firebase User');
      expect(userDetail.photoUrl, 'http://firebase.com/user.png');
      expect(userDetail.languageCode, 'es');

      final map = userDetail.toMap();
      expect(map['languageCode'], 'es');
    });

    test('fromFirebaseUser handles null languageCode', () {
      final mockUser = MockUser(uid: 'firebase456');
      final userDetail = UserDetail.fromFirebaseUser(mockUser); // languageCode is null by default

      expect(userDetail.languageCode, isNull);
      final map = userDetail.toMap();
      expect(map['languageCode'], isNull);
    });
    */
  });
}
