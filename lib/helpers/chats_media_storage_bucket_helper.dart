import 'dart:io';

///enum to create the correct storage file path for video message.
enum ChatVideoItemFolder {
  Folder,
  VideoFile,
  ThumbnailFile,
}

///class containing helpers for sending image and video messages.

class ChatsMediaStorageBucketHelper {
  static const maxMediaSizeMegaBytes = 200;

  ///checks if media file is below a threshold.
  static Future<bool> checkMediaBytes(File file) async {
    final int fileSize = await file.length();
    if (fileSize > maxMediaSizeMegaBytes * 1000000) return false;
    return true;
  }

  ///returns image file name for Firebase Storage.
  static String chatImageItemFileName({required String chatContentId}) {
    return "$chatContentId";
  }

  /// returns thumbnail file, video file and folder file path for videos uploaded to Firebase Storage.
  static String chatVideoItemFolder({
    required String chatContentId,
    required ChatVideoItemFolder chatVideoItemFolder,
  }) {
    final String chatVideoItemFolderName = "$chatContentId";
    if (chatVideoItemFolder == ChatVideoItemFolder.Folder) {
      return chatVideoItemFolderName;
    } else if (chatVideoItemFolder == ChatVideoItemFolder.VideoFile) {
      return "$chatVideoItemFolderName/video";
    } else {
      return "$chatVideoItemFolderName/thumbnail";
    }
  }
}
