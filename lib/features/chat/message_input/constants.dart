import 'package:flutter/material.dart';
import 'package:public_chat/features/chat/message_input/models/mention_model.dart';

///////CHAT MESSAGE INPUT CONSTANTS////////

const kMentionTrigger = '@';

// Pattern forr detecting mentions (starting with @ and ending with space or end of string)
final kMentionPattern = RegExp(r'@\w+(?=\s|$)');

const mentionStyle = TextStyle(
  color: Colors.blue,
  fontWeight: FontWeight.bold,
);

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
