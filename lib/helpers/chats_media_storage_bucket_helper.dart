import 'dart:io';

enum ChatVideoItemFolder {
  Folder,
  VideoFile,
  ThumbnailFile,
}

class ChatsMediaStorageBucketHelper {
  static const maxMediaSizeMegaBytes = 200;

  static Future<bool> checkMediaBytes(File file) async {
    final int fileSize = await file.length();
    if (fileSize > maxMediaSizeMegaBytes * 1000000) return false;
    return true;
  }

  static String chatImageStorageRefName({
    required clientUID,
    required coachUID,
  }) {
    return "$coachUID/$clientUID/images";
  }

  static String chatVideoStorageRefName({
    required clientUID,
    required coachUID,
  }) {
    return "$coachUID/$clientUID/videos";
  }

  static String chatImageItemFileName({required String chatContentId}) {
    return "$chatContentId";
  }

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

  static String chatImageItemInternalStorageFile(
      {required String chatContentItemId}) {
    return "IMAGE_$chatContentItemId.jpg";
  }

  static String chatVideoItemInternalStorageFile(
      {required String chatContentItemId}) {
    return "VIDEO_$chatContentItemId.mp4";
  }
}
