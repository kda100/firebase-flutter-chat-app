import 'package:firebase_chat_app/models/chat_content_item_models/chat_content_item.dart';
import 'package:firebase_chat_app/models/chat_content_item_type.dart';

///foundation class for storing view data of each chat content items
abstract class ChatContentItemView {
  final String id; //firebase id reference using for widget keys
  final bool showName; //true = name of sender is shown
  final bool
      showDateHeading; //true = date heading displaying day is shown above widget.
  final ChatContentItem chatContentItem;

  ChatContentItemView({
    required this.id,
    required this.showName,
    required this.showDateHeading,
    required this.chatContentItem,
  });

  get content => chatContentItem.content;
  bool get isRecipient => chatContentItem.isRecipient;
  DateTime get createdAt => chatContentItem.createdAt;
  ChatContentItemType get chatContentItemType =>
      chatContentItem.chatContentItemType;
}
