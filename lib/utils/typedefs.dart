import 'package:flutter/material.dart';
import 'package:public_chat/features/chat/auto_complete/triggers.dart';
import 'package:public_chat/features/chat/message_input/controllers/message_input_controller.dart';

/// The type of the Autocomplete callback which returns the widget that
/// contains the input [TextField] or [TextFormField].
typedef MyAutocompleteFieldViewBuilder = Widget Function(
  BuildContext context,
  MessageInputController messageEditingController,
  FocusNode focusNode,
);

typedef MyAutocompleteOptionsViewBuilder = Widget Function(
  BuildContext context,
  AutocompleteQuery autocompleteQuery,
  MessageInputController messageEditingController,
);

/// A function that takes a [BuildContext] and returns a [TextStyle].
typedef TextStyleBuilder = TextStyle? Function(
  BuildContext context,
  String text,
);

typedef TextPatternStyleMap = Map<RegExp, TextStyleBuilder>;
