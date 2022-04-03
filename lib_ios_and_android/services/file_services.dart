import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

///Service used to perform requests to mobile devices file system.
///file services is a singleton.

class FileServices {
  static final FileServices _instance = FileServices._();

  FileServices._();

  factory FileServices() {
    return _instance;
  }

  static const int _maxMediaSizeMegaBytes =
      200; // max size of media messages (file and images)

  static int get maxMediaSizeMegaBytes => _maxMediaSizeMegaBytes;

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

  ///function to delete a single file.
  Future<void> deleteFile({required String filePath}) async {
    final File file = File(filePath);
    if (await file.exists()) await file.delete();
  }

  ///function to delete multiple files.
  Future<void> deleteFiles({required List<String> filePaths}) async {
    filePaths.forEach(
      (filePath) async {
        //thumbnail and video.
        final File file = File(filePath);
        if (await file.exists()) await File(filePath).delete();
      },
    );
  }
}
