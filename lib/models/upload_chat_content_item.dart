import 'package:firebase_storage/firebase_storage.dart';
import 'chat_content_item.dart';
import 'chat_content_item_type.dart';

class UploadChatContentItem extends ChatContentItem {
  UploadTask? uploadTask;
  bool isSending;
  final String sentBy;

  UploadChatContentItem({
    content,
    required ChatContentItemType chatContentItemType,
    required this.sentBy,
    UploadTask? uploadTask,
    bool isSending = false,
  })  : uploadTask = uploadTask,
        isSending = isSending,
        super(
            createdAt: DateTime.now(),
            content: content,
            chatContentItemType: chatContentItemType,
            isRecipient: false,
            sentBy: "");
}
