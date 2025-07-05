import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:public_chat/_shared/data/chat_data.dart';
import 'package:public_chat/features/chat/message_input/models/mention_model.dart';
import 'package:public_chat/utils/constants.dart';
import 'package:public_chat/utils/extensions.dart';

class MessageText extends StatelessWidget {
  const MessageText({
    super.key,
    required this.message,
    this.onMentionTap,
    this.style,
  });
  final TextStyle? style;

  /// Message whose text is to be displayed
  final Message message;

  /// The action to perform when a mention is tapped
  final void Function(MentionModel)? onMentionTap;

  @override
  Widget build(BuildContext context) {
    final messageText = message.replaceMentions(linkify: false).message.trim();
    final defaultStyle = style ?? DefaultTextStyle.of(context).style;

    return RichText(
      text: _buildTextSpan(messageText, defaultStyle),
    );
  }

  TextSpan _buildTextSpan(String text, TextStyle defaultStyle) {
    final spans = <TextSpan>[];
    int lastIndex = 0;

    for (final match in kMentionPattern.allMatches(text)) {
      // Add text before mention
      if (match.start > lastIndex) {
        spans.add(TextSpan(
          text: text.substring(lastIndex, match.start),
          style: defaultStyle,
        ));
      }

      // Add mention with special style
      final mentionText = match.group(0)!;
      spans.add(TextSpan(
        text: mentionText,
        style: defaultStyle.merge(mentionStyle),
        recognizer: onMentionTap != null
            ? (TapGestureRecognizer()
              ..onTap = () {
                // Extract mention name without @ symbol
                final mentionId = mentionText.substring(1);

                // Find the mention in the message's mentionedUsers list
                final mention = message.mentionedUsers.firstWhere(
                  (user) => user.id == mentionId || user.name == mentionId,
                  orElse: () => MentionModel(id: mentionId, name: mentionId),
                );
                onMentionTap!(mention);
              })
            : null,
      ));

      lastIndex = match.end;
    }

    // Add remaining text
    if (lastIndex < text.length) {
      spans.add(TextSpan(
        text: text.substring(lastIndex),
        style: defaultStyle,
      ));
    }

    return TextSpan(children: spans);
  }
}
