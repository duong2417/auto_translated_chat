import 'package:flutter/material.dart';
import 'package:public_chat/_shared/data/chat_data.dart';
import 'package:public_chat/features/chat/message_input/models/mention_model.dart';
import 'package:public_chat/utils/typedefs.dart';

/// Extensions on Message
extension MessageX on Message {
  /// It replaces the user mentions with the actual user names.
  Message replaceMentions({bool linkify = true}) {
    var messageTextToRender = message;
    for (final user in mentionedUsers.toSet()) {
      final userId = user.id;
      final userName = user.name;
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

extension Mention on MentionModel {
  bool contains(String query) {
    final queryLower = query.toLowerCase();
    return nameLower.contains(queryLower) || idLower.contains(queryLower);
  }

  bool equals(String query) {
    final queryLower = query.toLowerCase();
    return nameLower == queryLower || idLower == queryLower;
  }
}

extension TextSpanX on TextSpan {
  TextSpan splitMapJoin(
    Pattern pattern, {
    TextSpan Function(Match)? onMatch,
    TextSpan Function(TextSpan)? onNonMatch,
  }) {
    final children = <TextSpan>[];

    toPlainText().splitMapJoin(
      pattern,
      onMatch: (match) {
        final span = TextSpan(text: match.group(0), style: style);
        final updated = onMatch?.call(match);
        children.add(updated ?? span);
        return span.toPlainText();
      },
      onNonMatch: (text) {
        final span = TextSpan(text: text, style: style);
        final updatedSpan = onNonMatch?.call(span);
        children.add(updatedSpan ?? span);
        return span.toPlainText();
      },
    );

    return TextSpan(style: style, children: children);
  }
}

extension A on TextPatternStyleMap {
  /// Returns a new [TextPatternStyleMap] with the given [style] applied to all patterns.
  TextPatternStyleMap applyStyle(TextStyle style) {
    return map((key, value) => MapEntry(key, (context, text) => style));
  }
}
