import 'package:firebase_storage/firebase_storage.dart';
import 'chat_content_item.dart';
import 'chat_content_item_type.dart';

/// class only used for image and video message in the process of being uploaded to Cloud Firestore.

class UploadChatContentItem extends ChatContentItem {
  UploadTask? uploadTask; //state of upload for file.
  bool isSending; //state of whether file is being sent.

  UploadChatContentItem({
    content,
    required ChatContentItemType chatContentItemType,
    required String sentBy,
    UploadTask? uploadTask,
    bool isSending = false,
  })  : uploadTask = uploadTask,
        isSending = isSending,
        super(
            createdAt: DateTime.now(),
            content: content,
            chatContentItemType: chatContentItemType,
            isRecipient: false,
            sentBy: sentBy);
}
