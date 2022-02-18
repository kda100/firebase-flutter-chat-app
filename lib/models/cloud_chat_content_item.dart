import 'chat_content_item.dart';
import 'chat_content_item_type.dart';

///class to store information for messages that have been written to Cloud Firestore.
class CloudChatContentItem extends ChatContentItem {
  bool? read; //true == message has been read by the recipient.
  bool? onCloud; //true == message is on Cloud Firestore.

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
