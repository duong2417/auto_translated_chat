import 'package:flutter/material.dart';
import 'package:public_chat/_shared/data/chat_data.dart';
import 'package:public_chat/features/chat/message_input/typedefs.dart';

class AutocompleteTrigger {
  /// The trigger character for the autocomplete: for example, '@' for mentions.
  final String trigger;

  /// Whether the [trigger] should only be recognised at the start of the input, eg: '/'
  final bool triggerOnlyAtStart;

  /// Whether the [trigger] should only be recognised after a space.
  final bool triggerOnlyAfterSpace;

  /// The minimum required characters for the [trigger] to start recognising
  /// a autocomplete options.
  final int minimumRequiredCharacters;

  /// Builds the widget responsible for querying and displaying the
  /// autocomplete options.
  final MyAutocompleteOptionsViewBuilder optionsViewBuilder;

  AutocompleteTrigger({
    required this.trigger,
    this.triggerOnlyAtStart = false,
    this.triggerOnlyAfterSpace = false,
    required this.optionsViewBuilder,
    this.minimumRequiredCharacters = 0,
  });
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AutocompleteTrigger &&
          runtimeType == other.runtimeType &&
          trigger == other.trigger &&
          triggerOnlyAtStart == other.triggerOnlyAtStart &&
          triggerOnlyAfterSpace == other.triggerOnlyAfterSpace &&
          minimumRequiredCharacters == other.minimumRequiredCharacters;

  @override
  int get hashCode =>
      trigger.hashCode ^
      triggerOnlyAtStart.hashCode ^
      triggerOnlyAfterSpace.hashCode ^
      minimumRequiredCharacters.hashCode;

  /// Checks if the user is invoking the recognising [trigger] and returns
  /// the autocomplete query if so.
  AutocompleteQuery? invokingTrigger(
    Message message,
    TextEditingValue textEditingValue,
  ) {
    final text = textEditingValue.text;
    final cursorPosition = textEditingValue.selection.baseOffset;

    // Find the first [trigger] location before the input cursor.
    final firstTriggerIndexBeforeCursor =
        text.substring(0, cursorPosition).lastIndexOf(trigger);

    // If the [trigger] is not found before the cursor, then it's not a trigger.
    if (firstTriggerIndexBeforeCursor == -1) return null;

    // If the [trigger] is found before the cursor, but the [trigger] is only
    // recognised at the start of the input, then it's not a trigger.
    if (triggerOnlyAtStart && firstTriggerIndexBeforeCursor != 0) {
      return null;
    }

    // Only show typing suggestions after a space, or at the start of the input
    // valid examples: "@user", "Hello @user"
    // invalid examples: "Hello@user"
    final textBeforeTrigger = text.substring(0, firstTriggerIndexBeforeCursor);
    if (triggerOnlyAfterSpace &&
        textBeforeTrigger.isNotEmpty &&
        !textBeforeTrigger.endsWith(' ')) {
      return null;
    }

    // The suggestion range. Protect against invalid ranges.
    final suggestionStart = firstTriggerIndexBeforeCursor + trigger.length;
    final suggestionEnd = cursorPosition;
    if (suggestionStart > suggestionEnd) return null;

    // Fetch the suggestion text. The suggestions can't have spaces.
    // valid example: "@luke_skywa..."
    // invalid example: "@luke skywa..."
    final suggestionText = text.substring(suggestionStart, suggestionEnd);
    if (suggestionText.contains(' ')) return null;

    // A minimum number of characters can be provided to only show
    // suggestions after the customer has input enough characters.
    if (suggestionText.length < minimumRequiredCharacters) return null;

    return AutocompleteQuery(
      query: suggestionText,
      selection: TextSelection(
        baseOffset: suggestionStart,
        extentOffset: suggestionEnd,
      ),
    );
  }
}

/// The query to determine the autocomplete options.
class AutocompleteQuery {
  /// Creates a [AutocompleteQuery] with the specified [query] and
  /// [selection].
  const AutocompleteQuery({
    required this.query,
    required this.selection,
  });

  /// The query string.
  final String query;

  /// The selection in the text field.
  final TextSelection selection;
}


class AutocompleteInvokedTriggerWithQuery {
  const AutocompleteInvokedTriggerWithQuery(this.trigger, this.query);

  final AutocompleteTrigger trigger;
  final AutocompleteQuery query;
}