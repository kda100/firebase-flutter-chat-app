import '../../constants/firebase.dart';
import '../chat_item_type.dart';
import 'chat_item.dart';

///class to store information for messages that have been written to Cloud Firestore.
class CloudChatItem extends ChatItem {
  final bool read; //true == message has been read by the recipient.
  final bool onCloud; //true == message is on Cloud Firestore.

  //constructor takes in firestore data as Map.
  CloudChatItem.fromFirestore({
    required Map<String, dynamic> cloudChatItemData,
    required String myId,
  })  : onCloud = cloudChatItemData[FieldNames.onCloudField],
        read = cloudChatItemData[FieldNames.readField],
        super(
          createdAt: cloudChatItemData[FieldNames.createdAtField].toDate(),
          isRecipient: cloudChatItemData[FieldNames.sentByIdField] != myId,
          chatItemType: ChatItemTypeConverter.decode(
              cloudChatItemData[FieldNames.chatItemTypeField]),
          content: cloudChatItemData[FieldNames.contentField],
        );
}
