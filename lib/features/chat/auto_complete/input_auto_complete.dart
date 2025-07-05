import 'package:flutter/material.dart';
import 'package:flutter_portal/flutter_portal.dart';
import 'package:public_chat/_shared/data/chat_data.dart';
import 'package:public_chat/features/chat/message_input/controllers/message_input_controller.dart';
import 'package:public_chat/utils/typedefs.dart';
import 'package:rate_limiter/rate_limiter.dart';

import 'triggers.dart';

class AutocompleteWidget extends StatefulWidget {
  /// The triggers that trigger autocomplete.
  final Iterable<AutocompleteTrigger> autocompleteTriggers;

  /// Builds the field whose input is used to get the options.
  ///
  /// Pass the provided [MessageInputController] to the field built
  /// here so that StreamAutocomplete can listen for changes.
  final MyAutocompleteFieldViewBuilder fieldViewBuilder;

  /// If this parameter is not null, then [focusNode] must also be not null.
  final MessageInputController? messageEditingController;

  /// The default value is [300ms].
  final Duration debounceDuration;

  final FocusNode? focusNode;
  const AutocompleteWidget({
    super.key,
    required this.autocompleteTriggers,
    required this.fieldViewBuilder,
    this.messageEditingController,
    this.focusNode,
    this.debounceDuration = const Duration(milliseconds: 300),
  });
  static AutocompleteWidgetState of(BuildContext context) {
    final state = context.findAncestorStateOfType<AutocompleteWidgetState>();
    assert(state != null, 'StreamAutocomplete not found in the widget tree');
    return state!;
  }

  @override
  State<AutocompleteWidget> createState() => AutocompleteWidgetState();
}

class AutocompleteWidgetState extends State<AutocompleteWidget> {
  late MessageInputController _messageEditingController;
  late FocusNode _focusNode;

  AutocompleteQuery? _currentQuery;
  AutocompleteTrigger? _currentTrigger;

  bool _hideOptions = false;
  String _lastFieldText = '';

  // True if the state indicates that the options should be visible.
  bool get _shouldShowOptions {
    return !_hideOptions &&
        _focusNode.hasFocus &&
        _currentQuery != null &&
        _currentTrigger != null;
  }

  /// Accepts and replaces the current query with the given [option] and closes
  /// the suggested options.
  ///
  /// Optionally, pass [keepTrigger] false to remove the trigger from the text.
  void acceptAutocompleteOption(
    String option, {
    bool keepTrigger = true,
  }) {
    if (option.isEmpty) return;

    final query = _currentQuery;
    final trigger = _currentTrigger;
    if (query == null || trigger == null) return;

    final querySelection = query.selection;
    final text = _messageEditingController.text;

    var start = querySelection.baseOffset;
    if (!keepTrigger) start -= 1;

    final end = querySelection.extentOffset;

    final alreadyContainsSpace = text.substring(end).startsWith(' ');
    // Having extra space helps dismissing the auto-completion view.
    // ignore: parameter_assignments
    if (!alreadyContainsSpace) option += ' ';

    var selectionOffset = start + option.length;
    // In case the extra space is already there, we need to move the cursor
    // after the space.
    if (alreadyContainsSpace) selectionOffset += 1;

    final newText = text.replaceRange(start, end, option);
    final newSelection = TextSelection.collapsed(offset: selectionOffset);

    _messageEditingController.textEditingValue = TextEditingValue(
      text: newText,
      selection: newSelection,
    );

    return closeSuggestions();
  }

  /// Closes the suggestions and resets the current query.
  void closeSuggestions() {
    final prev = _currentQuery;
    if (prev == null) return;

    _currentQuery = null;
    if (mounted) setState(() {});
  }

  /// Starts showing the suggestions for the given [query].
  void showSuggestions(
    AutocompleteQuery query,
    AutocompleteTrigger trigger,
  ) {
    final prevQuery = _currentQuery;
    final prevTrigger = _currentTrigger;
    if (prevQuery == query && prevTrigger == trigger) return;

    _currentQuery = query;
    _currentTrigger = trigger;
    if (mounted) {
      setState(() {});
    }
  }

  // Checks if there is any invoked autocomplete trigger and returns the first
  // one along with the query that matches the current input.
  AutocompleteInvokedTriggerWithQuery? _getInvokedTriggerWithQuery(
    Message messageValue,
    TextEditingValue textEditingValue,
  ) {
    final autocompleteTriggers = widget.autocompleteTriggers.toSet();
    for (final trigger in autocompleteTriggers) {
      final query = trigger.invokingTrigger(messageValue, textEditingValue);
      if (query != null) {
        return AutocompleteInvokedTriggerWithQuery(trigger, query);
      }
    }
    return null;
  }

  // Called when _textEditingController changes.
  late final _onChangedField = debounce(
    () {
      final messageValue = _messageEditingController.message;
      final textEditingValue = _messageEditingController.textEditingValue;

      // If the content has not changed, then there is nothing to do.
      if (textEditingValue.text == _lastFieldText) return;

      // Make sure the options are no longer hidden if the content of the
      // field changes.
      _hideOptions = false;
      _lastFieldText = textEditingValue.text;

      // If the text field is empty, then there is no need to do anything.
      if (textEditingValue.text.isEmpty) return closeSuggestions();

      // If the text field is not empty, then we need to check if the
      // text field contains a trigger.
      final triggerWithQuery = _getInvokedTriggerWithQuery(
        messageValue,
        textEditingValue,
      );

      // If the text field does not contain a trigger, then there is no need
      // to do anything.
      if (triggerWithQuery == null) return closeSuggestions();

      // If the text field contains a trigger, then we need to open the
      // portal.
      final trigger = triggerWithQuery.trigger;
      final query = triggerWithQuery.query;
      return showSuggestions(query, trigger);
    },
    widget.debounceDuration,
  );

  // Called when the field's FocusNode changes.
  void _onChangedFocus() {
    // Options should no longer be hidden when the field is re-focused.
    _hideOptions = !_focusNode.hasFocus;
    if (mounted) setState(() {});
  }

// Handle a potential change in textEditingController by properly disposing of
  // the old one and setting up the new one, if needed.
  void _updateTextEditingController(
    MessageInputController? old,
    MessageInputController? current,
  ) {
    if ((old == null && current == null) || old == current) {
      return;
    }
    if (old == null) {
      _messageEditingController
        ..removeListener(_onChangedField.call)
        ..dispose();
      _messageEditingController = current!;
    } else if (current == null) {
      _messageEditingController.removeListener(_onChangedField.call);
      _messageEditingController = MessageInputController();
    } else {
      _messageEditingController.removeListener(_onChangedField.call);
      _messageEditingController = current;
    }
    _messageEditingController.addListener(_onChangedField.call);
  }

  // Handle a potential change in focusNode by properly disposing of the old one
  // and setting up the new one, if needed.
  void _updateFocusNode(FocusNode? old, FocusNode? current) {
    if ((old == null && current == null) || old == current) {
      return;
    }
    if (old == null) {
      _focusNode
        ..removeListener(_onChangedFocus)
        ..dispose();
      _focusNode = current!;
    } else if (current == null) {
      _focusNode.removeListener(_onChangedFocus);
      _focusNode = FocusNode();
    } else {
      _focusNode.removeListener(_onChangedFocus);
      _focusNode = current;
    }
    _focusNode.addListener(_onChangedFocus);
  }

  @override
  void initState() {
    super.initState();
    _messageEditingController =
        widget.messageEditingController ?? MessageInputController();
    _messageEditingController.addListener(_onChangedField.call);
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_onChangedFocus);
  }

  @override
  void didUpdateWidget(AutocompleteWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updateTextEditingController(
      oldWidget.messageEditingController,
      widget.messageEditingController,
    );
    _updateFocusNode(oldWidget.focusNode, widget.focusNode);
  }

  @override
  void dispose() {
    _messageEditingController.removeListener(_onChangedField.call);
    if (widget.messageEditingController == null) {
      _messageEditingController.dispose();
    }
    _focusNode.removeListener(_onChangedFocus);
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    _onChangedField.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
// Adding additional builder so that [.of] works.
    return Builder(
      builder: (context) {
        final shouldShowOptions = _shouldShowOptions;
        final optionViewBuilder = shouldShowOptions
            ? TextFieldTapRegion(
                child: _currentTrigger!.optionsViewBuilder(
                  context,
                  _currentQuery!,
                  _messageEditingController,
                ),
              )
            : null;

        return PortalTarget(
          anchor: const Aligned(
            widthFactor: 1,
            follower: Alignment.bottomCenter,
            target: Alignment.topCenter,
          ),
          visible: shouldShowOptions,
          portalFollower: optionViewBuilder,
          child: widget.fieldViewBuilder(
            context,
            _messageEditingController,
            _focusNode,
          ),
        );
      },
    );
  }
}
