import 'package:firebase_chat_app/models/chat_content_item_models/chat_content_item.dart';

import '../chat_content_item_type.dart';

///foundation class for storing view data of each chat content items
abstract class ChatContentItemView {
  final String id; //firebase id reference using for widget keys
  final bool showName; //true = name of sender is shown
  final bool
      showDateHeading; //true = date heading displaying day is shown above widget.
  final ChatContentItem _chatContentItem;

  ChatContentItemView({
    required this.id,
    required this.showName,
    required this.showDateHeading,
    required ChatContentItem chatContentItem,
  }) : _chatContentItem = chatContentItem;

  get content => _chatContentItem.content;
  bool get isRecipient => _chatContentItem.isRecipient;
  DateTime get createdAt => _chatContentItem.createdAt;
  ChatContentItemType get chatContentItemType =>
      _chatContentItem.chatContentItemType;
}
