import 'chat_content_item.dart';

class CloudChatContentItem extends ChatContentItem {
  bool? read;
  bool? onCloud;

  CloudChatContentItem({
    required this.onCloud,
    required this.read,
    required chatContentItemType,
    required content,
    required createdAt,
    required sentBy,
  }) : super(
          createdAt: createdAt,
          chatContentItemType: chatContentItemType,
          content: content,
          sentBy: sentBy,
        );
}
