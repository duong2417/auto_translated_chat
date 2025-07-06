import 'package:flutter/material.dart';
import 'package:public_chat/utils/helper.dart';
import 'package:public_chat/utils/typedefs.dart';

class MessageTextFieldController extends TextEditingController {
  /// Returns a new MessageTextFieldController
  MessageTextFieldController({
    super.text,
    this.textPatternStyle,
  });

  /// Returns a new MessageTextFieldController with the given text [value].
  MessageTextFieldController.fromValue(
    super.value, {
    this.textPatternStyle,
  }) : super.fromValue();

  /// A map of style to apply to the text matching the RegExp patterns.
  final TextPatternStyleMap? textPatternStyle;

  /// Builds a [TextSpan] from the current text,
  /// highlighting the matches for [textPatternStyle].
  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    final pattern = textPatternStyle;
    if (pattern == null || pattern.isEmpty) {
      return super.buildTextSpan(
        context: context,
        style: style,
        withComposing: withComposing,
      );
    }
    return buildTextSpanWithPatternStyle(context, text,
        defaultStyle: style, textPatternStyle: textPatternStyle);
  }
}
