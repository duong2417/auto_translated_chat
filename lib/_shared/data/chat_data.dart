import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:public_chat/features/chat/message_input/constants.dart';
import 'package:public_chat/features/chat/message_input/models/mention_model.dart';

final class Message {
  final String id;
  final String message;
  final String sender;
  final Timestamp timestamp;
  final Map<String, dynamic> translations;

  final List<MentionModel> mentionedUsers;

  Message({required this.message, required this.sender})
      : id = '',
        timestamp = Timestamp.now(),
        translations = {},
        mentionedUsers = defaultMentions;

  Message.fromMap(this.id, Map<String, dynamic> map)
      : message = map['message'] ?? '',
        sender = map['sender'],
        timestamp = map['time'],
        translations = map['translated'] as Map<String, dynamic>? ?? {},
        mentionedUsers = (map['mentionedUsers'] as List<dynamic>?)
                ?.map((e) => MentionModel.fromMap(e as Map<String, dynamic>))
                .toList() ??
            [];

  Map<String, dynamic> toMap() => {
        'message': message,
        'sender': sender,
        'time': timestamp,
        'mentionedUsers': mentionedUsers.map((e) => e.toJson()).toList()
      };

  Message copyWith({
    String? id,
    String? message,
    String? sender,
    Timestamp? timestamp,
    Map<String, dynamic>? translations,
    List<MentionModel>? mentionedUsers,
  }) {
    return Message.fromMap(
      id ?? this.id,
      {
        'message': message ?? this.message,
        'sender': sender ?? this.sender,
        'time': timestamp ?? this.timestamp,
        'translated': translations ?? this.translations,
        'mentionedUsers': mentionedUsers?.map((e) => e.toJson()).toList() ??
            this.mentionedUsers.map((e) => e.toJson()).toList(),
      },
    );
  }

  Message clear() {
    return Message.fromMap(
      '',
      {
        'message': '',
        'sender': '',
        'time': Timestamp.now(),
        'translated': <String, dynamic>{},
        'mentionedUsers': <Map<String, dynamic>>[],
      },
    );
  }
}

final class UserDetail {
  final String displayName;
  final String? photoUrl;
  final String uid;

  UserDetail.fromFirebaseUser(User user)
      : displayName = user.displayName ?? 'Unknown',
        photoUrl = user.photoURL,
        uid = user.uid;

  UserDetail.fromMap(this.uid, Map<String, dynamic> map)
      : displayName = map['displayName'],
        photoUrl = map['photoUrl'];

  Map<String, dynamic> toMap() =>
      {'displayName': displayName, 'photoUrl': photoUrl};
}
