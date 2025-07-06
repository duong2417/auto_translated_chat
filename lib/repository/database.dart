import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:public_chat/_shared/data/chat_data.dart';
import 'package:public_chat/features/chat/message_input/models/mention_model.dart';

final class Database {
  static Database? _instance;

  Database._();

  static Database get instance {
    _instance ??= Database._();
    return _instance!;
  }

  final String _mentions = 'mentions';
  final String _publicRoom = 'public';
  final String _userList = 'users';

  Future<QuerySnapshot<MentionModel>> getMentions() {
    return FirebaseFirestore.instance
        .collection(_mentions)
        .withConverter(
          fromFirestore: (snapshot, options) =>
              MentionModel.fromMap(snapshot.data() ?? {}),
          toFirestore: (mention, options) => mention.toJson(),
        )
        .get();
  }

  void setMentions(List<MentionModel> mentions) {
    final WriteBatch batch = FirebaseFirestore.instance.batch();
    for (final mention in mentions) {
      final DocumentReference<MentionModel> docRef = FirebaseFirestore.instance
          .collection(_mentions)
          .doc(mention.id)
          .withConverter(
            fromFirestore: (snapshot, options) =>
                MentionModel.fromMap(snapshot.data() ?? {}),
            toFirestore: (mention, options) => mention.toJson(),
          );
      batch.set(docRef, mention);
    }
    batch.commit();
  }

  void writePublicMessage(Message message) {
    FirebaseFirestore.instance.collection(_publicRoom).add(message.toMap());
  }

  Query<T> getPublicChatContents<T>({
    required FromFirestore<T> fromFirestore,
    required ToFirestore<T> toFirestore,
  }) {
    return FirebaseFirestore.instance
        .collection(_publicRoom)
        .orderBy('time', descending: true)
        .withConverter(fromFirestore: fromFirestore, toFirestore: toFirestore);
  }

  void saveUser(User user) {
    final UserDetail userDetail = UserDetail.fromFirebaseUser(user);
    FirebaseFirestore.instance
        .collection(_userList)
        .doc(user.uid)
        .set(userDetail.toMap(), SetOptions(merge: true));
  }

  Future<DocumentSnapshot<UserDetail>> getUser(String uid) {
    return FirebaseFirestore.instance
        .collection(_userList)
        .doc(uid)
        .withConverter(
            fromFirestore: _userDetailFromFirestore,
            toFirestore: _userDetailToFirestore)
        .get(const GetOptions(source: Source.serverAndCache));
  }

  Stream<QuerySnapshot<UserDetail>> getUserStream() {
    return FirebaseFirestore.instance
        .collection(_userList)
        .withConverter(
            fromFirestore: _userDetailFromFirestore,
            toFirestore: _userDetailToFirestore)
        .snapshots();
  }

  /// ###############################################################
  /// fromFirestore and toFirestore
  UserDetail _userDetailFromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) =>
      UserDetail.fromMap(snapshot.id, snapshot.data() ?? {});
  Map<String, Object?> _userDetailToFirestore(
    UserDetail value,
    SetOptions? options,
  ) =>
      value.toMap();
}
