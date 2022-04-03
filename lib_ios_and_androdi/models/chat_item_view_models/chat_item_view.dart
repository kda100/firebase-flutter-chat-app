import 'package:firebase_chat_app/models/chat_item_models/chat_item.dart';
import '../chat_item_type.dart';

///foundation class for storing view data of each chat content items
abstract class ChatItemView {
  final String id; //firebase id reference using for widget keys
  final bool showName; //true = name of sender is shown
  final bool
      showDateHeading; //true = date heading displaying day is shown above widget.
  final ChatItem _chatItem;

  ChatItemView({
    required this.id,
    required this.showName,
    required this.showDateHeading,
    required ChatItem chatItem,
  }) : _chatItem = chatItem;

  get content => _chatItem.content;
  bool get isRecipient => _chatItem.isRecipient;
  DateTime get createdAt => _chatItem.createdAt;
  ChatItemType get chatItemType => _chatItem.chatItemType;
}
