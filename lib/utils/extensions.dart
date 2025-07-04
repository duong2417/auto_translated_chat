import 'package:public_chat/_shared/data/chat_data.dart';

/// Extensions on Message
extension MessageX on Message {
  /// It replaces the user mentions with the actual user names.
  Message replaceMentions({bool linkify = true}) {
    var messageTextToRender = message;
    for (final user in mentionedUsers.toSet()) {
      final userId = user.id;
      final userName = user.name;
      // print('Replacing mentions: $userId, $userName');
      if (linkify) {
        messageTextToRender = messageTextToRender.replaceAll(
          RegExp('@($userId|$userName)'),
          '[@$userName]($userId)',
        );
      } else {
        messageTextToRender = messageTextToRender.replaceAll(
          RegExp('@($userId|$userName)'),
          '@$userName',
        );
      }
    }
    return copyWith(message: messageTextToRender);
  }

  /// It returns the message replacing the mentioned user names with
  ///  the respective user ids
  Message replaceMentionsWithId() {
    if (mentionedUsers.isEmpty) return this;

    var messageTextToSend = message;
    if (messageTextToSend.isEmpty) return this;

    for (final user in mentionedUsers.toSet()) {
      final userName = user.name;
      messageTextToSend = messageTextToSend.replaceAll(
        '@$userName',
        '@${user.id}',
      );
    }

    return copyWith(message: messageTextToSend);
  }
}
