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
}
