import 'package:firebase_storage/firebase_storage.dart';
import '../chat_item_type.dart';
import 'chat_item.dart';

/// class to store information for image and video messages in the process of being uploaded to Cloud Firestore.

class UploadChatItem extends ChatItem {
  UploadTask? uploadTask; //state of upload for file.

  //for image files
  UploadChatItem.image_({
    required String imagePath,
    UploadTask? uploadTask,
  })  : uploadTask = uploadTask,
        super(
          createdAt: DateTime.now(),
          content: imagePath,
          chatItemType: ChatItemType.IMAGE,
          isRecipient: false,
        );

  //for video file.
  UploadChatItem.video_({
    required List<String> videoAndThumbnailPaths,
    UploadTask? uploadTask,
  })  : uploadTask = uploadTask,
        super(
          createdAt: DateTime.now(),
          content: videoAndThumbnailPaths,
          chatItemType: ChatItemType.VIDEO,
          isRecipient: false,
        );

  factory UploadChatItem(
      {required ChatItemType chatItemType, required var content}) {
    if (chatItemType == ChatItemType.IMAGE) {
      return UploadChatItem.image_(
        imagePath: content,
      );
    } else {
      return UploadChatItem.video_(
        videoAndThumbnailPaths: content,
      );
    }
  }
}
