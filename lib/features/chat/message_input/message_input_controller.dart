import 'package:flutter/material.dart';
import 'package:public_chat/_shared/data/chat_data.dart';
import 'package:public_chat/features/chat/message_input/message_text_field_controller.dart';

import 'models/mention_model.dart';

class MessageInputController extends ValueNotifier<Message> {
  /// Creates a controller for an editable text field.
  ///
  /// This constructor treats a null [message] argument as if it were the empty
  /// message.
  factory MessageInputController({
    Message? message,
    Map<RegExp, TextStyleBuilder>? textPatternStyle,
  }) =>
      MessageInputController._(
        initialMessage: message ?? Message(message: '', sender: ''),
        textPatternStyle: textPatternStyle,
      );

  MessageInputController._({
    required Message initialMessage,
    Map<RegExp, TextStyleBuilder>? textPatternStyle,
  })  : _initialMessage = initialMessage,
        _textFieldController = MessageTextFieldController.fromValue(
          _textEditingValueFromMessage(initialMessage),
          textPatternStyle: textPatternStyle,
        ),
        super(initialMessage) {
    _textFieldController.addListener(_textFieldListener);
  }

  /// Returns the controller of the text field linked to this controller.
  MessageTextFieldController get textFieldController => _textFieldController;
  MessageTextFieldController _textFieldController;

  Message _initialMessage;
  static TextEditingValue _textEditingValueFromMessage(Message message) {
    final messageText = message.message;
    var textEditingValue = TextEditingValue.empty;
    if (messageText.isNotEmpty) {
      textEditingValue = TextEditingValue(
        text: messageText,
        selection: TextSelection.collapsed(offset: messageText.length),
      );
    }
    return textEditingValue;
  }

  void _textFieldListener() {
    final text = _textFieldController.text;
    message = message.copyWith(message: text);
  }

  /// Returns the current message associated with this controller.
  Message get message => value;

  /// Sets the current message associated with this controller.
  set message(Message message) => value = message;

  @override
  set value(Message message) {
    super.value = message;

    // Update text field controller only if message text has changed.
    final messageText = message.message;
    final textFieldText = _textFieldController.text;
    if (messageText != textFieldText) {
      textEditingValue = _textEditingValueFromMessage(message);
    }
  }

  /// Returns the textEditingValue associated with this controller.
  TextEditingValue get textEditingValue => _textFieldController.value;

  set textEditingValue(TextEditingValue value) {
    _textFieldController.value = value;
  }

  /// Text of the message.
  String get text => _textFieldController.text;

  /// Sets the text of the message.
  set text(String text) {
    _textFieldController.text = text;
  }

  /// Sets the [message], to empty.
  void clear() {
    message = message.clear();
  }

  /// Sets the [message] to the initial [Message] value.
  void reset({bool resetId = true}) {
    if (resetId) {
      const newId = ''; //TODO use uuid
      _initialMessage = _initialMessage.copyWith(id: newId);
    }
    // Reset the message to the initial value.
    message = _initialMessage;
  }

  @override
  void dispose() {
    _textFieldController
      ..removeListener(_textFieldListener)
      ..dispose();
    super.dispose();
  }

  /// Returns the list of mentioned users in the message.
  List<MentionModel> get mentionedUsers => message.mentionedUsers;

  /// Sets the mentioned users.
  set mentionedUsers(List<MentionModel> users) {
    message = message.copyWith(mentionedUsers: users);
  }

  /// Adds a user to the list of mentioned users.
  void addMentionedUser(MentionModel user) {
    if (mentionedUsers.any((it) => it.id == user.id)) {
      // User is already mentioned, no need to add again.
      return;
    }
    mentionedUsers = [...mentionedUsers, user];
  }

  /// Removes the specified [user] from the mentioned users list.
  void removeMentionedUser(MentionModel user) {
    mentionedUsers = [...mentionedUsers]..remove(user);
  }

  /// Removes the mentioned user with the given [userId].
  void removeMentionedUserById(String userId) {
    mentionedUsers = [...mentionedUsers]..removeWhere((it) => it.id == userId);
  }

  /// Removes all mentioned users from the message.
  void clearMentionedUsers() {
    mentionedUsers = [];
  }
}
