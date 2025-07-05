import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:public_chat/_shared/widgets/simple_safe_area.dart';
import 'package:public_chat/_shared/widgets/message_box_widget.dart';

import '../auto_complete/auto_complete_options.dart';
import '../auto_complete/input_auto_complete.dart';
import '../auto_complete/triggers.dart';
import '../../../utils/constants.dart';
import 'controllers/message_input_controller.dart';
import 'models/mention_model.dart';
import '../widgets/mention_tile.dart';

class ChatMessageInput extends StatefulWidget {
  final User? user;
  final MessageInputController? messageInputController;
  final FocusNode? focusNode;
  const ChatMessageInput(
      {super.key,
      this.messageInputController,
      required this.user,
      this.focusNode});

  @override
  State<ChatMessageInput> createState() => _ChatMessageInputState();
}

class _ChatMessageInputState extends State<ChatMessageInput> {
  late final MessageInputController _messageInputController;
  late final FocusNode _focusNode;
  @override
  void initState() {
    super.initState();
    _messageInputController = widget.messageInputController ??
        MessageInputController(
          textPatternStyle: {
            kMentionPattern: (context, text) => _getMentionStyle(text),
          },
        );
    _focusNode = widget.focusNode ?? FocusNode();
  }

  TextStyle _getMentionStyle(String mentionText) {
    // Extract the username from the mention text (remove @ and [ ])
    final mentionExcludeTriggerCharactor =
        mentionText.replaceAll(RegExp(r'[@\[\]]'), '');
    // Check if this mention exists in the mentioned users list
    final isValidMention = defaultMentions.any((user) =>
        user.id == mentionExcludeTriggerCharactor ||
        user.name == mentionExcludeTriggerCharactor);
    // Return highlight style only for valid mentions
    return isValidMention ? mentionStyle : const TextStyle();
  }

  @override
  dispose() {
    if (widget.messageInputController == null) {
      // Only dispose if we created the controller
      _messageInputController.dispose();
    }
    if (widget.focusNode == null) {
      // Only dispose if we created the focus node
      _focusNode.unfocus();
      _focusNode.dispose();
    }
    super.dispose();
  }

  List<MentionModel> _fetchMentions(String query) {
    return defaultMentions
        .where(
            (mention) => mention.id.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  Widget _buildMessageInput(
    BuildContext context,
    MessageInputController controller,
    FocusNode focusNode,
  ) {
    return ValueListenableBuilder(
        valueListenable: controller,
        builder: (context, snapshot, child) {
          return Padding(
            padding: const EdgeInsets.all(8),
            child: _buildTextField(context),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    final messageInput = AutocompleteWidget(
      focusNode: _focusNode,
      messageEditingController: _messageInputController,
      autocompleteTriggers: [
        AutocompleteTrigger(
          trigger: kMentionTrigger,
          optionsViewBuilder: (
            context,
            autocompleteQuery,
            messageInputController,
          ) {
            final query = autocompleteQuery.query;
            final mentions = _fetchMentions(query);
            return AutocompleteOptions<MentionModel>(
              options: mentions,
              optionBuilder: (context, mention) {
                return Material(
                  child: InkWell(
                    onTap: () {
                      messageInputController.addMentionedUser(mention);
                      AutocompleteWidget.of(context)
                          .acceptAutocompleteOption(mention.name);
                    },
                    child: MentionTile(
                      title: mention.name,
                      subtitle: mention.id,
                    ),
                  ),
                );
              },
              headerBuilder: (context) => const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text('Only Gemini bot is available for now'),
              ),
            );
          },
        ),
      ],
      fieldViewBuilder: (BuildContext context,
          MessageInputController messageEditingController,
          FocusNode focusNode) {
        return _buildMessageInput(
          context,
          messageEditingController,
          focusNode,
        );
      },
    );
    return SimpleSafeArea(
      enabled: true,
      child: Center(child: messageInput),
    );
  }

  Widget _buildTextField(BuildContext context) {
    return MessageBox(
      key: const Key('messageInputText'),
      controller: _messageInputController.textFieldController,
      focusNode: _focusNode,
      prefixIcon: IconButton(
          icon: const Icon(Icons.flash_on),
          onPressed: () {
            _messageInputController.text = '@';
          }),
      onSendMessage: (value) {
        final trimmedValue = value.trim();
        if (widget.user == null ||
            widget.user!.uid.isEmpty ||
            trimmedValue.isEmpty) {
          // do nothing
          return;
        }
        FirebaseFirestore.instance.collection('public').add(
            _messageInputController.message
                .copyWith(sender: widget.user!.uid, message: trimmedValue)
                .toMap());
      },
    );
  }
}
