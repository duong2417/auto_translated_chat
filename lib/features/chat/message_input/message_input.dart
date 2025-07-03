import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:public_chat/_shared/data/chat_data.dart';
import 'package:public_chat/_shared/simple_safe_area.dart';
import 'package:public_chat/_shared/widgets/message_box_widget.dart';

import 'auto_complete/auto_complete_options.dart';
import 'auto_complete/input_auto_complete.dart';
import 'auto_complete/triggers.dart';
import 'constants.dart';
import 'message_input_controller.dart';
import 'models/mention_model.dart';
import 'widgets/mention_tile.dart';

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
        MessageInputController(textPatternStyle: {
          kMentionPattern: (context, text) => const TextStyle(
                color: Colors.blue,
                fontWeight: FontWeight.bold,
              ),
        });
    _focusNode = widget.focusNode ?? FocusNode();
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
    }
    _focusNode.dispose();
    super.dispose();
  }

  List<MentionModel> _fetchMentions(String query) {
    // FirebaseFirestore.instance
    //     .collection('bots')
    //     .where('name', isEqualTo: query)
    //     .get();
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
            child: Column(
              spacing: 8,
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget?>[
                _buildTextField(context),
              ].nonNulls.toList(),
            ),
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
      onSendMessage: (value) {
        final trimmedValue = value.trim();
        if (widget.user == null ||
            widget.user!.uid.isEmpty ||
            trimmedValue.isEmpty) {
          // do nothing
          return;
        }
        FirebaseFirestore.instance.collection('public').add(
            Message(sender: widget.user!.uid, message: trimmedValue).toMap());
      },
    );
  }
}
