import 'package:flutter/material.dart';
import 'package:public_chat/_shared/data/chat_data.dart';
import 'package:public_chat/features/chat/message_input/models/mention_model.dart';
import 'package:public_chat/utils/extensions.dart';
import 'package:public_chat/utils/helper.dart';
import 'package:public_chat/utils/typedefs.dart';

class MessageText extends StatelessWidget {
  const MessageText({
    super.key,
    required this.message,
    this.onMentionTap,
    this.style,
    this.textPatternStyle,
  });
  final TextPatternStyleMap? textPatternStyle;
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
      text: buildTextSpanWithPatternStyle(context, messageText,
          defaultStyle: defaultStyle, textPatternStyle: textPatternStyle),
    );
  }
}
