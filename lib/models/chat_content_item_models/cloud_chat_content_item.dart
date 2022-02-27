import 'package:firebase_chat_app/constants/firebase_field_names.dart';

import 'chat_content_item.dart';
import 'chat_content_item_type.dart';

///class to store information for messages that have been written to Cloud Firestore.
class CloudChatContentItem extends ChatContentItem {
  final bool _read; //true == message has been read by the recipient.
  final bool _onCloud; //true == message is on Cloud Firestore.

  CloudChatContentItem._({
    required bool onCloud,
    required bool read,
    required ChatContentItemType chatContentItemType,
    required bool isRecipient,
    required content,
    required DateTime createdAt,
  })  : _read = read,
        _onCloud = onCloud,
        super(
          createdAt: createdAt,
          isRecipient: isRecipient,
          chatContentItemType: chatContentItemType,
          content: content,
        );

  bool get read => _read;

  bool get onCloud => _onCloud;

  //constructor takes in firestore data as Map.
  factory CloudChatContentItem({
    required Map<String, dynamic> chatContentItemData,
    required String myId,
  }) {
    return CloudChatContentItem._(
      onCloud: chatContentItemData[FieldNames.onCloudField],
      read: chatContentItemData[FieldNames.readField],
      chatContentItemType: ChatContentItemTypeConverter.decode(
          chatContentItemData[FieldNames.chatContentItemTypeField]),
      isRecipient: chatContentItemData[FieldNames.sentByIdField] != myId,
      content: chatContentItemData[FieldNames.contentField],
      createdAt: chatContentItemData[FieldNames.createdAtField].toDate(),
    );
  }
}
