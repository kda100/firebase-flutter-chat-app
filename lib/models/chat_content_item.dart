import 'chat_content_item_type.dart';

abstract class ChatContentItem {
  final content;
  final ChatContentItemType chatContentItemType;
  final bool isRecipient;
  final String sentBy;
  DateTime createdAt;

  ChatContentItem({
    required this.content,
    required this.isRecipient,
    required this.chatContentItemType,
    required this.sentBy,
    required this.createdAt,
  });
}
