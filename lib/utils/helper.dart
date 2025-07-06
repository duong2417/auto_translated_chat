import 'package:flutter/material.dart';
import 'package:public_chat/utils/constants.dart';
import 'package:public_chat/utils/extensions.dart';
import 'package:public_chat/utils/typedefs.dart';

/// Returns a map of patterns to styles for mentions.
TextPatternStyleMap mentionPattern({
  TextStyle? style,
}) {
  return {
    kMentionPattern: (context, text) => style ?? _getMentionStyle(text),
  };
}

TextStyle? _getMentionStyle(String mentionText) {
  // Extract the username from the mention text (remove @ and [ ])
  final mentionExcludeTriggerCharactor =
      mentionText.replaceAll(RegExp(r'[@\[\]]'), '');
  // Check if this mention exists in the mentioned users list
  final isValidMention = defaultMentions
      .any((user) => user.equals(mentionExcludeTriggerCharactor));
  // Return highlight style only for valid mentions
  return isValidMention ? mentionStyle : null;
}

TextSpan buildTextSpanWithPatternStyle(BuildContext context, String text,
    {TextStyle? defaultStyle,
    TextPatternStyleMap? textPatternStyle,
    bool caseSensitive = false}) {
  final style = defaultStyle ?? DefaultTextStyle.of(context).style;
  if (textPatternStyle == null || textPatternStyle.isEmpty) {
    return TextSpan(text: text, style: style);
  }
  return TextSpan(text: text, style: style).splitMapJoin(
    RegExp(
      textPatternStyle.keys.map((it) => it.pattern).join('|'),
      caseSensitive: caseSensitive,
    ),
    onMatch: (match) {
      final text = match[0]!;
      final key = textPatternStyle.keys.firstWhere((it) => it.hasMatch(text));
      return TextSpan(
        text: text,
        style: textPatternStyle[key]?.call(
          context,
          text,
        ),
      );
    },
  );
}
