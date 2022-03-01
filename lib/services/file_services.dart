import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_chat_app/models/chat_content_item_type.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

///Service used to perform requests to mobile devices file system.

class FileServices {
  static const int maxMediaSizeMegaBytes =
      200; // max size of media messages (file and images)

  ///function used to get file path of chat content item user would like to get.
  Future<String?> getFilePath({required FileType fileType}) async {
    FilePickerResult? filePickerResult =
        await FilePicker.platform.pickFiles(type: fileType);
    return filePickerResult?.files.single.path;
  }

  ///used to check file size user would like to send does not exceed limit.
  Future<bool> checkFileSize(File file) async {
    final int fileSize = await file.length();
    if (fileSize > maxMediaSizeMegaBytes * 1000000) return false;
    return true;
  }

  ///used to check user has granted permission for app to access media files.
  Future<bool> storagePermissionRequest(
      {required Permission permission}) async {
    PermissionStatus status = await Permission.storage.status;
    if (status.isGranted) {
      return true;
    } else {
      status = await Permission.storage.request();
      if (status.isGranted) {
        return true;
      } else {
        return false;
      }
    }
  }

  ///used to generate a thumbnail for video file.
  Future<File?> genVideoThumbnail({required String videoPath}) async {
    String? thumbnailFilePath = await VideoThumbnail.thumbnailFile(
      video: videoPath,
      imageFormat: ImageFormat.JPEG,
    );
    if (thumbnailFilePath != null) {
      return File(thumbnailFilePath);
    }
    return null;
  }

  ///this function removes cached files once they have been uploaded to storage.
  Future<void> deleteChatMediaItemCache({
    required var content,
    required ChatContentItemType chatContentItemType,
  }) async {
    if (chatContentItemType == ChatContentItemType.IMAGE) {
      // just image
      if (content != null) {
        final File file = File(content);
        if (await file.exists()) await file.delete();
      }
    } else if (chatContentItemType == ChatContentItemType.VIDEO) {
      content.forEach(
        (filePath) async {
          //thumbnail and video.
          if (filePath != null) {
            final File file = File(filePath);
            if (await file.exists()) await File(filePath).delete();
          }
        },
      );
    }
  }
}
