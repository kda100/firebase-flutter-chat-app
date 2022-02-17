import 'chat_content_item.dart';
import 'chat_content_item_type.dart';

///class only used for messages that have been written to Cloud Firestore.
class CloudChatContentItem extends ChatContentItem {
  bool? read; //to control read state of message
  bool? onCloud; //to control instance of upload for message.

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
