import 'package:flutter/material.dart';
import 'package:public_chat/features/chat/message_input/models/mention_model.dart';

const kMentionTrigger = '@';

final defaultMentions = [
  MentionModel(
    id: 'bot',
    name: 'Gemini',
    type: MentionType.bot,
  )
];

const kDefaultAutocompleteOptionsShape = RoundedRectangleBorder(
  borderRadius: BorderRadius.all(Radius.circular(8)),
);