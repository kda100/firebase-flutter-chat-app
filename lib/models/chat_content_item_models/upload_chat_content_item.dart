import 'package:firebase_storage/firebase_storage.dart';
import 'chat_content_item.dart';
import 'chat_content_item_type.dart';

/// class to store information for image and video messages in the process of being uploaded to Cloud Firestore.

class UploadChatContentItem extends ChatContentItem {
  UploadTask? uploadTask; //state of upload for file.

  //for image files
  UploadChatContentItem.image_({
    required String imagePath,
    UploadTask? uploadTask,
  })  : uploadTask = uploadTask,
        super(
          createdAt: DateTime.now(),
          content: imagePath,
          chatContentItemType: ChatContentItemType.IMAGE,
          isRecipient: false,
        );

  //for video file.
  UploadChatContentItem.video_({
    required List<String> videoAndThumbnailPaths,
    UploadTask? uploadTask,
  })  : uploadTask = uploadTask,
        super(
          createdAt: DateTime.now(),
          content: videoAndThumbnailPaths,
          chatContentItemType: ChatContentItemType.VIDEO,
          isRecipient: false,
        );

  factory UploadChatContentItem(
      {required ChatContentItemType chatContentItemType,
      required var content}) {
    if (chatContentItemType == ChatContentItemType.IMAGE) {
      return UploadChatContentItem.image_(
        imagePath: content,
      );
    } else {
      return UploadChatContentItem.video_(
        videoAndThumbnailPaths: content,
      );
    }
  }
}
