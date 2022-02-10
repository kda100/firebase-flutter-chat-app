import 'chat_content_item.dart';
import 'chat_content_item_type.dart';

class CloudChatContentItem extends ChatContentItem {
  bool? read;
  bool? onCloud;

  CloudChatContentItem({
    required this.onCloud,
    required this.read,
    required ChatContentItemType chatContentItemType,
    required bool isRecipient,
    required content,
    required DateTime createdAt,
    required String sentBy,
  }) : super(
          createdAt: createdAt,
          isRecipient: isRecipient,
          chatContentItemType: chatContentItemType,
          content: content,
          sentBy: sentBy,
        );
}
